defmodule SimpleBank.User.UpdateTest do
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
    id: "skdjgflksdjgksjdgkl",
    first_name: "John",
    last_name: "Doe",
    cpf: "12345678900",
    birth: ~D[2000-01-01],
    address: "Rua A, 123",
    cep: "80000000"
  }

  @update_params %{
    first_name: "Jane",
    last_name: "Smith"
  }

  describe "call/1" do
    test "umpdates a user's fields successfully" do
      {:ok, %User{} = user} = User.Create.call(@valid_params)

      updated_user_params = Map.merge(@update_params, %{id: user.id})
      {:ok, %User{} = updated_user} = User.Update.call(updated_user_params)

      assert updated_user.first_name == "Jane"
      assert updated_user.last_name == "Smith"
    end

    test "returns :error when trying to updates a non-existent user" do
      assert {:error, %Error{}} = User.Update.call(@invalid_params)
    end

    test "returns :erro when id not provided" do
      assert {:error, %Error{}} = User.Update.call(@update_params)
    end
  end
end
