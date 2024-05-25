defmodule SimpleBankWeb.UserController do
  use SimpleBankWeb, :controller

  alias SimpleBankWeb.FallbackController
  alias SimpleBank.User

  action_fallback FallbackController

  def index(conn, _params) do
    with {:ok, users} <- SimpleBank.get_users() do
      conn
      |> put_status(:ok)
      |> render("all_users.json", users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- SimpleBank.get_user_by_id(id) do
      conn
      |> put_status(:ok)
      |> render("user.json", user: user)
    end
  end

  def show_by_name(conn, %{"user_name" => user_name}) do
    with {:ok, users} <- SimpleBank.get_user_by_name(user_name) do
      conn
      |> put_status(:ok)
      |> render("all_users.json", users: users)
    end
  end

  def create(conn, params) do
    params =
      params
      |> Enum.map(fn {k, v} ->
        key = String.to_atom(k)
        value = if key == :birth, do: Date.from_iso8601!(v), else: v
        {key, value}
      end)
      |> Enum.into(%{})

    with {:ok, %User{} = user} <- SimpleBank.create_user(params) do
      conn
      |> put_status(:created)
      |> render("user.json", user: user)
    end
  end

  def update(conn, params) do
    params =
      params
      |> Enum.map(fn {k, v} ->
        key = String.to_atom(k)
        value = if key == :birth, do: Date.from_iso8601!(v), else: v
        {key, value}
      end)
      |> Enum.into(%{})

    with {:ok, %User{} = user} <- SimpleBank.update_user(params) do
      conn
      |> put_status(:ok)
      |> render("user.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %User{}} <- SimpleBank.delete_user(id) do
      conn
      |> put_status(:no_content)
      |> render("delete.json", message: "User deleted with success!")
    end
  end
end
