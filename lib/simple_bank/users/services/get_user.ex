defmodule SimpleBank.Users.Services.GetUser do
  import Ecto.Query, warn: false

  alias SimpleBank.Repo
  alias SimpleBank.Schemas.User

  @spec get_user_by_id!(binary()) ::
    {:ok, User.t()} | {:error, String.t(), String.t()}
  def get_user_by_id!(id) do
    case Repo.get(User, id) do
      nil -> {:error, "User not found", "No apparent error!"}
      user -> {:ok, user}
    end
  end

  def get_user_by_document!(document) do
    case Repo.get_by(User, document) do
      nil -> {:error, "User with document #{document} not found"}
      user -> {:ok, user}
    end
  end
end
