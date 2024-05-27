defmodule SimpleBank.Account.CreateTest do
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

  describe "call/1" do
    setup do
      {:ok, %User{} = user} = User.Create.call(@user_params)
      %{user: user}
    end

    test "returns :ok when valid params are passed", %{user: user} do
      account_params = %{type: :chain, user_id: user.id}
      account_params2 = %{type: :savings, user_id: user.id}

      assert {:ok, %Account{}} = Account.Create.call(account_params)
      assert {:ok, %Account{}} = Account.Create.call(account_params2)
    end

    test "returns error when trying to create an account of the same type that already exists", %{user: user} do
      account_chain_params = %{type: :chain, user_id: user.id}
      account_savings_params = %{type: :savings, user_id: user.id}
      account_wage_params = %{type: :wage, user_id: user.id}

      Account.Create.call(account_chain_params)
      Account.Create.call(account_savings_params)

      assert {:error, %Error{}} = Account.Create.call(account_savings_params)
      assert {:error, %Error{}} = Account.Create.call(account_wage_params)
      assert {:error, %Error{}} = Account.Create.call(account_chain_params)
    end

    test "returns :error when invalid params are passed" do
      account_params = %{type: :chain}

      assert {:error, %Error{}} = Account.Create.call(account_params)
    end

    test "returns :error when argument is not a map" do
      assert {:error, %Error{}} = Account.Create.call("invalid")
    end
  end
end
