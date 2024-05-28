# priv/repo/seeds.exs

alias SimpleBank.{Repo, Account, Transaction, User}

user1 = %User{
  first_name: "John",
  last_name: "Doe",
  cpf: "11122233344",
  birth: ~D[2000-01-01],
  address: "Rua A, 123",
  cep: "80000000"
}

user2 = %User{
  first_name: "Antony",
  last_name: "Stark",
  cpf: "55566677788",
  birth: ~D[2000-03-04],
  address: "Rua B, 456",
  cep: "80000000"
}

user3 = %User{
  first_name: "Steve",
  last_name: "Rogers",
  cpf: "99988877766",
  birth: ~D[2000-07-08],
  address: "Rua C, 789",
  cep: "80000000"
}

{:ok, %User{} = john} = User.Create.call(user1)
{:ok, %User{} = antony} = User.Create.call(user2)
{:ok, %User{} = steve} = User.Create.call(user3)

{:ok, %Account{} = chain_john} = Account.Create.call(%{type: :chain, user_id: john.id, balance: Decimal.new("50")})
{:ok, %Account{} = savings_john} = Account.Create.call(%{type: :savings, user_id: john.id, balance: Decimal.new("50")})

{:ok, %Account{} = savings_antony} = Account.Create.call(%{type: :savings, user_id: antony.id, balance: Decimal.new("50")})
{:ok, %Account{} = wage_antony} = Account.Create.call(%{type: :wage, user_id: antony.id, balance: Decimal.new("50")})

{:ok, %Account{} = chain_steve} = Account.Create.call(%{type: :chain, user_id: steve.id, balance: Decimal.new("50")})
{:ok, %Account{} = savings_steve} = Account.Create.call(%{type: :savings, user_id: steve.id, balance: Decimal.new("50")})

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
  amount: Decimal.new("50"),
  account_number: chain_john.number
})

{:ok, _} = Transaction.Create.call(%{
  type: :deposit,
  amount: Decimal.new("50"),
  account_number: savings_antony.number
})

{:ok, _} = Transaction.Create.call(%{
  type: :withdraw,
  amount: Decimal.new("10"),
  account_number: chain_john.number
})

{:ok, _} = Transaction.Create.call(%{
  type: :withdraw,
  amount: Decimal.new("10"),
  account_number: savings_antony.number
})

{:ok, _} = Transaction.Create.call(%{
  type: :withdraw,
  amount: Decimal.new("10"),
  account_number: wage_antony.number
})

IO.puts("Seeds ran successfully!")
