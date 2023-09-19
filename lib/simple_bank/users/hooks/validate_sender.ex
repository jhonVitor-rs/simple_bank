defmodule SimpleBank.Users.Hooks.ValidateSender do
  alias SimpleBank.Schemas.User

  @spec validate_sender(User.t(), float) ::
    {:ok, User.t()} | {:error, String.t(), String.t()}
  def validate_sender(sender, amount) when is_map(sender) and is_number(amount) do
    case {sender.userType == "common", amount > 0, sender.balance >= amount} do
      {false, _, _} ->
        {:error, "Sender must be of type 'common'", "Invalid sender type!"}

      {_, false, _} ->
        {:error, "Amount must be positive", "Transfer amount must be greater than 0!"}

      {_, _, false} ->
        {:error, "Insufficient balance", "Insufficient funds!"}

      {true, true, true} ->
        {:ok, sender}
    end
  end
end
