defmodule SimpleBankWeb.Router.User.UpdateTest do
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

  @update_params %{
    first_name: "Tony",
    last_name: "Stark",
  }

  describe "call/1" do
    setup do
      {:ok, %User{} = user} = User.Create.call(@user_params)
      %{user: user}
    end

    test "returns the user if updated successfully", %{conn: conn, user: user} do
      conn = put(conn, "/api/users/#{user.id}", @update_params)
      user = json_response(conn, :ok)

      assert user["user"]["first_name"] == "Tony"
      assert user["user"]["last_name"] == "Stark"
    end

    test "returns :error if no corresponding user is found for the id", %{conn: conn} do
      non_exists_id = Ecto.UUID.generate()

      conn = put(conn, "/api/users/#{non_exists_id}", @update_params)
      user = json_response(conn, :not_found)

      assert user["message"] == "User is not found!"
    end

    test "returns :error if sending an invalid id", %{conn: conn} do
      conn = put(conn, "/api/users/#{010101}", @update_params)
      user = json_response(conn, :bad_request)

      assert user["message"] == "ID must be a valid UUID!"
    end
  end
end
