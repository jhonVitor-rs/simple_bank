defmodule SimpleBank.User.Read do
  alias SimpleBank.{User, Repo, Error}

  @spec get_all() ::
        {:error, Error.t()}
        | {:ok, list(User.t())}
  def get_all() do
    case Repo.all(User) do
      nil -> {:error, Error.build(:not_found, "Users is not found!")}
      users ->
        users_with_accounts = Repo.preload(users, :accounts)
        {:ok, users_with_accounts}
    end
  end

  @spec get_by_id(binary()) ::
        {:error, Error.t()}
        | {:ok, User.t()}
  def get_by_id(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        user <- Repo.get(User, uuid) do
      user_with_accounts = Repo.preload(user, :accounts)
      {:ok, user_with_accounts}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "User is not found!")}
    end
  end
end
