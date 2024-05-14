defmodule SimpleBank.Transaction.Create do
  @moduledoc """
  Módulo Transaction.Create para a criação de uma noa transação para o SimpleBank.Account

  Este módulo define um serviço de criação para a tablea de "transactions"
  fornecendo uma função que recebe como argumento os seguintes campos:
  - :type - O tipo da transação que pode transferência (:transfer), deposito (:deposit) ou saque (:withdraw)
  - :amount - O valor da transação (decimal)
  - :account_number - O número da conta a qual a transação pertence (Account.t())
  - :recipient_number - O número da conta que receberá a transação (Account.t())

  O campo :amount é opicional, visto que se não for fornecido o sistema entenderá como 0.
  O campo :recipient_id e opicional, visto que transaçoes de saque e deposito a afetada e a unica conta afetada.
  A transação ainda tera um campo :number que será gerado automaticamente pelo código.
  """
  import Ecto.Query

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
    receive_number = Map.get(params, :receive_number)
    amount = Map.get(params, :amount)

    case get_account(account_number) do
      {:error, %Error{}} = error -> error
      {:ok, account} ->
        number = create_transaction_number(type)
        with multi <- build_multi(account, type, amount, receive_number, number),
        {:ok, %Transaction{}} <- Repo.transaction(multi) do
          {:ok, %Transaction{}}
        else
          {:error, _failed_operation, failed_value, _changes_so_far} ->
            %{number: number, type: type, status: :incomplete, amount: amount, account_id: account[:id]}
            |> Transaction.changeset()
            |> Repo.insert()
            {:error, Error.build(:bad_request, failed_value)}
        end
    end
  end

  @doc """
  Esta função e ativada quando o usuário envia um argumento invalido
  """
  def call(_anything), do: {:error, "Enter the data in a map format"}

  defp build_multi(_account, type, amount, receive_number, number) do
    case type do
      :transfer ->
        Ecto.Multi.new()
        |> Ecto.Multi.run(:verify_account, fn _repo, %{account: account} ->
          verify_account(account[:type], type) end)
        |> Ecto.Multi.run(:verify_balance, fn _repo, %{account: account} ->
          verify_balance(account[:balance], amount) end)
        |> Ecto.Multi.run(:receive_account, fn _repo, _changes ->
          get_account(receive_number) end)
        |> Ecto.Multi.run(:update_account, fn _repo, %{account: account} ->
          update_account(account, type, account[:balance] - amount) end)
        |> Ecto.Multi.run(:update_receive_account, fn _repo, %{receive_account: receive_acount} ->
          update_account(receive_acount, type, receive_acount[:balance] + amount) end)
        |> Ecto.Multi.run(:inserted_transaction, fn _repo, %{account: account, receive_account: receive_account} ->
          insert_transaction(account, receive_account, type, amount, number, :complete) end)

      :deposit ->
        Ecto.Multi.new()
        |> Ecto.Multi.run(:verify_account, fn _repo, %{account: account} ->
          verify_account(account[:type], type) end)
        |> Ecto.Multi.run(:update_account, fn _repo, %{account: account} ->
          update_account(account, type, account[:balance] + amount) end)
        |> Ecto.Multi.run(:inserted_transaction, fn _repo, %{account: account} ->
          insert_transaction(account, nil, type, amount, number, :complete) end)

      :withdraw ->
        Ecto.Multi.new()
        |> Ecto.Multi.run(:verify_balance, fn _repo, %{account: account} ->
        verify_balance(account[:balance], amount) end)
        |> Ecto.Multi.run(:update_account, fn _repo, %{account: account} ->
        update_account(account, type, account[:balance] - amount) end)
        |> Ecto.Multi.run(:inserted_transaction, fn _repo, %{account: account} ->
          insert_transaction(account, nil, type, amount, number, :complete) end)
    end
  end

  defp insert_transaction(account, receive_account, type, amount, number, status) do
    transaction_params = %{
      number: number,
      type: type,
      status: status,
      amount: amount,
      account_id: account[:id],
      recipient_id: receive_account && receive_account[:id]
    }

    Transaction.changeset(transaction_params)
    |> Repo.insert()
  end

  # Está é a função privada chamada para gerar um número aleatório para a conta
  defp create_transaction_number(type) do
    prefix = case type do
      :transfer -> "18"
      :deposit -> "24"
      :withdraw -> "30"
      _ -> "18"
    end

    random_numbers = for _ <- 1..10, do: Integer.to_string(:rand.uniform(9))
    transaction_number = prefix <> Enum.join(random_numbers, "")

    case Repo.get(Transaction, transaction_number) do
      nil -> transaction_number
      _transaction -> create_transaction_number(type)
    end
  end

  # Função para buscar a conta no banco de dados
  defp get_account(number) do
    query = from a in Account,
      where: a.number == ^number,
      select: %{id: a.id, type: a.type, balance: a.balance}

    case Repo.one(query) do
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
      account -> {:ok, account}
    end
  end

  # Função para verificar o tipo da conta
  defp verify_account(account_type, type) do
    cond do
      account_type == :chain ->
        {:ok}

      account_type == :saving and
      type == :deposit ->
        {:ok}

      account_type == :wage ->
        {:ok}

      true ->
        {:error, Error.build(:bad_request, "Transaction not allowed for this account type")}
    end
  end

  # Função para verificar o saldo disponivel na conta
  defp verify_balance(balance, amount) do
    case balance >= amount do
      false -> {:error, Error.build(:bad_request, "You do not have enough balance to complete the transaction!")}
      true -> {:ok}
    end
  end

  # Função para atualizar a conta
  defp update_account(%Account{} = account, type, balance) do
    account
    |> Account.changeset_to_update(%{
      type: type,
      balance: balance
    })
    |> Repo.update()
  end
end
