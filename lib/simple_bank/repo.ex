defmodule SimpleBank.Repo do
  use Ecto.Repo,
    otp_app: :simple_bank,
    adapter: Ecto.Adapters.Postgres
end
