defmodule SimpleBankWeb.Router.Accounts.ReadTest do
  use SimpleBankWeb.ConnCase, async: true

  alias SimpleBank.{Account, User}

  @user_params %{
    "first_name" => "John",
    "last_name" => "Doe",
    "cpf" => "12345678900",
    "birth" => "2000-01-01",
    "address" => "Rua A, 123",
    "cep" => "80000000"
  }

  setup do
    {:ok, %User{} = user} = User.Create.call(@user_params)
    %{user: user}
  end

  describe "index/0" do
    test "returns accouts if they exists in the database", %{conn: conn, user: user} do
      Account.Create.call(%{type: :chain, user_id: user.id})

      conn = get(conn, "/api/accounts")
      accounts = json_response(conn, :ok)

      assert accounts["data"] != []
      assert Enum.any?(accounts["data"], fn account -> account["type"] == "chain" end)
    end

    test "returns :error if accounts are not exists", %{conn: conn} do
      conn = get(conn, "/api/accounts")
      accounts = json_response(conn, :not_found)

      assert accounts["message"] == "Accounts not found!"
    end
  end

  describe "get_by_type/1" do
    test "returns accounts corresponding to the search type", %{conn: conn, user: user} do
      Account.Create.call(%{type: :chain, user_id: user.id})

      conn = get(conn, "/api/accounts/type/chain")
      accounts = json_response(conn, :ok)

      assert accounts["data"] != []
      assert Enum.any?(accounts["data"], fn account -> account["type"] == "chain" end)
    end

    test "returns not found if it does not find any account matching the search", %{conn: conn} do
      conn = get(conn, "/api/accounts/type/chain")
      accounts = json_response(conn, :not_found)

      assert accounts["message"] == "Accounts not found!"
    end
  end

  describe "get_by_user_id/1" do
    test "returns accounts belonging to a specific user", %{conn: conn, user: user} do
      Account.Create.call(%{type: :chain, user_id: user.id})

      conn = get(conn, "/api/accounts/user_id/#{user.id}")
      accounts = json_response(conn, :ok)

      assert accounts["data"] != []
    end

    test "returns not found if it does not find any account matching the search", %{conn: conn, user: user} do
      conn = get(conn, "/api/accounts/user_id/#{user.id}")
      accounts = json_response(conn, :not_found)

      assert accounts["message"] == "Accounts not found!"
    end

    test "retudn bad request if to invite id invalid", %{conn: conn} do
      conn = get(conn, "/api/accounts/user_id/010101")
      accounts = json_response(conn, :bad_request)

      assert accounts["message"] == "ID must be a valid UUID!"
    end
  end

  describe "get_by_id/1" do
    test "returns the account that matches the passed id", %{conn: conn, user: user} do
      {:ok, %Account{} = a} = Account.Create.call(%{type: :chain, user_id: user.id})

      conn = get(conn, "/api/accounts/#{a.id}")
      account = json_response(conn, :ok)

      assert account["id"] == a.id
    end

    test "returns :not_found if the account is not found", %{conn: conn} do
      non_exists_id = Ecto.UUID.generate()

      conn = get(conn, "/api/accounts/#{non_exists_id}")
      account = json_response(conn, :not_found)

      assert account["message"] == "Account is not found!"
    end

    test "returns :bad_request if the id passed is invalid", %{conn: conn} do
      conn = get(conn, "/api/accounts/010101")
      account = json_response(conn, :bad_request)

      assert account["message"] == "ID must be a valid UUID!"
    end
  end

  describe "get_by_number/1" do
    test "returns the account that matches the passed number", %{conn: conn, user: user} do
      {:ok, %Account{} = a} = Account.Create.call(%{type: :chain, user_id: user.id})

      conn = get(conn, "/api/accounts/number/#{a.number}")
      account = json_response(conn, :ok)

      assert account["number"] == a.number
    end

    test "returns :not_found if the account is not found", %{conn: conn} do
      conn = get(conn, "/api/accounts/number/010101")
      account = json_response(conn, :not_found)

      assert account["message"] == "Account not found!"
    end
  end
end
