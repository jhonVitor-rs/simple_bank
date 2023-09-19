defmodule SimpleBank.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :firstName, :string
      add :lastName, :string
      add :document, :string
      add :email, :string
      add :password, :string
      add :balance, :float
      add :userType, :string

      timestamps()
    end

    create unique_index(:users, [:document])
    create unique_index(:users, [:email])
  end
end
