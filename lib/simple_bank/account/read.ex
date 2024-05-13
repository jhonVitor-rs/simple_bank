defmodule SimpleBank.Account.Read do
  @moduledoc """
  Módulo Account.Read para busca de Contas no banco de dados

  Este módulo executa uma busca no banco de dados para encontras as contas
  e utiliza a função preload para carregar as transações que cada conta possui.
  Possui tres funçoes para busa no banco de dados.
  """
  import Ecto.Query

  alias SimpleBank.{Account, Repo, Error}

  @doc """
  Função get_all que executa uma busca completa no banco de dados.
  Não espera nenhum argumento como parametro.
  Retorna todas as contas.
  A função retorna apenas os campos:
  - :id
  - :number
  - :type
  - user {
    - :first_name
    - :last_name
    - :cpf
  }
  """
  @spec get_all() ::
        {:error, Error.t()} | {:ok, list(Account.t())}
  def get_all() do
    query = create_query()

    case Repo.all(query) do
      nil -> {:error, Error.build(:not_found, "Accounts not found!")}
      accounts ->
        accaounts_with_transactions = Repo.preload(accounts, [:transaction_sent, :transaction_received])
        {:ok, accaounts_with_transactions}
    end
  end

  @doc """
  Função get_by_user_id que esecuta umas busca pelo campo user_id na tabela de contas
  Ela espera um ID do usuário como argumento.
  Retorna um array de contas que pertençam ao mesmo usuário
  A função retorna apenas os campos:
  - :id
  - :number
  - :type
  - user {
    - :first_name
    - :last_name
    - :cpf
  }
  """
  @spec get_by_user_id(binary()) ::
        {:error, Error.t()} | {:ok, list(Account.t())}
  def get_by_user_id(user_id) do
    with {:ok, uuid} <- Ecto.UUID.cast(user_id),
        query <- create_query(uuid),
        accounts <- Repo.all(query) do
      {:ok, accounts}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
    end
  end

  @doc """
  Função get_by_id que executa uma busca mais seleta pelo ID da conta
  Espera o id como parametro
  Retorna apenas um usuário correspondente ao ID
  """
  @spec get_by_id(binary()) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def get_by_id(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        account <- Repo.get(Account, uuid) do
      account_with_transactions = Repo.preload(account, [:user, :transaction_sent, :transaction_received])
      {:ok, account_with_transactions}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
    end
  end

  @spec get_by_number(integer()) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def get_by_number(number) do
    case Repo.get(Account, where: [number: number]) do
      nil -> {:error, Error.build(:not_found, "Account not found!")}
      account ->
        account_with_details = Repo.preload(account, [:user, :transaction_sent, :transaction_received])
        {:ok, account_with_details}
    end
  end

  # Função para criar a query com a busca pelo id do usuário
  defp create_query(uuid) do
    from a in Account,
      join: u in assoc(a, :user),
      where: u.id == ^uuid,
      select: %{
        id: a.id,
        number: a.number,
        type: a.type,
        user: %{
          first_name: u.first_name,
          last_name: u.last_name,
          cpf: u.cpf
        }
      },
      preload: [:user]
  end

  # Função para criar a query para busca
  defp create_query() do
    from a in Account,
      join: u in assoc(a, :user),
      select: %{
        id: a.id,
        number: a.number,
        type: a.type,
        user: %{
          first_name: u.first_name,
          last_name: u.last_name,
          cpf: u.cpf
        }
      },
      preload: [:user]
  end
end
