defmodule SimpleBank.Transactions.Services.CreateTransaction do
  alias SimpleBank.Repo
  alias SimpleBank.Schemas.Transaction

  @type transaction_attrs :: %{
    :status => String.t(),
    :amount => float(),
    :sender_id => binary(),
    :receiver_id => binary()
  }

  @spec create_transaction(transaction_attrs) ::
    {:ok, Transaction.t()} | {:error, String.t(), Ecto.Changeset.t()}
  def create_transaction(attrs) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        case create_transaction_in_memory(changeset) do
          {:ok, transaction} ->
            {:ok, transaction}
          {:error, changeset} ->
            {:error, "Failed to create transaction", changeset.errors}
        end
      changeset ->
        {:error, "Invalid changeset", changeset.errors}
    end
  end

  defp create_transaction_in_memory(changeset) do
    Repo.insert(changeset)
  end
end
