defmodule SimpleBank.Transactions.Services.GetAllTransactions do
  import Ecto.Query, warn: false

  alias SimpleBank.Repo
  alias SimpleBank.Schemas.Transaction

  def list_transactions do
    case Repo.all(
      from t in Transaction,
      left_join: s in assoc(t, :sender),
      left_join: r in assoc(t, :receiver),
      select: %{id: t.id, amount: t.amount, status: t.status, created_at: t.created_at, senderName: s.firstName, senderDocument: s.document, receiverName: r.firstName, receiverDocument: r.document}
    ) do
      [] -> {:error, "No transactions found", "No apparent error!"}
      transactions -> {:ok, transactions}
    end
  end
end
