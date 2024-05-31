defmodule SimpleBankWeb.TransactionController do
  use SimpleBankWeb, :controller
  use PhoenixSwagger

  alias SimpleBankWeb.FallbackController
  alias SimpleBank.Transaction

  action_fallback FallbackController

  def swagger_definitions do
    %{
      TransactionRequest:
        swagger_schema do
          title "Transaction Request"
          description "POST body for cratong a transaction"
          type :object

          properties do
            type :string, "Type", required: true, enum: ["transfer", "deposit", "withdraw"]
            amount :string, "Amount", format: "decimal", required: true
            account_number :integer, "Account Number", required: true
            recipient_number :integer, "Recipient Number", required: false
          end
        end,
      TransactionResponse:
        swagger_schema do
          title "Transaction Response"
          description "Response schema for a single transaction"
          type :object

          properties do
            id :string, "Transaction ID", format: "binary", required: true
            number :ineger, "Number", required: true
            amount :string, "Amount", required: true
            type :string, "Type", required: true
            status :string, "Status", required: true
            account(Schema.ref(:TransactionAccount), "Transaction Account", required: true)
            recipient(Schema.ref(:TransactionAccount), "Transaction Account Received", required: true)
            inserted_at :string, "Insertion date", format: "date_time"
            updated_at :string, "Update date", format: "date-time"
          end
        end,
      TransactionAccount:
        swagger_schema do
          title "Transaction Account"
          description "Account scheme that is returned along with the transactions"
          type :object

          properties do
            id :string, "Account ID", format: "binary", required: true
            number :integer, "Account Number", required: true
            type :string, "Account Type", required: true
            user(Schema.ref(:TransactionAccountUser), "Account User", required: true)
          end
        end,
      TransactionAccountUser:
        swagger_schema do
          title "Transaction Account Schema"
          description "User schema returned along with accounts in transaction queries"
          type :object

          properties do
            id :string, "User ID", required: true
            first_name :string, "User First Name", required: true
            last_name :string, "User Last Name", required: true
            cpf :string, "User CPF", required: true
          end
        end
    }
  end

  swagger_path :create do
    post "/api/transactions"
    summary "Creaye a new transaction"
    description "Creates a new transaction in the database"
    produces "application/json"
    tag "Transactions"
    consumes "application/json"

    parameter :transaction, :body, Schema.ref(:TransactionRequest), "Transaction data", required: true

    response 200, "OK", Schema.ref(:TransactionResponse)
    response 400, "Bad Request"
    response 500, "Internal Server Error"
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

    with {:ok, %Transaction{} = transaction} <- SimpleBank.create_transaction(params) do
      conn
      |> put_status(:created)
      |> render("transaction.json", transaction: transaction)
    end
  end

  swagger_path :show do
    get "/api/transactions/{id}"
    summary "Get a transaction by ID"
    description "Get a specified transaction by their ID"
    produces "application/json"
    tag "Transactions"
    parameter :id, :path, :binary, "Transaction ID", required: true
    response 200, "OK", Schema.ref(:TransactionResponse)
    response 400, "Bad Request"
    response 404, "Not Found"
  end
  def show(conn, %{"id" => id}) do
    with {:ok, %Transaction{} = transaction} <- SimpleBank.get_transaction_by_id(id) do
      conn
      |> put_status(:ok)
      |> render("transaction.json", transaction: transaction)
    end
  end
end
