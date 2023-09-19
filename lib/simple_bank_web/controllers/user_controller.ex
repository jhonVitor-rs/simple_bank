defmodule SimpleBankWeb.UserController do
  use SimpleBankWeb, :controller

  alias SimpleBank.Users.Services.GetAllUsers
  alias SimpleBank.Users.Hooks.CreateUser

  plug :action

  def index(conn, _params) do
    GetAllUsers.list_users()
    |> handle_response(conn)
  end

  def create(conn, params) do
    CreateUser.create_user(params)
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
