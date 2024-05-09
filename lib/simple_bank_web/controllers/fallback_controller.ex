defmodule SimpleBankWeb.FallbackController do
  use SimpleBankWeb, :controller

  alias Ecto.Changeset
  alias SimpleBank.Error

  def call(conn, {:error, %Error{status: status, result: changeset_or_message}}) do
    conn
    |> put_status(status)
    |> render("error.json", result: changeset_or_message)
  end

  def call(conn, {:error, %Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> render("error.json", result: changeset)
  end
end
