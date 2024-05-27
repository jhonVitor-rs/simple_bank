defmodule SimpleBankWeb.Router.Transaction.ReadTest do
  use SimpleBankWeb.ConnCase, async: true

  alias SimpleBank.{Account, User, Transaction}

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

  describe "get_by_id/1" do
    setup do
      {:ok, %User{} = john} = User.Create.call(@user_1_params)
      {:ok, %User{} = antony} = User.Create.call(@user_2_params)

      {:ok, %Account{} = chain_john} = Account.Create.call(%{type: :chain, user_id: john.id, balance: 50})

      {:ok, %Account{} = savings_antony} = Account.Create.call(%{type: :savings, user_id: antony.id, balance: 50})

      %{chain_john: chain_john, savings_antony: savings_antony}
    end

    test "returns :ok it find the transaction",
    %{conn: conn, chain_john: chain_john, savings_antony: savings_antony} do
      {:ok, %Transaction{} = transfer} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("10"),
        account_number: chain_john.number,
        recipient_number: savings_antony.number
      })

      conn = get(conn, "/api/transactions/#{transfer.id}")
      transaction = json_response(conn, :ok)

      assert transaction["id"] == transfer.id
    end

    test "returns :bad_request to ID invalid", %{conn: conn} do
      conn = get(conn, "/api/transactions/010101")
      transaction = json_response(conn, :bad_request)

      assert transaction["message"] == "ID must be a valid UUID!"
    end

    test "returns :not_found if you can't find the transaction", %{conn: conn} do
      non_exists_id = Ecto.UUID.generate()

      conn = get(conn, "/api/transactions/#{non_exists_id}")
      transaction = json_response(conn, :not_found)

      assert transaction["message"] == "Transaction is not found!"
    end
  end
end
