defmodule SimpleBank.User.Delete do
  @moduledoc """
  Módulo User.Delete para deletar um usuário do banco de dados

  Este modulo define um serviço para deletar um usuário
  Fornece uma função que busca um usuário pelo ID e o excluir da tabela.
  """

  alias SimpleBank.{User, Repo, Error}

  @spec call(binary()) ::
        {:error, Ecto.Changeset.t()}
        | {:error, Error.t()}
        | {:ok, User.t()}
  def call(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        %User{} = user <- Repo.get(User, uuid) do
      Repo.delete(user)
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "User is not found!")}
    end
  end

end
