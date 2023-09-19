defmodule SimpleBank.Users.Hooks.UpdateBalance do
  alias SimpleBank.Users.Services.UpdateUser
  alias SimpleBank.Schemas.User

  @spec update_balance(User.t(), User.t(), float()) ::
    {:ok, User.t(), User.t()} | {:error, String.t(), Ecto.Changeset.t()}
  def update_balance(sender, receiver, change) when is_float(change) and change > 0.0 do
    {sender, receiver}
    |> update_sender_balance(change)
    |> update_receiver_balance(change)
  end

  defp update_sender_balance({sender, receiver}, change) do
    new_sender_balance = sender.balance - change

    case UpdateUser.update_user(sender, %{balance: new_sender_balance}) do
      {:ok, _sender} ->
        {sender, receiver}
      {:error, cause} ->
        {:error, "Failed to update sender balance", cause}
    end
  end

  defp update_receiver_balance({sender, receiver}, change) do
    new_receiver_balance = receiver.balance + change

    case UpdateUser.update_user(receiver, %{balance: new_receiver_balance}) do
      {:ok, _receiver} ->
        {:ok, sender, receiver}
      {:error, cause} ->
        # Se a atualização do receptor falhar, reverta a atualização do remetente.
        UpdateUser.update_user(sender, %{balance: (sender.balance + change)})
        {:error, "Failed to update receiver balance" ,cause}
    end
  end
end
