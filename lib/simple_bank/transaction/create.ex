defmodule SimpleBank.Transaction.Create do
  @moduledoc """
  Módulo Transaction.Create para a criação de uma nova transação para o SimpleBank.Account.

  Este módulo define um serviço de criação para a tabela de "transactions",
  fornecendo uma função que recebe como argumento os seguintes campos:
  - :type - O tipo da transação que pode ser transferência (:transfer), depósito (:deposit) ou saque (:withdraw)
  - :amount - O valor da transação (decimal)
  - :account_number - O número da conta à qual a transação pertence (Account.t())
  - :recipient_number - O número da conta que receberá a transação (Account.t.)

  O campo :amount é opcional, visto que se não for fornecido o sistema entenderá como 0.
  O campo :recipient_number é opcional, visto que transações de saque e depósito afetam apenas a própria conta.
  A transação ainda terá um campo :number que será gerado automaticamente pelo código.
  """
  alias SimpleBank.{Transaction, Account, Repo, Error}

  @type transaction_params :: %{
    type: :transfer | :deposit | :withdraw,
    amount: Decimal.t(),
    account_number: integer(),
    recipient_number: nil | integer()
  }

  @spec call(transaction_params()) ::
        {:error, Error.t()} | {:ok, Transaction.t()}
  def call(%{} = params) do
    type = Map.get(params, :type)
    account_number = Map.get(params, :account_number)
    recipient_number = Map.get(params, :recipient_number, 0)
    amount = Map.get(params, :amount, Decimal.new("0"))

    number = create_transaction_number(type)

    with {:ok, %Account{} = account} <- get_account(account_number),
        {:ok} <- verify_account(account.type, type),
        {:ok, result} <- create_transaction(type, account, recipient_number, amount, number) do
      {:ok, result}
    else
      {:error, %Error{}} = error -> error
    end
  end

  @doc """
  Esta função é ativada quando o usuário envia um argumento inválido.
  """
  def call(_anything), do: {:error, "Enter the data in a map format"}

  defp create_transaction(:transfer, account, recipient_number, amount, number) do
    with {:ok} <- verify_balance(account.balance, amount),
         {:ok, %Account{} = recipient} <- get_account(recipient_number),
         :ok <- ensure_different_accounts(account, recipient),
         multi <- build_transfer(account, recipient, :transfer, amount, number),
         {:ok, transaction} <- Repo.transaction(multi) do
      {:ok, transaction.inserted_transaction}
    else
      {:error, %Error{} = error} ->
        handle_error_transaction(error, account, :transfer, amount, number)
        {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, Error.build(:internal_server_error, failed_value.result)}
    end
  end

  defp create_transaction(:deposit, account, _recipient_number, amount, number) do
    with multi <- build_deposit(account, :deposit, amount, number),
        {:ok, transaction} <- Repo.transaction(multi) do
      {:ok, transaction.inserted_transaction}
    else
      {:error, _failed_operation, failed_value, _changes_so_far} -> {:error, Error.build(:internal_server_error, failed_value.result)}
      {:error, %Error{} = error} -> handle_error_transaction(error, account, :deposit, amount, number)
    end
  end

  defp create_transaction(:withdraw, account, _recipient_number, amount, number) do
    with {:ok} <- verify_balance(account.balance, amount),
         multi <- build_withdraw(account, :withdraw, amount, number),
         {:ok, transaction} <- Repo.transaction(multi) do
      {:ok, transaction.inserted_transaction}
    else
      {:error, %Error{} = error} -> handle_error_transaction(error, account, :withdraw, amount, number)
      {:error, _failed_operation, failed_value, _changes_so_far} -> {:error, Error.build(:internal_server_error, failed_value.result)}
    end
  end

  defp ensure_different_accounts(%Account{id: id1}, %Account{id: id2}) when id1 != id2, do: :ok
  defp ensure_different_accounts(_, _), do: {:error, Error.build(:bad_request, "Sender and recipient accounts must be different")}

  # criação do build para o Ecto.Multi
  defp build_transfer(account, recipient_account, type, amount, number) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:update_account, fn _repo, _changes ->
      update_account(account, account.type, Decimal.sub(account.balance, amount))
    end)
    |> Ecto.Multi.run(:update_recipient_account, fn _repo, _changes ->
      update_account(recipient_account, recipient_account.type, Decimal.add(recipient_account.balance, amount))
    end)
    |> Ecto.Multi.run(:inserted_transaction, fn _repo, _changes ->
      insert_transaction(account, recipient_account, type, amount, number, :complete)
    end)
  end

  defp build_deposit(account, type, amount, number) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:update_account, fn _repo, _changes ->
      update_account(account, account.type, Decimal.add(account.balance, amount))
    end)
    |> Ecto.Multi.run(:inserted_transaction, fn _repo, _changes ->
      insert_transaction(account, nil, type, amount, number, :complete)
    end)
  end

  defp build_withdraw(account, type, amount, number) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:update_account, fn _repo, _changes ->
      update_account(account, account.type, Decimal.sub(account.balance, amount))
    end)
    |> Ecto.Multi.run(:inserted_transaction, fn _repo, _changes ->
      insert_transaction(account, nil, type, amount, number, :complete)
    end)
  end

  # Inserção da transação no banco de dados
  defp insert_transaction(account, recipient_account, type, amount, number, status) do
    transaction_params = %{
      number: number,
      type: type,
      status: status,
      amount: amount,
      account_id: account.id,
      recipient_id: recipient_account && recipient_account.id
    }

    with changeset <- Transaction.changeset(transaction_params),
         {:ok, transaction} <- Repo.insert(changeset),
         transaction = Repo.preload(transaction, [recipient: :user]) do
      {:ok, transaction}
    else
      {:error, result} -> {:error, Error.build(:bad_request, result)}
    end
  end

  #Criação da transação com status :incomplete
  defp handle_error_transaction(%Error{} = error, account, type, amount, number) do
    transaction_params = %{
      number: number,
      type: type,
      status: :incomplete,
      amount: amount,
      account_id: account.id,
    }

    changeset = Transaction.changeset(%Transaction{}, transaction_params)

    case Repo.insert(changeset) do
      {:ok, _transaction} -> {:error, error}
      {:error, result} -> {:error, Error.build(:bad_request, result)}
    end
  end

  # Esta é a função privada chamada para gerar um número aleatório para a transação.
  defp create_transaction_number(type) do
    prefix = case type do
      :transfer -> "18"
      :deposit -> "24"
      :withdraw -> "30"
      _ -> "18"
    end

    random_numbers = for _ <- 1..7, do: Integer.to_string(:rand.uniform(9))
    transaction_number = prefix <> Enum.join(random_numbers, "")

    case Repo.get_by(Transaction, number: String.to_integer(transaction_number)) do
      nil -> String.to_integer(transaction_number)
      _transaction -> create_transaction_number(type)
    end
  end

  # Função para buscar a conta no banco de dados.
  defp get_account(number) do
    case Repo.get_by(Account, number: number) do
      nil -> {:error, Error.build(:not_found, "Account not found!")}
      %Account{} = account -> {:ok, account}
    end
  end

  # Função para verificar o tipo da conta.
  defp verify_account(account_type, type) do
    cond do
      account_type == :chain -> {:ok}
      account_type == :savings and type == :deposit -> {:ok}
      account_type == :savings and type == :withdraw -> {:ok}
      account_type == :wage and type == :withdraw -> {:ok}
      true -> {:error, Error.build(:bad_request, "Transaction not allowed for this account type")}
    end
  end

  # Função para verificar o saldo disponível na conta.
  defp verify_balance(balance, amount) do
    if Decimal.compare(balance, amount) != :lt do
      {:ok}
    else
      {:error, Error.build(:bad_request, "Insufficient balance for the transaction!")}
    end
  end

  # Função para atualizar a conta.
  defp update_account(%Account{} = account, type, balance) do
    with changeset <- Account.changeset_to_update(account, %{type: type, balance: balance}),
        {:ok, %Account{}} <- Repo.update(changeset) do
      {:ok, %Account{}}
    else
      {:error, result} -> {:error, Error.build(:bad_request, result)}
    end
  end
end
