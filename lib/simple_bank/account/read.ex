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
    query = from a in Account,
      preload: [:user]

    case Repo.all(query) do
      [] -> {:error, Error.build(:not_found, "Accounts not found!")}
      accounts -> {:ok, accounts}
    end
  end

  @doc """
  Função get_by_type que executa uma busca pelo tipo da conta no banco de dados.
  Ela espera o tipo da conta como parametro.
  Retorna todas as contas correspondentes a busca.
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
  @spec get_by_type(atom()) ::
        {:error, Error.t()} | {:ok, list(Account.t())}
  def get_by_type(type) do
    query = from a in Account,
        join: u in assoc(a, :user),
        where: a.type == ^type,
        preload: [user: u]

    case Repo.all(query) do
      [] -> {:error, Error.build(:not_found, "Account is not found!")}
      accounts -> {:ok, accounts}
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
    with {:ok, uuid} <- Ecto.UUID.cast(user_id) do
      query = from a in Account,
        join: u in assoc(a, :user),
        where: a.user_id == ^uuid,
        preload: [user: u]

      case Repo.all(query) do
        [] -> {:error, Error.build(:not_found, "Account is not found!")}
        accounts -> {:ok, accounts}
      end
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
    end
  end

  @doc """
  Função get_by_id que executa uma busca mais seleta pelo ID da conta
  Espera o id como parametro
  Retorna apenas uma conta correspondente ao ID
  """
  @spec get_by_id(binary()) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def get_by_id(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        account when not is_nil(account) <- Repo.get(Account, uuid) do
        account = Repo.preload(account, [:user, :transactions_sent, :transactions_received])
      {:ok, account}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
    end
  end

  @spec get_by_number(integer()) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def get_by_number(number) do
    case Repo.get_by(Account, number: number) do
      nil -> {:error, Error.build(:not_found, "Account not found!")}
      account ->
        account = Repo.preload(account, [:user, :transactions_sent, :transactions_received])
        {:ok, account}
    end
  end
end
