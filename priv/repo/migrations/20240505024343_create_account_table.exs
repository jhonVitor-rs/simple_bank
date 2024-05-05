defmodule SimpleBank.Repo.Migrations.CreateAccountTable do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :number, :int
      add :balance, :decimal
      add :type, :account_type
      add :user_id, references(:users, type: :binary_id)

      timestamps()
    end

    create unique_index(:accounts, [:number])
  end
end