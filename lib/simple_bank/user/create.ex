defmodule SimpleBank.User.Create do
  @moduledoc """
  Módulo User.Create para criação de um Usuário para o SimpleBank.

  Este módulo define um serviço de criação para a tabela de "users"
  fornecendo uma função que recebe como argumento os seguintes campos:
  - :first_name - uma string contendo o nome do usuário (string)
  - :last_name - uma string contendo o sobrenome do usuário (string)
  - :cpf - O CPF do usuário em formato de string (string)
  - :birth - A data de nascimento do usuário (date)
  - :address - O endereço do usuário (string)
  - :cep - O CEP do usuário (string)
  """

  alias SimpleBank.{User, Repo, Error}

  @type user_params :: %{
    first_name: String.t(),
    last_name: String.t(),
    cpf: String.t(),
    birth: Date.t(),
    address: String.t(),
    cep: String.t()
  }

  @spec call(user_params()) ::
        {:error, Error.t()} | {:ok, User.t()}
  def call(%{} = params) do
    with changeset <- User.changeset(params),
        {:ok, %User{} = user} <- Repo.insert(changeset),
        user = Repo.preload(user, :accounts) do
      {:ok, user}
    else
      {:error, %Error{}} = error -> error
      {:error, result} -> {:error, Error.build(:bad_request, result)}
    end
  end

  @doc """
  Esta função e ativada quando o usuário envia um argumento invalido
  """
  def call(_anything), do: {:error, Error.build(:bad_request, "Enter the data in a map format")}
end
