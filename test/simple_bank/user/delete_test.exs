defmodule SimpleBank.User.DeleteTest do
  use SimpleBank.DataCase, async: true
  alias SimpleBank.{User, Error}

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
      assert {:ok, %User{}} = User.Delete.call(user.id)
    end

    test "returns error when an invalid id is passed or user not found" do
      assert {:error, %Error{}} = User.Delete.call("skjdhfjksdhfjk")
    end
  end
end
