defmodule SimpleBank.Transaction.Read do
  @moduledoc """
  Modulo Transaction.Read para busca de Transações no banco de dados

  Este modulo executa uma busca no banco de dados para encontrar determinada transação
  e utiliza a função preload para carregar as informações da conta de destino
  """

  alias SimpleBank.{Transaction, Repo, Error}

  @doc """
  Função get_by_id que executa uma busca seleta pelo ID da transação
  Espera um id como parametro
  Retorna apenas uma transação correspondente ao ID
  """
  @spec get_by_id(binary()) ::
        {:error, Error.t()} | {:ok, Transaction.t()}
  def get_by_id(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         transaction <- Repo.get(Transaction, uuid),
         true <- not is_nil(transaction) do
      transaction_with_details = Repo.preload(transaction, [account: :user, recipient: :user])
      {:ok, transaction_with_details}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      false -> {:error, Error.build(:not_found, "Transaction is not found!")}
    end
  end
end
