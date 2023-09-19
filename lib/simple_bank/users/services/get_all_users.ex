defmodule SimpleBank.Users.Services.GetAllUsers do
  import Ecto.Query, warn: false

  alias SimpleBank.Repo
  alias SimpleBank.Schemas.User

  def list_users do
    case Repo.all(
      from u in User,
      preload: [:sent_transactions, :received_transactions]
    ) do
      [] -> {:error, "No users found", "No apparent error!"}
      users -> {:ok, users}
    end
  end
end
