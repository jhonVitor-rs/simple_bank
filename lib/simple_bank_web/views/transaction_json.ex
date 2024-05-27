defmodule SimpleBankWeb.TransactionJSON do
  alias SimpleBankWeb.ErrorJSON

  alias SimpleBank.Transaction

  def render("transaction.json", %{transaction: %Transaction{} = transaction}) do
    recipient = if transaction.recipient do
      %{
        number: transaction.recipient.number,
        type: transaction.recipient.type,
        user: %{
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
      recipient: recipient,
      inserted_at: transaction.inserted_at,
      updated_at: transaction.updated_at
    }
  end

  def render("error.json", %{result: result}) do
    ErrorJSON.error(result)
  end
end
