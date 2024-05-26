defmodule SimpleBankWeb.Router.Accounts.DeleteTest do
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

    test "return success :no_content if the account is deleted", %{conn: conn, account: account} do
      conn = delete(conn, "/api/accounts/#{account.id}")
      account = json_response(conn, :no_content)

      assert account["message"] == "Account deleted with success!"
    end

    test "returns error if the account cannot be found", %{conn: conn} do
      non_exists_id = Ecto.UUID.generate()

      conn = delete(conn, "/api/accounts/#{non_exists_id}")
      account = json_response(conn, :not_found)

      assert account["message"] == "Account is not found!"
    end

    test "returns :error for id invalid", %{conn: conn} do
      conn = delete(conn, "/api/accounts/010101")
      account = json_response(conn, :bad_request)

      assert account["message"] == "ID must be a valid UUID!"
    end
  end
end
