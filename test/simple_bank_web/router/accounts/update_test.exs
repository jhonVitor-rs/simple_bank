defmodule SimpleBankWeb.Router.Accounts.UpdateTest do
  use SimpleBankWeb.ConnCase, async: true

  alias SimpleBank.{Account, User}

  @user_params %{
    first_name: "John",
    last_name: "Doe",
    cpf: "12345678900",
    birth: ~D[2000-01-01],
    address: "Rua A, 123",
    cep: "80000000"
  }

  describe "call/1" do
    setup do
      {:ok, %User{} = user} = User.Create.call(@user_params)
      {:ok, %Account{} = account} = Account.Create.call(%{type: :chain, user_id: user.id})
      %{account: account}
    end

    test "returns the updated account if successful", %{conn: conn, account: account} do
      conn = put(conn, "/api/accounts/#{account.id}", %{"balance" => "10.00", "type" => "chain"})
      account = json_response(conn, :ok)

      assert account["balance"] == "10.00"
    end

    test "return :not_found If you cannot find an account corresponding to the ID sent", %{conn: conn} do
      non_exists_id = Ecto.UUID.generate()

      conn = put(conn, "/api/accounts/#{non_exists_id}", %{"balance" => "10.00", "type" => "chain"})
      account = json_response(conn, :not_found)

      assert account["message"] == "Account is not found!"
    end

    test "returns :bad_request if the ID is invalid", %{conn: conn} do
      conn = put(conn, "/api/accounts/010101",  %{"balance" => "10.00", "type" => "chain"})
      account = json_response(conn, :bad_request)

      assert account["message"] == "ID must be a valid UUID!"
    end
  end
end
