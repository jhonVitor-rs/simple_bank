defmodule SimpleBank.Repo.Migrations.CreateAccountType do
  use Ecto.Migration

  def change do
    up_query = "CREATE TYPE account_type AS ENUM ('chain', 'savings', 'wage')"

    down_query = "DROP TYPE account_type"

    execute(up_query)
  end
end
