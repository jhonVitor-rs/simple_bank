defmodule SimpleBank.Transaction.CreateTest do
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

  @user_3_params %{
    first_name: "Steve",
    last_name: "Rogers",
    cpf: "10101028456",
    birth: ~D[2000-07-08],
    address: "Rua C, 789",
    cep: "80000000"
  }

  describe "call/1" do
    setup do
      {:ok, %User{} = john} = User.Create.call(@user_1_params)
      {:ok, %User{} = antony} = User.Create.call(@user_2_params)
      {:ok, %User{} = steve} = User.Create.call(@user_3_params)

      {:ok, %Account{} = chain_john} = Account.Create.call(%{type: :chain, user_id: john.id, balance: 50})
      {:ok, %Account{} = savings_john} = Account.Create.call(%{type: :savings, user_id: john.id, balance: 50})

      {:ok, %Account{} = savings_antony} = Account.Create.call(%{type: :savings, user_id: antony.id, balance: 50})
      {:ok, %Account{} = wage_antony} = Account.Create.call(%{type: :wage, user_id: antony.id, balance: 50})

      {:ok, %Account{} = chain_steve} = Account.Create.call(%{type: :chain, user_id: steve.id, balance: 50})
      {:ok, %Account{} = savings_steve} = Account.Create.call(%{type: :savings, user_id: steve.id, balance: 50})

      %{chain_john: chain_john, savings_john: savings_john,
        savings_antony: savings_antony, wage_antony: wage_antony,
        chain_steve: chain_steve, savings_steve: savings_steve}
    end

    # Este resultado será padrão para qualquer tentativa de transação com o numero da conta de origem invalido
    test "returns :error for transactions with invalid account",
    %{chain_steve: chain_steve} do
      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("10"),
        account_number: 015876943,
        recipient_number: chain_steve.number
      })
    end

    # Transfers
    test "returns :ok for transfers made from a current account",
    %{chain_john: chain_john, chain_steve: chain_steve,
    savings_antony: savings_antony, wage_antony: wage_antony} do
      assert {:ok, %Transaction{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("10"),
        account_number: chain_john.number,
        recipient_number: chain_steve.number
      })

      assert {:ok, %Transaction{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("10"),
        account_number: chain_john.number,
        recipient_number: savings_antony.number
      })

      assert {:ok, %Transaction{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("10"),
        account_number: chain_john.number,
        recipient_number: wage_antony.number
      })
    end

    test "returns :error for transfers without balance",
    %{chain_john: chain_john, chain_steve: chain_steve} do
      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("60"),
        account_number: chain_john.number,
        recipient_number: chain_steve.number
      })
    end

    test "returns :error for transfers with invalid recipient",
    %{chain_john: chain_john} do
      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("60"),
        account_number: chain_john.number,
        recipient_number: 054648469
      })
    end

    test "returns :error for transfers with negative value",
    %{chain_john: chain_john, chain_steve: chain_steve} do
      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("-20"),
        account_number: chain_john.number,
        recipient_number: chain_steve.number
      })
    end

    test "returns :error for transfers made from a salary or savings account",
    %{chain_john: chain_john, savings_antony: savings_antony, wage_antony: wage_antony} do
      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("50"),
        account_number: savings_antony.number,
        recipient_number: chain_john.number
      })

      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("20"),
        account_number: wage_antony.number,
        recipient_number: chain_john.number
      })
    end

    # Deposits
    # Transações de deposito não e necessaro o campo recipient_number,
    # e possivel envia-lo mas a função não ira utiliza-lo
    test "returns :ok for deposits into current and savings accounts",
    %{chain_john: chain_john, savings_antony: savings_antony} do
      assert {:ok, %Transaction{}} = Transaction.Create.call(%{
        type: :deposit,
        amount: Decimal.new("50"),
        account_number: chain_john.number
      })
      assert {:ok, %Transaction{}} = Transaction.Create.call(%{
        type: :deposit,
        amount: Decimal.new("50"),
        account_number: savings_antony.number
      })
    end

    test "returns :error for deposits into salary account",
    %{wage_antony: wage_antony} do
      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :deposit,
        amount: Decimal.new("50"),
        account_number: wage_antony.number
      })
    end

    # Withdraw
    # Transações de saque não e necessaro o campo recipient_number,
    # e possivel envia-lo mas a função não ira utiliza-lo
    test "return :ok for withdrawals from any account",
    %{chain_john: chain_john, savings_antony: savings_antony, wage_antony: wage_antony} do
      assert {:ok, %Transaction{}} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("10"),
        account_number: chain_john.number
      })

      assert {:ok, %Transaction{}} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("10"),
        account_number: savings_antony.number
      })

      assert {:ok, %Transaction{}} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("10"),
        account_number: wage_antony.number
      })
    end

    test "return :error for withdrawals from any account without a balance",
    %{chain_john: chain_john, savings_antony: savings_antony, wage_antony: wage_antony} do
      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("60"),
        account_number: chain_john.number
      })

      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("60"),
        account_number: savings_antony.number
      })

      assert {:error, %Error{}} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("60"),
        account_number: wage_antony.number
      })
    end
  end
end
