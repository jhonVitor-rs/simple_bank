defmodule SimpleBank.Transaction.Update do
  @moduledoc """
  MOdulo Transaction.Update para Atualização de Transações no SimpleBank.Account

  Este modulo define o serviço de atualização para a tabela "transactions",
  fornecendo uma função para atualização que deverá receber como parametro os campos:
  - :id - Um ID unico gerado pelo sistema, ele será enviado junto com a URL (binary())
  - :type - O tipo da transação que pode transferência (:transfer), deposito (:deposit) ou saque (:withdraw)
  - :status - O status em que a transação se encontra, que pode ser pendente (:pending), completa (:complete) ou incompleta (:incomplete)
  - :amount - O valor da transação (decimal)
  - :account_id - O id da conta a qual a transação pertence (date)
  - :recipient_id - O id da conta que receberá a transação (date)
  """

  alias SimpleBank.{Transaction, Repo, Error}

  @type transaction_params :: %{
    id: binary(),
    type: :transfer | :deposit | :withdraw,
    status: :pending | :complete | :incomplete,
    amount: Decimal.t(),
    account_id: binary(),
    recipient_id: nil | binary()
  }

  @spec call(transaction_params()) ::
        {:error, Error.t()} | {:ok, Transaction.t()}
  def call(%{"id" => id} = params) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        transaction <- Repo.get(Transaction, uuid) do
      transaction
      |> Transaction.changeset(params)
      |> Repo.update()
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      {:error, result} -> {:error, Error.build(:bad_request, result)}
      nil -> {:error, Error.build(:not_found, "Transaction is not found!")}
    end
  end

  @doc """
  Esta função e ativada quando o usuário envia um argumento envalido
  """
  def call(_anything), do: {:error, Error.build(:bad_request, "ID not provided!")}
end
