defmodule SimpleBankWeb.TransactionJSON do
  alias SimpleBankWeb.ErrorJSON

  alias SimpleBank.Transaction

  def render("transaction.json", %{transaction: %Transaction{} = transaction}) do
    recipient = if transaction.recipient do
      %{
        id: transaction.recipient.id,
        number: transaction.recipient.number,
        type: transaction.recipient.type,
        user: %{
          id: transaction.recipient.user.id,
          first_name: transaction.recipient.user.first_name,
          last_name: transaction.recipient.user.last_name,
          cpf: transaction.recipient.user.cpf
        }
      }
    else
      nil
    end

    %{
      id: transaction.id,
      number: transaction.number,
      amount: transaction.amount,
      type: transaction.type,
      status: transaction.status,
      account: %{
        id: transaction.account.id,
        number: transaction.account.number,
        type: transaction.account.type,
        user: %{
          id: transaction.account.user.id,
          first_name: transaction.account.user.first_name,
          last_name: transaction.account.user.last_name,
          cpf: transaction.account.user.cpf
        }
      },
      recipient: recipient,
      inserted_at: transaction.inserted_at,
      updated_at: transaction.updated_at
    }
  end

  def render("error.json", %{result: result}) do
    ErrorJSON.error(result)
  end
end
