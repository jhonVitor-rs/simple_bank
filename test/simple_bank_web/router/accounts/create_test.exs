defmodule SimpleBankWeb.Router.Accounts.CreateTest do
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
      %{user: user}
    end

    test "return the account if creation is successful", %{conn: conn, user: user} do
      conn = post(conn, "/api/accounts", %{"type" => "chain", "user_id" => user.id})
      account = json_response(conn, :created)

      assert account["id"] != nil
      assert account["number"] != nil
    end

    test "returns :error if invalid parameters are sent", %{conn: conn} do
      conn = post(conn, "/api/accounts", %{"type" => "chain"})
      account = json_response(conn, :bad_request)

      assert account["message"] != nil
    end

    test "returns :error if the user already has an account of the same type",
    %{conn: conn, user: user} do
      Account.Create.call(%{type: :chain, user_id: user.id})

      conn = post(conn, "/api/accounts", %{"type" => "wage", "user_id" => user.id})
      account = json_response(conn, :bad_request)

      assert account["message"] == "An account of this type or similar already exists!"
    end
  end
end
