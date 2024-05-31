defmodule SimpleBankWeb.AccountController do
  use SimpleBankWeb, :controller
  use PhoenixSwagger

  alias SimpleBankWeb.FallbackController
  alias SimpleBank.Account

  action_fallback FallbackController

  def swagger_definitions do
    %{
      AccountRequest:
        swagger_schema do
          title "Account Request"
          description "POST body for creating a account"
          type :object

          properties do
            type :string, "Type", required: true, enum: ["chain", "wage", "saving"]
            user_id :string, "User ID", required: true
            balance :string, "Balance", format: "decimal", required: false
          end
        end,
      AccountResponse:
        swagger_schema do
          title "Account Response"
          description "Response schema for a single account"
          type :object

          properties do
            id :string, "Account ID", format: "binary", required: true
            number :integer, "Number", required: true
            balance :string, "Balance", format: "decimal", required: true
            type :string, "Type", required: true
            user(Schema.ref(:AccountUser), "User", required: true)
            transactions_sent(:array, "Transactions Sent", items: Schema.array(:AccountTransactions))
            transactions_received(:array, "Transactions Received", items: Schema.array(:AccountTransactions))
            inserted_at :string, "Insertion date", format: "date_time"
            updated_at :string, "Update date", format: "date-time"
          end
        end,
      AccountTransactions:
        swagger_schema do
          title "Account Transactions"
          description "Transaction scheme that is returned along with the accounts"
          type :object

          properties do
            id :string, "Account ID", format: "binary", required: true
            number :integer, "Number", required: true
            amount :string, "Amount", format: "decimal", required: true
            type :string, "Type", required: true
            status :string, "Status", required: true
            inserted_at :string, "Insertion date", format: "date_time"
            updated_at :string, "Update date", format: "date-time"
          end
        end,
      AccountsResponse:
        swagger_schema do
          title "Accounts Response"
          description "Response schema for a many account"
          type :object

          properties do
            id :string, "Account ID", format: "binary", required: true
            number :integer, "Number", required: true
            type :string, "Type", required: true
            user(Schema.ref(:AccountUser), "User", required: true)
          end
        end,
      AccountUser:
        swagger_schema do
          title "Account User"
          description "User schema that is returned along with the account search"
          type :object

          properties do
            id :string, "User ID", format: "binary", required: true
            first_name :string, "Fist Name", required: true
            last_name :string, "Last Name", required: true
            cpf :string, "CPF", required: true
          end
        end,
    }
  end

  swagger_path :index do
    get "/api/accounts"
    summary "List all accounts"
    description "List all accounts in the database"
    produces "application/json"
    tag "Accounts"
    response 200, "OK", Schema.array(:AccountsResponse)
    response 404, "Not Found"
  end
  def index(conn, _params) do
    with {:ok, accounts} <- SimpleBank.get_accounts() do
      conn
      |> put_status(:ok)
      |> render("all_accounts.json", accounts: accounts)
    end
  end

  swagger_path :show do
    get "/api/accounts/{id}"
    summary "Get a account by ID"
    description "Get a specified account by their ID"
    produces "application/json"
    tag "Accounts"
    parameter :id, :path, :string, "Account ID", required: true
    response 200, "OK", Schema.ref(:AccountResponse)
    response 400, "Bad Request"
    response 404, "Not Found"
  end
  def show(conn, %{"id" => id}) do
    with {:ok, %Account{} = account} <- SimpleBank.get_account_by_id(id) do
      conn
      |> put_status(:ok)
      |> render("account.json", account: account)
    end
  end

  swagger_path :show_by_type do
    get "/api/accounts/type/{type}"
    summary "Get accounts by type"
    description "Get all accounts by a specified type"
    produces "application/json"
    tag "Accounts"
    parameter :type, :path, :string, "Account Type", required: true
    response 200, "OK", Schema.array(:AccountsResponse)
    response 404, "Not Found"
  end
  def show_by_type(conn, %{"type" => type}) do
    type_atom = String.to_existing_atom(type)

    with {:ok, accounts} <- SimpleBank.get_accounts_by_type(type_atom) do
      conn
      |> put_status(:ok)
      |> render("all_accounts.json", accounts: accounts)
    end
  end

  swagger_path :show_by_number do
    get "/api/accounts/number/{number}"
    summary "Get a account by Number"
    description "Get a specified account by their Number"
    produces "application/json"
    tag "Accounts"
    parameter :number, :path, :integer, "Account Number", required: true
    response 200, "OK", Schema.ref(:AccountResponse)
    response 400, "Bad Request"
    response 404, "Not Found"
  end
  def show_by_number(conn, %{"number" => number}) do
    with {:ok, %Account{} = account} <- SimpleBank.get_account_by_number(number) do
      conn
      |> put_status(:ok)
      |> render("account.json", account: account)
    end
  end

  swagger_path :show_by_user_id do
    get "/api/accounts/user_id/{user_id}"
    summary "Get accounts by user ID"
    description "Get all accounts by a specified user ID"
    produces "application/json"
    tag "Accounts"
    parameter :user_id, :path, :string, "User ID", required: true
    response 200, "OK", Schema.array(:AccountsResponse)
    response 400, "Bad Request"
    response 404, "Not Found"
  end
  def show_by_user_id(conn, %{"user_id" => user_id}) do
    with {:ok, accounts} <- SimpleBank.get_accounts_by_user_id(user_id) do
      conn
      |> put_status(:ok)
      |> render("all_accounts.json", accounts: accounts)
    end
  end

  swagger_path :create do
    post "/api/accounts"
    summary "Create a new account"
    description "Creates a new account in the database"
    produces "application/json"
    tag "Accounts"
    consumes "application/json"

    parameter :account, :body, Schema.ref(:AccountRequest), "Account data", required: true

    response 200, "OK", Schema.ref(:AccountResponse)
    response 400, "Bad Request"
  end
  def create(conn, params) do
    params =
      params
      |> Enum.map(fn {k, v} ->
        key = String.to_atom(k)
        value = if key == :type, do: String.to_existing_atom(v), else: v
        {key, value}
      end)
      |> Enum.into(%{})

    with {:ok, %Account{} = account} <- SimpleBank.create_account(params) do
      conn
      |> put_status(:created)
      |> render("account.json", account: account)
    end
  end

  swagger_path :update do
    put "/api/accounts/{id}"
    summary "Update a existing account"
    description "Update a existing account in the database"
    produces "application/json"
    tag "Accounts"
    consumes "application/json"

    parameters do
      id :path, :string, "Account ID", required: true

      account :body, Schema.ref(:AccountRequest), "Account data"
    end

    response 200, "OK", Schema.ref(:AccountResponse)
    response 400, "Bad Request"
    response 404, "Not Found"
  end
  def update(conn, params) do
    params =
      params
      |> Enum.map(fn {k, v} ->
        key = String.to_atom(k)
        value = if key == :type, do: String.to_existing_atom(v), else: v
        {key, value}
      end)
      |> Enum.into(%{})

    with {:ok, %Account{} = account} <- SimpleBank.update_account(params) do
      conn
      |> put_status(:ok)
      |> render("account.json", account: account)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/accounts/{id}"
    summary "Delete a account"
    description "Deletes an existing account from the system"
    produces "application/json"
    tag "Accounts"

    parameter :id, :path, :string, "Account ID", required: true

    response 204, "No Content"
    response 404, "Not Found"
  end
  def delete(conn, %{"id" => id}) do
    with {:ok, %Account{}} <- SimpleBank.delete_account(id) do
      conn
      |> put_status(:no_content)
      |> render("delete.json", message: "Account deleted with success!")
    end
  end
end
