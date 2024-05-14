defmodule SimpleBank.Transaction.Read do
  @moduledoc """
  Modulo Transaction.Read para busca de Transações no banco de dados

  Este modulo executa uma busca no banco de dados para encontrar determinada transação
  e utiliza a função preload para carregar as informações da conta de destino
  """
  import Ecto.Query

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
        query <- create_query(uuid),
        transaction <- Repo.one(query) do
      {:ok, transaction}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "Transaction is not found!")}
    end
  end

  # Função para a criação da query de busca
  defp create_query(uuid) do
    from t in Transaction,
      left_join: r in assoc(t, :recipient),
      where: t.id == ^uuid,
      # select: %{
      #   id: t.id,
      #   number: t.number,
      #   type: t.type,
      #   status: t.status,
      #   amount: t.amount,
      #   recipient: if(is_nil(t.recipient), do: nil, else: %{
      #     number: t.recipient.number,
      #     type: t.recipient.type,
      #     user: %{
      #       first_name: t.recipient.user.first_name,
      #       last_name: t.recipient.user.last_name,
      #       cpf: t.recipient.user.cpf
      #     }
      #   }),
      #   created_at: t.created_at,
      #   updated_at: t.updated_at
      # },
      preload: [recipient: :user]
  end
end
