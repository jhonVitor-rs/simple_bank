defmodule SimpleBankWeb.Router.User.CreateTest do
  use SimpleBankWeb.ConnCase, async: true

  alias SimpleBank.User

  @user_params %{
    "first_name" => "John",
    "last_name" => "Doe",
    "cpf" => "12345678900",
    "birth" => "2000-01-01",
    "address" => "Rua A, 123",
    "cep" => "80000000"
  }

  @invalid_params %{
    "first_name" => "John",
    "last_name" => "Doe",
    "cpf" => "12345678900",
  }

  describe "call/1" do
    test "returns the user if creation is successful", %{conn: conn} do
      conn = post(conn, "/api/users",@user_params)
      user = json_response(conn, :created)

      assert user["user"]["id"] != nil
      assert user["user"]["first_name"] == "John"
      assert user["user"]["last_name"] == "Doe"
      assert user["user"]["cpf"] == "12345678900"
    end

    test "returns :error if you try to register the same CPF twice", %{conn: conn} do
      User.Create.call(@user_params)

      conn = post(conn, "/api/users",@user_params)
      user = json_response(conn, :bad_request)

      assert user["message"] == %{"cpf" => ["has already been taken"]}
    end

    test "returns :error if invalid parameters are sent", %{conn: conn} do
      conn = post(conn, "/api/users", @invalid_params)
      user = json_response(conn, :bad_request)

      assert user["message"] == %{
        "birth" => ["can't be blank"],
        "address" => ["can't be blank"],
        "cep" => ["can't be blank"]
      }
    end
  end
end
