defmodule SimpleBank.Account.UpdateTest do
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

  describe "call/0" do
    setup do
      {:ok, %User{} = user} = User.Create.call(@user_params)
      {:ok, %Account{} = account} = Account.Create.call(%{type: :chain, user_id: user.id})
      %{account: account}
    end

    test "updates a accounts fields successfully", %{account: account} do
      assert {:ok, %Account{} = updated_account} = Account.Update.call(%{"id" => account.id, "type" => :savings})
      assert updated_account.type == :savings
    end

    test "returns an :error when trying to updates a non-existent account" do
      non_existent_id = Ecto.UUID.generate()

      assert {:error, %Error{}} = Account.Update.call(%{"id" => non_existent_id, "type" => :savings})
    end

    test "returns :error when id not provided" do
      assert {:error, %Error{}} = Account.Update.call(%{"type" => :wage})
    end
  end
end
