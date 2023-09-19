defmodule SimpleBank.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :float
      add :status, :string
      add :created_at, :naive_datetime
      add :sender_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :receiver_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:transactions, [:sender_id])
    create index(:transactions, [:receiver_id])
  end
end
