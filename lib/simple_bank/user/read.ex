defmodule SimpleBank.User.Read do
  @moduledoc """
  Modulo User.Read para busca de Usuários no banco de dados

  Este módulo executa uma busca no banco de dados para encontrar os usuários
  e utiliza a função preload para carregar as contas que o usuário possui.
  Possui tres funções para busca no banco de dados.
  """
  import Ecto.Query

  alias SimpleBank.{User, Repo, Error}

  @doc """
  Função get_all que executa uma busca completa no banco de dados.
  Não espera nenhum argumento como parametro.
  Retorna todos os usuários.
  """
  @spec get_all() ::
        {:error, Error.t()} | {:ok, list(User.t())}
  def get_all() do
    case Repo.all(User) do
      nil -> {:error, Error.build(:not_found, "Users is not found!")}
      users ->
        users_with_accounts = Repo.preload(users, :accounts)
        {:ok, users_with_accounts}
    end
  end

  @doc """
  Função get_by_name que executa uma busca pelos campos first_name ou last_name da tabela de usuário.
  Ela espera uma string como argumento.
  Retorna um array de usuários que contenham o first_name ou last_name
  que correspondam ao parametro enviado na busca.
  """
  @spec get_by_name(String.t()) ::
        {:error, Error.t()} | {:ok, list(User.t())}
  def get_by_name(user_name) do
    from(u in User,
      where: ilike(u.first_name, ^"%#{user_name}%") or ilike(u.last_name, ^"%#{user_name}%")
    )
    |> Repo.all()
    |> case do
      nil -> {:error, Error.build(:not_found, "User is not found!")}
      users ->
        users_with_accounts = Repo.preload(users, :accounts)
        {:ok, users_with_accounts}
    end
  end

  @doc"""
  Função get_by_id que executa uma busca mais seleta pelo ID do usuário.
  Espera o id como parametro.
  Retorna apenas um usuário correspondente ao ID.
  """
  @spec get_by_id(binary()) ::
        {:error, Error.t()} | {:ok, User.t()}
  def get_by_id(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        user <- Repo.get(User, uuid) do
      user_with_accounts = Repo.preload(user, :accounts)
      {:ok, user_with_accounts}
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      nil -> {:error, Error.build(:not_found, "User is not found!")}
    end
  end
end
