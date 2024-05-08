defmodule SimpleBank.User.Delete do
  alias SimpleBank.{User, Repo, Error}

  @spec call(binary()) ::
        {:error, %{result: String.t(), status: :not_found}}
        | {:error, Ecto.Changeset.t()}
        | {:ok, Ecto.Struct.t()}
  def call(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        %User{} = user <- Repo.get(User, uuid) do
      Repo.delete(user)
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "User is not found!")}
    end
  end

  def call(_anything), do: {:error, Error.build(:bad_request, "ID not provided!")}
end
