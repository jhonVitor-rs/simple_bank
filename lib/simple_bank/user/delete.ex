defmodule SimpleBank.User.Delete do
  alias SimpleBank.{User, Repo, Error}

  @spec call(binary()) ::
        {:error, %{result: String.t(), status: :not_found}}
        | {:error, Ecto.Changeset.t()}
        | {:ok, Ecto.Struct.t()}
  def call(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        user <- Repo.get(User, uuid) do
      %User{} = user -> Repo.delete(user)
    else

    end
  end
end
