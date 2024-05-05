defmodule SimpleBank.Repo.Migrations.CreateTransactionTable do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :number, :int
      add :amount, :decimal
      add :type, :transaction_type
      add :status, :transaction_status
      add :account_id, references(:accounts, type: :binary_id)
      add :sender_id, references(:users, type: :binary_id)
      add :recipient_id, references(:user, type: :binary_id)

      timestamps()
    end
  end
end
