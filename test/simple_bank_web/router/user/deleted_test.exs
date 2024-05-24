defmodule SimpleBankWeb.Router.User.DeletedTest do
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

  describe "call/" do
    setup do
      {:ok, %User{} = user} = User.Create.call(@user_params)
      %{user: user}
    end

    test "returns success :no_content if the user is deleted", %{conn: conn, user: user} do
      conn = delete(conn, "/api/users/#{user.id}")
      user = json_response(conn, :no_content)

      assert user["message"] == "User deleted with success!"
    end

    test "returns error if the user cannot be found", %{conn: conn} do
      non_exists_id = Ecto.UUID.generate()

      conn = delete(conn, "/api/users/#{non_exists_id}")
      user = json_response(conn, :not_found)

      assert user["message"] == "User is not found!"
    end

    test "returns :error for id invalid", %{conn: conn} do
      conn = delete(conn, "/api/users/010101")
      user = json_response(conn, :bad_request)

      assert user["message"] == "ID must be a valid UUID!"
    end
  end
end
