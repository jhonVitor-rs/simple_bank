defmodule SimpleBankWeb.TransactionController do
  use SimpleBankWeb, :controller

  alias SimpleBank.Transactions.Services.GetAllTransactions
  alias SimpleBank.Transactions.Hooks.CreateTransactions

  def index(conn, _params) do
    GetAllTransactions.list_transactions()
    |> handle_response(conn)
  end

  def create(conn, params) do
    CreateTransactions.create_transaction(params)
    |> handle_response(conn)
  end

  defp handle_response({:ok, data}, conn) do
    conn
    |> put_status(:ok)
    |> render("success.json", data: data)
  end

  defp handle_response({:error, message, cause}, conn) do
    conn
    |> put_status(:bad_request)
    |> render("error.json", message: message, cause: cause)
  end
end
