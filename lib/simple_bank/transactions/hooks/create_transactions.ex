defmodule SimpleBank.Transactions.Hooks.CreateTransactions do

  require Logger

  alias SimpleBank.Users.Services.GetUser
  alias SimpleBank.Users.Hooks.ValidateSender
  alias SimpleBank.Users.Hooks.UpdateBalance

  # alias SimpleBank.Transactions.Hooks.CheckAuthorization
  alias SimpleBank.Transactions.Services.CreateTransaction
  alias SimpleBank.Transactions.Services.UpdateTransaction

  @type transaction_attrs :: %{
    :amount => String.t(),
    :sender_id => String.t(),
    :receiver_id => String.t()
  }

  @spec create_transaction(transaction_attrs()) ::
    {:ok, Transaction.t()} | {:error, String.t(), Ecto.Changeset.t()}
  def create_transaction(%{
    "amount" => amount_str,
    "sender_id" => sender_id_str,
    "receiver_id" => receiver_id_str
  }) do
    sender_id = <<sender_id_str::binary>>
    receiver_id = <<receiver_id_str::binary>>
    amount = String.to_float(amount_str)

    with {:ok, sender} <- GetUser.get_user_by_id!(sender_id),
      {:ok, _sender} <- ValidateSender.validate_sender(sender, amount),
      {:ok, receiver} <- GetUser.get_user_by_id!(receiver_id),
      # {:ok, _authorization_response} <- CheckAuthorization.check_authorization,
      {:ok, transaction} <- CreateTransaction.create_transaction(%{sender_id: sender.id, receiver_id: receiver.id, amount: amount, status: "pending"}),
      {:ok, _sender, _receiver} <- UpdateBalance.update_balance(sender, receiver, amount),
      {:ok, new_transaction} <- UpdateTransaction.update_transaction(transaction, %{status: "completed"}) do
        {:ok, new_transaction}
      else
        {:error, message, cause} ->
          {:error, message, cause}
      end
  end
end
