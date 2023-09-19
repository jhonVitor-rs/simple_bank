defmodule SimpleBank.Transactions.Services.UpdateTransaction do
  alias SimpleBank.Repo
  alias SimpleBank.Schemas.Transaction

  @spec update_transaction(transaction :: Transaction.t(), attrs :: %{optional(atom) => any}) ::
    {:ok, Transaction.t()} | {:error, String.t(), Ecto.Changeset.t()}
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        case Repo.update(changeset) do
          {:ok, updated_transaction} ->
            {:ok, updated_transaction}
          {:error, changeset} ->
            {:error, "Failed to update transaction", changeset.errors}
        end
      changeset ->
        {:error, "Invalid changeset", changeset.errors}
    end
  end
end
