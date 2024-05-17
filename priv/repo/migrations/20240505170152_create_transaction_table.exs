defmodule SimpleBank.Repo.Migrations.CreateTransactionTable do
  use Ecto.Migration

  def change do
    create table :transactions, primary_key: false do
      add :id, :binary_id, primary_key: true
      add :number, :integer
      add :amount, :decimal
      add :type, :transaction_type
      add :status, :transaction_status
      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all)
      add :recipient_id, references(:accounts, type: :binary_id)

      timestamps()
    end
  end
end
