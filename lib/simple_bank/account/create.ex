defmodule SimpleBank.Account.Create do
  @moduledoc """
  Módulo Account.Create para criação de uma nova conta no SimpleBank

  Este módulo define um serviço de criação para a tabela de "accounts"
  fornecendo uma função que recebe como argumento os seguintes campos:
  - :type - O tipo especifico da conta que pode ser corrente (:chain), poupança (:saving) e salário (:wage)
  - :user_id - O ID que refeência o usuário a quem a conta pertence
  O módulo se encarrega de criar um número aleatório para a conta,
  cado a o número ja exista a função se chamara novamente para gerar um novo número
  """
  import Ecto.Query

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
      nil -> with :ok <- verify_account(params_with_number[:user_id], params_with_number[:type]),
        changeset <- Account.changeset(params_with_number),
        {:ok, %Account{}} = account <- Repo.insert(changeset) do
          account
        else
          {:error, %Error{}} = error -> error
          {:error, result} -> {:error, Error.build(:bad_request, result)}
        end
      _account -> call(params)
    end
  end

  @doc """
  Esta função e ativada quando o usuário envia um argumento invalido
  """
  def call(_anything), do: {:error, "Enter the data in a map format"}


  # Está é a função privada chamada para gerar um número aleatório para a conta
  defp create_account_number(type) do
    prefix = case type do
      :chain -> "00"
      :savings -> "06"
      :wage -> "12"
      _ -> "00"
    end

    random_numbers = for _ <- 1..10, do: Integer.to_string(:rand.uniform(9))
    account_number = prefix <> Enum.join(random_numbers, "")

    account_number
  end

  # Está função ira verificar se o usuário possui ou não uma conta do mesmo tipo que ele está tentando criar
  defp verify_account(user_id, type) do
    query = case type do
      :chain ->
        from a in Account,
        where: a.user_id == ^user_id and (a.type == :chain or a.type == :wage)
      :wage ->
        from a in Account,
        where: a.user_id == ^user_id and (a.type == :chain or a.type == :wage)
      :saving ->
        from a in Account,
        where: a.user_id == ^user_id and a.type == :saving
      _ ->
        from a in Account,
        where: a.user_id == ^user_id and a.type == ^type
    end

    case Repo.one(query) do
      nil -> :ok
      _account -> {:error, Error.build(:bad_request, "An account of this type or similar already exists!")}
    end
  end
end
