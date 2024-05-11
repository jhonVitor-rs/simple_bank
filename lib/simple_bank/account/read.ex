defmodule SimpleBank.Account.Read do
  alias SimpleBank.{Account, Repo, Error}

  @spec get_all() ::
        {:error, Error.t()} | {:ok, list(Account.t())}
  def get_all() do
    case Repo.all(Account) do
      nil -> {:error, Error.build(:not_found, "Accounts not found!")}
      accounts ->
        accaounts_with_transactions = Repo.preload(accounts, [:transaction_sent, :transaction_received])
        {:ok, accaounts_with_transactions}
    end
  end

  @spec get_by_user_id(binary()) ::
        {:error, Error.t()} | {:ok, list(Account.t())}
  def get_by_user_id(user_id) do
    with {:ok, uuid} <- Ecto.UUID.cast(user_id),
        accounts <- Repo.all(Account, where: [user_id: uuid]) do
      accaounts_with_transactions = Repo.preload(accounts, [:transaction_sent, :transaction_received])
      {:ok, accaounts_with_transactions}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
    end
  end

  @spec get_by_id(binary()) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def get_by_id(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        account <- Repo.get(User, uuid) do
      account_with_transactions = Repo.preload(account, [:transaction_sent, :transaction_received])
      {:ok, account_with_transactions}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
    end
  end

  @spec get_by_number(integer()) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def get_by_number(number) do
    case Repo.get(Account, where: [number: number]) do
      nil -> {:error, Error.build(:not_found, "Account not found!")}
      account ->
        account_with_transactions = Repo.preload(account, [:transaction_sent, :transaction_received])
        {:ok, account_with_transactions}
    end
  end
end
