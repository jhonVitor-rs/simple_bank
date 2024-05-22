defmodule SimpleBank.Account.DeleteTest do
  use SimpleBank.DataCase, async: true
  alias SimpleBank.{Account, User, Error}

  @valid_params %{
    first_name: "John",
    last_name: "Doe",
    cpf: "12345678900",
    birth: ~D[2000-01-01],
    address: "Rua A, 123",
    cep: "80000000"
  }

  describe "call/1" do
    test "returns success when it was possible to delete the user" do
      {:ok, %User{} = user} = User.Create.call(@valid_params)
      {:ok, %Account{} = account} = Account.Create.call(%{type: :chain, user_id: user.id})

      assert {:ok, %Account{}} = Account.Delete.call(account.id)
    end

    test "returns error when an invalida id is passed or account not found" do
      non_existent_id = Ecto.UUID.generate()

      assert {:error, %Error{}} = Account.Delete.call(non_existent_id)
    end
  end
end
