defmodule SimpleBank.Users.Services.UpdateUser do
  alias SimpleBank.Repo
  alias SimpleBank.Schemas.User

  @spec update_user(user :: User.t(), attrs :: %{optional(atom) => any}) ::
    {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        case Repo.update(changeset) do
          {:ok, updated_user} ->
            {:ok, updated_user}
          {:error, changeset} ->
            {:error, changeset.errors}
        end
      changeset ->
        {:error, changeset.errors}
    end
  end
end
