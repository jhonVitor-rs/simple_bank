defmodule SimpleBank.Account.Create do
  alias SimpleBank.{Account, Repo, Error}

  @type account_params :: %{
    type: :chain | :savings | :wage,
    user_id: binary()
  }

  @spec call(account_params()) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def call(%{} = params) do
    number = create_account_number(params[:type])
    params_with_number = Map.put(params, :number, number)

    case Repo.get(Account, number) do
      nil -> with changeset <- Account.changeset(params_with_number),
        {:ok, %Account{}} = account <- Repo.insert(changeset) do
          account
        else
          {:error, %Error{}} = error -> error
          {:error, result} -> {:error, Error.build(:bad_request, result)}
      end
      _account -> call(params)
    end
  end

  def call(_anything), do: {:error, "Enter the data in a map format"}

  defp create_account_number(type) do
    prefix = case type do
      :chain -> "00"
      :savings -> "01"
      :wage -> "02"
      _ -> "00"
    end

    random_numbers = for _ <- 1..10, do: Integer.to_string(:rand.uniform(9))
    account_number = prefix <> Enum.join(random_numbers, "")

    account_number
  end
end
