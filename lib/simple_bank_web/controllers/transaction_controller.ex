defmodule SimpleBankWeb.TransactionController do
  use SimpleBankWeb, :controller

  alias SimpleBankWeb.FallbackController
  alias SimpleBank.Transaction

  action_fallback FallbackController


  def create(conn, params) do
    params =
      params
      |> Enum.map(fn {k, v} ->
        key = String.to_atom(k)
        value = if key == :type, do: String.to_existing_atom(v), else: v
        {key, value}
      end)
      |> Enum.into(%{})

    with {:ok, %Transaction{} = transaction} <- SimpleBank.create_transaction(params) do
      conn
      |> put_status(:created)
      |> render("transaction.json", transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %Transaction{} = transaction} <- SimpleBank.get_transaction_by_id(id) do
      conn
      |> put_status(:ok)
      |> render("transaction.json", transaction: transaction)
    end
  end
end
