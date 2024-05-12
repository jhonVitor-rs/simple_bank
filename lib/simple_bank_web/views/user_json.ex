defmodule SimpleBankWeb.UserJSON do
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
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      cpf: user.cpf,
      birth: user.birth,
      address: user.address,
      cep: user.cep,
      accounts: for(account <- user.accounts, do:
        %{
          id: account.id,
          number: account.number,
          balance: account.balance,
          type: account.type,
          inserted_at: account.inserted_at,
          updated_at: account.updated_at
        }
      ),
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  def render("error.json", %{result: result}) do
    ErrorJSON.error(result)
  end
end
