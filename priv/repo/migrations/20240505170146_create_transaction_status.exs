defmodule SimpleBank.Repo.Migrations.CreateTransactionStatus do
  use Ecto.Migration

  def change do
    up_query = "CREATE TYPE transaction_status AS ENUM ('pending', 'complete', 'incomplete')"

    dow_query = "DROP TYPE transaction_status"

    execute(up_query, dow_query)
  end
end
