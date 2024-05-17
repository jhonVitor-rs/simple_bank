defmodule SimpleBank.Repo.Migrations.CreateUserTable do
  use Ecto.Migration

  def change do
    create table :users, primary_key: false do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :cpf, :string
      add :email, :string
      add :birth, :date
      add :address, :string
      add :cep, :string

      timestamps()
    end

    create unique_index(:users, [:cpf])
    create unique_index(:users, [:email])
  end
end
