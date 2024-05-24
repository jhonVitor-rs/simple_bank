defmodule SimpleBankWeb.Router.User.ReadTest do
  use SimpleBankWeb.ConnCase, async: true

  alias SimpleBank.User

  @user_params %{
    first_name: "John",
    last_name: "Doe",
    cpf: "12345678900",
    birth: ~D[2000-01-01],
    address: "Rua A, 123",
    cep: "80000000"
  }

  describe "index/0" do
    test "returns users if they exist in the database", %{conn: conn} do
      User.Create.call(@user_params)

      conn = get(conn, "/api/users")
      users = json_response(conn, :ok)

      assert users["data"] != []
      assert Enum.any?(users["data"], fn user -> user["first_name"] == "John" and user["last_name"] == "Doe" end)
    end

    test "returns :error if users are not found", %{conn: conn} do
      conn = get(conn, "/api/users")
      users = json_response(conn, :not_found)

      assert users["message"] == "Users not found!"
    end
  end

  describe "show/1" do
    test "returns the user that matches the passed id", %{conn: conn} do
      {:ok, %User{} = u} = User.Create.call(@user_params)

      conn = get(conn, "/api/users/#{u.id}")
      user = json_response(conn, :ok)

      assert user["user"]["id"] == u.id
      assert user["user"]["first_name"] == u.first_name
      assert user["user"]["last_name"] == u.last_name
      assert user["user"]["cpf"] == u.cpf
    end

    test "returns :not_found if the user is not found", %{conn: conn} do
      non_exists_id = Ecto.UUID.generate()

      conn = get(conn, "/api/users/#{non_exists_id}")
      user = json_response(conn, :not_found)

      assert user["message"] == "User is not found!"
    end

    test "returns :bad_request if the id passed is invalid", %{conn: conn} do
      conn = get(conn, "/api/users/020202")
      user = json_response(conn, :bad_request)

      assert user["message"] == "ID must be a valid UUID!"
    end
  end

  describe "show_by_name/1" do
    test "returns the user that matches the passed id", %{conn: conn} do
      User.Create.call(@user_params)

      conn = get(conn, "/api/users/name/john")
      users = json_response(conn, :ok)

      assert users["data"] != []
      assert Enum.any?(users["data"], fn user -> user["first_name"] == "John" and user["last_name"] == "Doe" end)
    end

    test "returns :error if users are not found", %{conn: conn} do
      conn = get(conn, "/api/users/name/jhon")
      users = json_response(conn, :not_found)

      assert users["message"] == "Users not found!"
    end
  end
end
