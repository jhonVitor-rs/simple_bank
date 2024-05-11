defmodule SimpleBankWeb.UserJSON do
  alias SimpleBank.User
  alias SimpleBankWeb.ErrorJSON

  def render("all_users.json", %{users: users}) do
    %{data: for(user <- users, do: %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      cpf: user.cpf,
      accounts: for(account <- user.accounts, do:
      %{number: account.number, type: account.type}
      )
    })}
  end

  def render("user.json", %{user: user}) do
    %{user: get_user_data(user)}
  end

  def render("error.json", %{result: result}) do
    ErrorJSON.error(result)
  end

  def get_user_data(%User{} = user) do

    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      cpf: user.cpf,
      birth: user.birth,
      address: user.address,
      cep: user.cep,
      # accounts
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
