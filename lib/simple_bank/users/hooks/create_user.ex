defmodule SimpleBank.Users.Hooks.CreateUser do
  alias SimpleBank.Users.Services.CreateUser

  @type user_attrs :: %{
    :firstName => String.t(),
    :lastName => String.t(),
    :document => String.t(),
    :email => String.t(),
    :password => String.t(),
    :balance => String.t(),
    :userType => String.t()
  }

  @spec create_user(user_attrs) ::
    {:ok, User.t()} | {:error, String.t(), Ecto.Changeset.t()}
  def create_user(%{
    "firstName" => first_name,
    "lastName" => last_name,
    "document" => document,
    "email" => email,
    "password" => password,
    "balance" => balance_str,
    "userType" => user_type
  }) do
    balance = String.to_float(balance_str)

    CreateUser.create_user(%{
      firstName: first_name,
      lastName: last_name,
      document: document,
      email: email,
      password: password,
      balance: balance,
      userType: user_type
    })
  end
end
