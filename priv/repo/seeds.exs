defmodule SimpleBank.Seeds do
  # priv/repo/seeds.exs

  alias SimpleBank.{Account, Transaction, User, Repo, Error}

  def run do
    user1 = %{
      first_name: "John",
      last_name: "Doe",
      cpf: "11122233344",
      birth: ~D[2000-01-01],
      address: "Rua A, 123",
      cep: "80000000"
    }

    user2 = %{
      first_name: "Antony",
      last_name: "Stark",
      cpf: "55566677788",
      birth: ~D[2000-03-04],
      address: "Rua B, 456",
      cep: "80000000"
    }

    user3 = %{
      first_name: "Steve",
      last_name: "Rogers",
      cpf: "99988877766",
      birth: ~D[2000-07-08],
      address: "Rua C, 789",
      cep: "80000000"
    }

    {:ok, john} = create_or_find_users(user1)
    {:ok, antony} = create_or_find_users(user2)
    {:ok, steve} = create_or_find_users(user3)

    {:ok, %Account{} = chain_john} = create_or_find_accounts(%{type: :chain, user_id: john.id, balance: Decimal.new("50")})
    {:ok, %Account{} = _savings_john} = create_or_find_accounts(%{type: :savings, user_id: john.id, balance: Decimal.new("50")})

    {:ok, %Account{} = savings_antony} = create_or_find_accounts(%{type: :savings, user_id: antony.id, balance: Decimal.new("50")})
    {:ok, %Account{} = wage_antony} = create_or_find_accounts(%{type: :wage, user_id: antony.id, balance: Decimal.new("50")})

    {:ok, %Account{} = chain_steve} = create_or_find_accounts(%{type: :chain, user_id: steve.id, balance: Decimal.new("50")})
    {:ok, %Account{} = _savings_steve} = create_or_find_accounts(%{type: :savings, user_id: steve.id, balance: Decimal.new("50")})

    if chain_john.transactions_sent == [] do
      {:ok, _} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("10"),
        account_number: chain_john.number,
        recipient_number: chain_steve.number
      })

      {:ok, _} = Transaction.Create.call(%{
        type: :transfer,
        amount: Decimal.new("10"),
        account_number: chain_john.number,
        recipient_number: savings_antony.number
      })

      {:ok, _} = Transaction.Create.call(%{
        type: :deposit,
        amount: Decimal.new("50.00"),
        account_number: chain_john.number
      })

      {:ok, _} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("10.00"),
        account_number: chain_john.number
      })
    end

    if  savings_antony.transactions_sent == [] do
      {:ok, _} = Transaction.Create.call(%{
        type: :deposit,
        amount: Decimal.new("50.00"),
        account_number: savings_antony.number
      })

      {:ok, _} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("10.00"),
        account_number: savings_antony.number
      })
    end

    if wage_antony.transactions_sent == [] do
      {:ok, _} = Transaction.Create.call(%{
        type: :withdraw,
        amount: Decimal.new("10.00"),
        account_number: wage_antony.number
      })
    end

    IO.puts("Seeds ran successfully!")

  end

  defp create_or_find_users(%{} = params) do
    case Repo.get_by(User, cpf: params.cpf) do
      nil -> User.Create.call(params)
      user -> {:ok, user}
    end
  end

  defp create_or_find_accounts(%{} = params) do
    case Account.Read.get_by_user_id(params.user_id) do
      {:error, %Error{}} -> Account.Create.call(params)
      {:ok, accounts} ->
        existing_account = Enum.find(accounts, fn account ->
          account.type == params.type
        end)
        if existing_account do
          {:ok, existing_account}
        else
          Account.Create.call(params)
        end
    end
  end
end

SimpleBank.Seeds.run()
