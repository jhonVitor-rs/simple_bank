defmodule SimpleBankWeb.TransactionJSON do
  alias SimpleBankWeb.ErrorJSON

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      number: transaction.number,
      amount: transaction.amount,
      type: transaction.type,
      status: transaction.status,
      recipient: %{
        number: transaction.recipient.number,
        type: transaction.recipient.type,
        user: %{
          first_name: transaction.recipient.user.first_name,
          last_name: transaction.recipient.user.last_name,
          cpf: transaction.recipient.user.cpf
        }
      },
      inserted_at: transaction.inserted_at,
      updated_at: transaction.updated_at
    }
  end

  def render("error.json", %{result: result}) do
    ErrorJSON.error(result)
  end
end
