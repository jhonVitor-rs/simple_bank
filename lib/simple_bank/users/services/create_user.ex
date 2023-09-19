defmodule SimpleBank.Users.Services.CreateUser do
  alias SimpleBank.Repo
  alias SimpleBank.Schemas.User

  @type user_attrs :: %{
    :firstName => String.t(),
    :lastName => String.t(),
    :document => String.t(),
    :email => String.t(),
    :password => String.t(),
    :balance => float(),
    :userType => String.t()
  }

  @spec create_user(user_attrs) ::
    {:ok, User.t()} | {:error, String.t(), Ecto.Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        case create_user_in_memory(changeset) do
          {:ok, user} ->
            {:ok, user}
          {:error, changeset} ->
            {:error, "Failed to create user", changeset.errors}
        end
      changeset ->
        {:error, "Invalid changeset", changeset.errors}
    end
  end

  defp create_user_in_memory(changeset) do
    Repo.insert(changeset)
  end
end
