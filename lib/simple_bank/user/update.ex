defmodule SimpleBank.User.Update do
  alias SimpleBank.{User, Repo, Error}

  @spec call(%{id: binary()}) ::
        {:error, Struct.t(
          result: Ecto.Changeset.t() | String.t() | atom(),
          status: :bad_request
        )} | {:ok, User.t()}
  def call(%{"id" => id} = params) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        user <- Repo.get(User, uuid) do
      user
      |> Clothing.changeset(params)
      |> Repo.update()
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      {:error, result} -> {:error, Error.build(:bad_request, result)}
      nil -> {:error, Error.build(:not_found, "User is not found!")}
    end
  end

  def call(_anything), do: {:error, Error.build(:bad_request, "ID not provided!")}
end
