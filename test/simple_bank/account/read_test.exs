defmodule SimpleBank.Account.ReadTest do
  use SimpleBank.DataCase, async: true
  alias SimpleBank.{Account, User, Error}

  @user_params %{
    first_name: "John",
    last_name: "Doe",
    cpf: "12345678900",
    birth: ~D[2000-01-01],
    address: "Rua A, 123",
    cep: "80000000"
  }

  setup do
    {:ok, %User{} = user} = User.Create.call(@user_params)
    %{user: user}
  end

  describe "get_all/0" do
    test "return all accounts", %{user: user} do
      {:ok, %Account{}} = Account.Create.call(%{type: :chain, user_id: user.id})

      assert {:ok, _accounts} = Account.Read.get_all()
    end

    test "return error when accounts table is empty" do
      assert {:error, %Error{}} = Account.Read.get_all()
    end
  end

  describe "get_by_type/1" do
    test "return all accounts by type", %{user: user} do
      {:ok, %Account{}} = Account.Create.call(%{type: :chain, user_id: user.id})

      assert {:ok, _accounts} = Account.Read.get_by_type(:chain)
    end

    test "returns an error not found if no account is found for the type" do
      assert {:error, %Error{}} = Account.Read.get_by_type(:chain)
    end
  end

  describe "get_by_user_id/1" do
    test "return all accounts by user_id", %{user: user}  do
      {:ok, %Account{}} = Account.Create.call(%{type: :chain, user_id: user.id})

      assert {:ok, _accounts} = Account.Read.get_by_user_id(user.id)
    end

    test "returns an error not found if no account is found for the user id", %{user: user}  do
      assert {:error, %Error{}} = Account.Read.get_by_user_id(user.id)
    end

    test "return an error to ID invalid" do
      assert {:error, %Error{}} = Account.Read.get_by_user_id("010101")
    end
  end

  describe "get_by_id/1" do
    test "returns the account corresponding to the id", %{user: user}  do
      {:ok, %Account{} = account} = Account.Create.call(%{type: :chain, user_id: user.id})

      assert {:ok, %Account{}} = Account.Read.get_by_id(account.id)
    end

    test "return an error not found if no account is found", %{user: user}  do
      assert {:error, %Error{}} = Account.Read.get_by_id(user.id)
    end

    test "returns an error to ID invalid" do
      assert {:error, %Error{}} = Account.Read.get_by_id("010101")
    end
  end

  describe "get_by_number/1" do
    test "returns the account corresponding to the number", %{user: user}  do
      {:ok, %Account{} = account} = Account.Create.call(%{type: :chain, user_id: user.id})

      assert {:ok, %Account{}} = Account.Read.get_by_number(account.number)
    end

    test "returns an error to not found account" do
      assert {:error, %Error{}} = Account.Read.get_by_number(0101010101)
    end
  end
end
