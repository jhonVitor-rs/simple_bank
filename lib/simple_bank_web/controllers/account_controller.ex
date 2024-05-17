defmodule SimpleBankWeb.AccountController do
  use SimpleBankWeb, :controller

  alias SimpleBankWeb.FallbackController
  alias SimpleBank.Account

  action_fallback FallbackController

  def index(conn, _params) do
    with {:ok, accounts} <- SimpleBank.get_accounts() do
      conn
      |> put_status(:ok)
      |> render("all_accounts.json", accounts: accounts)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %Account{} = account} <- SimpleBank.get_account_by_id(id) do
      conn
      |> put_status(:ok)
      |> render("account.json", account: account)
    end
  end

  def show_by_number(conn, %{"number" => number}) do
    with {:ok, %Account{} = account} <- SimpleBank.get_account_by_number(number) do
      conn
      |> put_status(:ok)
      |> render("account.json", account: account)
    end
  end

  def show_by_user_id(conn, %{"user_id" => user_id}) do
    with {:ok, accounts} <- SimpleBank.get_accounts_by_user_id(user_id) do
      conn
      |> put_status(:ok)
      |> render("all_accounts.json", accounts: accounts)
    end
  end

  def create(conn, params) do
    with {:ok, %Account{} = account} <- SimpleBank.create_account(params) do
      conn
      |> put_status(:created)
      |> render("account.json", account: account)
    end
  end

  def update(conn, params) do
    with {:ok, %Account{} = account} <- SimpleBank.update_account(params) do
      conn
      |> put_status(:updated)
      |> render("account.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Account{}} <- SimpleBank.delete_account(id) do
      conn
      |> put_status(:no_content)
      |> text("")
    end
  end
end