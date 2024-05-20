defmodule SimpleBank.User.CreateTest do
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

  @invalid_params %{
    first_name: "Jo",
    last_name: "D",
    cpf: "123",
    birth: ~D[2000-01-01],
    address: "Rua A, 123",
    cep: "80000000"
  }

  describe "call/1" do
    test "returns :ok when valid params are passed" do
      assert {:ok, %User{}} = User.Create.call(@valid_params)
    end

    test "returns :error when a user with the same cpf is inserted" do
      User.Create.call(@valid_params)
      assert {:error, %Error{}} = User.Create.call(@valid_params)
    end

    test "returns :error when invalid params are passed" do
      assert {:error, %Error{}} = User.Create.call(@invalid_params)
    end

    test "returns :error when argument is not a map" do
      assert {:error, %Error{}} = User.Create.call("invalid")
    end
  end
end
