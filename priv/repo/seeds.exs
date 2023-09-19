alias SimpleBank.Schemas.User
alias SimpleBank.Schemas.Transaction

alias SimpleBank.Repo

{:ok, user1} = %User{}
|> User.changeset(%{
    firstName: "João",
    lastName: "Siben",
    document: "123456781",
    email: "joaosiben@example.com",
    password: "s3cr3tp@ssw0rd",
    balance: "100.0",
    userType: "common"
  })
|> Repo.insert

{:ok, user2} = %User{}
|> User.changeset(%{
    firstName: "Jhon",
    lastName: "Dhoe",
    document: "123456791",
    email: "jhondhoe@example.com",
    password: "s3cr3tp@ssw0rd",
    balance: "100.0",
    userType: "common"
  })
|> Repo.insert

%Transaction{}
|> Transaction.changeset(%{
    amount: "25.00",
    sender_id: user1.id,
    receiver_id: user2.id
  })
