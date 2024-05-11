defmodule SimpleBank.Account.Update do
  alias SimpleBank.{Account, Repo, Error}

  @spec call(%{id: binary()}) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def call(%{"id" => id} = params) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        account <- Repo.get(User, uuid) do
      account
      |> Account.changeset(params)
      |> Repo.update()
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      {:error, result} -> {:error, Error.build(:bad_request, result)}
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
    end
  end

  def call(_anything), do: {:error, Error.build(:bad_request, "ID not provided!")}
end
