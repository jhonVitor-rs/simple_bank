defmodule SimpleBankWeb.Router.Transaction.CreateTest do
  use SimpleBankWeb.ConnCase, async: true
  alias SimpleBank.{Account, User}

  @user_1_params %{
    first_name: "John",
    last_name: "Doe",
    cpf: "12345678900",
    birth: ~D[2000-01-01],
    address: "Rua A, 123",
    cep: "80000000"
  }

  @user_2_params %{
    first_name: "Antony",
    last_name: "Stark",
    cpf: "10987654321",
    birth: ~D[2000-03-04],
    address: "Rua B, 456",
    cep: "80000000"
  }

  @user_3_params %{
    first_name: "Steve",
    last_name: "Rogers",
    cpf: "10101028456",
    birth: ~D[2000-07-08],
    address: "Rua C, 789",
    cep: "80000000"
  }

  describe "call/1" do
    setup do
      {:ok, %User{} = john} = User.Create.call(@user_1_params)
      {:ok, %User{} = antony} = User.Create.call(@user_2_params)
      {:ok, %User{} = steve} = User.Create.call(@user_3_params)

      {:ok, %Account{} = chain_john} = Account.Create.call(%{type: :chain, user_id: john.id, balance: 50})
      {:ok, %Account{} = savings_john} = Account.Create.call(%{type: :savings, user_id: john.id, balance: 50})

      {:ok, %Account{} = savings_antony} = Account.Create.call(%{type: :savings, user_id: antony.id, balance: 50})
      {:ok, %Account{} = wage_antony} = Account.Create.call(%{type: :wage, user_id: antony.id, balance: 50})

      {:ok, %Account{} = chain_steve} = Account.Create.call(%{type: :chain, user_id: steve.id, balance: 50})
      {:ok, %Account{} = savings_steve} = Account.Create.call(%{type: :savings, user_id: steve.id, balance: 50})

      %{chain_john: chain_john, savings_john: savings_john,
        savings_antony: savings_antony, wage_antony: wage_antony,
        chain_steve: chain_steve, savings_steve: savings_steve}
    end

    test "returns :error for transactions with invalid account",
    %{chain_steve: chain_steve, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "transfer",
        "amount" => "10.00",
        "account_number" => "015876943",
        "recipient_number" => chain_steve.number
      })
      transaction = json_response(conn, :not_found)

      assert transaction["message"] == "Account not found!"
    end

    test "returns :ok for transfers made from a current account",
    %{chain_john: chain_john, chain_steve: chain_steve, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "transfer",
        "amount" => "10.00",
        "account_number" => chain_john.number,
        "recipient_number" => chain_steve.number
      })
      transaction = json_response(conn, :created)

      assert transaction["id"] != nil
      assert transaction["number"] != nil
    end

    test "returns :error for transfers without balance",
    %{chain_john: chain_john, chain_steve: chain_steve, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "transfer",
        "amount" => "60.00",
        "account_number" => chain_john.number,
        "recipient_number" => chain_steve.number
      })
      transaction = json_response(conn, :bad_request)

      assert transaction["message"] == "Insufficient balance for the transaction!"
    end

    test "returns :error for transfers with invalid recipient",
    %{chain_john: chain_john, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "transfer",
        "amount" => "10.00",
        "account_number" => chain_john.number,
        "recipient_number" => 010101
      })
      transaction = json_response(conn, :not_found)

      assert transaction["message"] == "Account not found!"
    end

    test "returns :error for transfers with negative value",
    %{chain_john: chain_john, chain_steve: chain_steve, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "transfer",
        "amount" => "-20.00",
        "account_number" => chain_john.number,
        "recipient_number" => chain_steve.number
      })
      transaction = json_response(conn, :internal_server_error)

      # Changeset error
      assert transaction["message"] != nil
    end

    test "returns :error for transfers made from a salary or savings account",
    %{chain_john: chain_john, savings_antony: savings_antony, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "transfer",
        "amount" => "50.00",
        "account_number" => savings_antony.number,
        "recipient_number" => chain_john.number
      })
      transaction = json_response(conn, :bad_request)

      assert transaction["message"] == "Transaction not allowed for this account type"
    end

    test "returns :ok for deposits into current accounts",
    %{chain_john: chain_john, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "deposit",
        "amount" => "50.00",
        "account_number" => chain_john.number
      })
      transaction = json_response(conn, :created)

      assert transaction["id"] != nil
      assert transaction["number"] != nil
    end

    test "returns :error for deposits into salary account",
    %{wage_antony: wage_antony, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "deposit",
        "amount" => "50.00",
        "account_number" => wage_antony.number
      })
      transaction = json_response(conn, :bad_request)

      assert transaction["message"] == "Transaction not allowed for this account type"
    end

    test "return :ok for withdrawals from any account",
    %{wage_antony: wage_antony, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "withdraw",
        "amount" => "40.00",
        "account_number" => wage_antony.number
      })
      transaction = json_response(conn, :created)

      assert transaction["id"] != nil
      assert transaction["number"] != nil
    end

    test "return :error for withdrawals from any account without a balance",
    %{wage_antony: wage_antony, conn: conn} do
      conn = post(conn, "/api/transactions", %{
        "type" => "withdraw",
        "amount" => "60.00",
        "account_number" => wage_antony.number
      })
      transaction = json_response(conn, :bad_request)

      assert transaction["message"] == "Insufficient balance for the transaction!"
    end
  end
end
