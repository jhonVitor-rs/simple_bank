defmodule SimpleBank.Transaction.ReadTest do
  use SimpleBank.DataCase, async: true
  alias SimpleBank.{Account, Transaction, User, Error}

  @user_1_params %{
    first_name: "John",
    last_name: "Doe",
    cpf: "12345678900",
    birth: ~D[2000-01-01],
    address: "Rua A, 123",
    cep: "80000000"
  }

  @user_2_params %{
    first_name: "Antony",
    last_name: "Stark",
    cpf: "10987654321",
    birth: ~D[2000-03-04],
    address: "Rua B, 456",
    cep: "80000000"
  }

  describe "get_by_id/1" do
    setup do
      {:ok, %User{} = john} = User.Create.call(@user_1_params)
      {:ok, %User{} = antony} = User.Create.call(@user_2_params)

      {:ok, %Account{} = chain_john} = Account.Create.call(%{type: :chain, user_id: john.id, balance: 50})

      {:ok, %Account{} = savings_antony} = Account.Create.call(%{type: :savings, user_id: antony.id, balance: 50})

      %{chain_john: chain_john, savings_antony: savings_antony}
    end

    test "returns :ok if it finds the transaction",
    %{chain_john: chain_john, savings_antony: savings_antony} do
      {:ok, %Transaction{} = transfer} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("10"),
        account_number: chain_john.number,
        recipient_number: savings_antony.number
      })

      {:ok, %Transaction{} = deposit} = Transaction.Create.call(%{
        type: :deposit,
        amount: Decimal.new("50"),
        account_number: savings_antony.number
      })

      {:ok, %Transaction{} = withdraw} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("10"),
        account_number: chain_john.number
      })

      assert {:ok, %Transaction{}} = Transaction.Read.get_by_id(transfer.id)
      assert {:ok, %Transaction{}} = Transaction.Read.get_by_id(deposit.id)
      assert {:ok, %Transaction{}} = Transaction.Read.get_by_id(withdraw.id)
    end

    test "returns an :error if it does not find any transaction matching the id" do
      non_exitent_id = Ecto.UUID.generate()

      assert {:error, %Error{}} = Transaction.Read.get_by_id(non_exitent_id)
    end

    test "returns an :error if the id is invalid" do
      assert {:error, %Error{}} = Transaction.Read.get_by_id(nil)
    end
  end
end
