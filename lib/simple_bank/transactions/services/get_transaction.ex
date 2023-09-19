defmodule SimpleBank.Transactions.Services.GetTransaction do
  alias SimpleBank.Repo
  alias SimpleBank.Schemas.Transaction

  def get_transaction_by_id!(id) do
    case Repo.get(Transaction, id) do
      nil -> {:error, "Transaction not found!"}
      transaction -> {:ok, transaction}
    end
  end
end
