defmodule SimpleBank.Account.Delete do
  @moduledoc """
  Modulo Account.Delete para deletar uma conta do banco de dados

  Este modulo define um serviço para deletar uma conta
  Fornece uma função que busca um usuário pelo ID e o exclui da tabela
  """

  alias SimpleBank.{Account, Repo, Error}

  @spec call(binary()) ::
        {:error, Ecto.Changeset.t()}
        | {:error, Error.t()}
        | {:ok, Account.t()}
  def call(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        %Account{} = account <- Repo.get(Account, uuid) do
      Repo.delete(account)
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
    end
  end
end
