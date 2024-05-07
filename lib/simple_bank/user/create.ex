defmodule SimpleBank.User.Create do
  alias ElixirLS.LanguageServer.Plugins.Ecto
  alias SimpleBank.{User, Repo, Error}

  @type user_params :: %{
    first_name: String.t(),
    last_name: String.t(),
    cpf: String.t(),
    birth: Date.t(),
    address: String.t(),
    cep: String.t()
  }

  @spec call(user_params()) ::
        {:error, Struct.t(
          result: Ecto.Changeset.t() | String.t() | atom(),
          status: :bad_request
        )} | {:ok, User.t()}
  def call(%{} = params) do
    with changeset <- User.changeset(params),
        {:ok, %User{}} = user <- Repo.insert(changeset) do
      user
    else
      {:error, %Error{}} = error -> error
      {:error, result} -> {:error, Error.build(:bad_request, result)}
    end
  end

  def call(_anything), do: {:error, "Enter the data in a map format"}
end
