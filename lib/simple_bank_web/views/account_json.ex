defmodule SimpleBankWeb.AccountJSON do
  alias SimpleBankWeb.ErrorJSON

  alias SimpleBank.Account

  def render("all_accounts.json", %{accounts: accounts}) do
    %{data: for(account <- accounts, do: %{
      id: account.id,
      number: account.number,
      type: account.type,
      user: %{
        id: account.user.id,
        first_name: account.user.first_name,
        last_name: account.user.last_name,
        cpf: account.user.cpf
      }
    })}
  end

  def render("account.json", %{account: %Account{} = account}) do
    %{
      id: account.id,
      number: account.number,
      balance: account.balance,
      type: account.type,
      user: %{
        id: account.user.id,
        first_name: account.user.first_name,
        last_name: account.user.last_name,
        cpf: account.user.cpf
      },
      transactions_sent: for(ts <- account.transactions_sent, do: %{
        id: ts.id,
        number: ts.number,
        amount: ts.amount,
        type: ts.type,
        status: ts.status,
        inserted_at: ts.inserted_at,
        updated_at: ts.updated_at
      }),
      transaction_received: for(tr <- account.transactions_received, do: %{
        id: tr.id,
        number: tr.number,
        amount: tr.amount,
        type: tr.type,
        status: tr.status,
        inserted_at: tr.inserted_at,
        updated_at: tr.updated_at
      }),
      inserted_at: account.inserted_at,
      updated_at: account.updated_at
    }
  end

  def render("error.json", %{result: result}) do
    ErrorJSON.error(result)
  end

  def render("delete.json", %{message: message}) do
    %{message: message}
  end
end
