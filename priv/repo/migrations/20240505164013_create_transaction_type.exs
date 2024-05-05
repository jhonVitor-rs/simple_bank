defmodule SimpleBank.Repo.Migrations.CreateTransactionType do
  use Ecto.Migration

  def change do
    up_query = "CREATE TYPE transaction_type AS ENUM ('transfer', 'deposit', 'withdraw')"

    down_query = "DROP TYPE transaction_type"

    execute(up_query)
  end
end
