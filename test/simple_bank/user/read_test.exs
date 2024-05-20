defmodule SimpleBank.User.ReadTest do
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

  #
  describe "get_all/0" do
    test "returns :ok when there are users in the database" do
      User.Create.call(@valid_params)

      # users :: %{
      #   id: binary(),
      #   first_name: String.t(),
      #   last_name: String.t(),
      #   cpf: String.t(),
      #   accounts: [%{
      #     number: Integer,
      #     type: atom()
      #   }] | []
      # }
      assert {:ok, _users} = User.Read.get_all()
    end

    test "returns :error when not finding users in database" do
      assert {:error, %Error{}} = User.Read.get_all()
    end
  end

  describe "get_byName/1" do
    test "returns :ok when it finds the user that matches the search" do
      User.Create.call(@valid_params)

       # users :: %{
      #   id: binary(),
      #   first_name: String.t(),
      #   last_name: String.t(),
      #   cpf: String.t(),
      #   accounts: [%{
      #     number: Integer,
      #     type: atom()
      #   }] | []
      # }
      assert {:ok, _users} = User.Read.get_by_name("john")
    end

    test "returned an :error when no user matching the search was found" do
      assert {:error, %Error{}} = User.Read.get_by_name("jhon")
    end
  end

  describe "get_by_id/1" do
    test "returns :ok if it finds the user corresponding to the given id" do
      {:ok, user} = User.Create.call(@valid_params)
      assert {:ok, %User{}} = User.Read.get_by_id(user.id)
    end

    test "Returns an :error if the id is invalid or does not match any user" do
      assert {:error, %Error{}} = User.Read.get_by_id("0a0a0a0a")
    end
  end
end
