defmodule SimpleBank.User.Update do
  @moduledoc """
  Modulo User.Update para Atualização de Usuário para o SimpleBank.

  Este módulo define o serviço de atualização para a tabela "users",
  fornecendo uma funcção para atualização que deverá receber como parametro os campos:
  - :id - Um ID unico gerado pelo sistema, ele será enviado junto da URL (binary())
  - :first_name - uma string contendo o nome do usuário (string)
  - :last_name - uma string contendo o sobrenome do usuário (string)
  - :cpf - O CPF do usuário em formato de string (string)
  - :birth - A data de nascimento do usuário (date)
  - :address - O endereço do usuário (string)
  - :cep - O CEP do usuário (string)
  """

  alias SimpleBank.{User, Repo, Error}

  @type user_params :: %{
    id: binary(),
    first_name: String.t(),
    last_name: String.t(),
    cpf: String.t(),
    birth: Date.t(),
    address: String.t(),
    cep: String.t()
  }

  @spec call(user_params()) ::
        {:error, Error.t()} | {:ok, User.t()}
  def call(%{"id" => id} = params) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        user <- Repo.get(User, uuid) do
      user
      |> User.changeset(params)
      |> Repo.update()
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      {:error, result} -> {:error, Error.build(:bad_request, result)}
      nil -> {:error, Error.build(:not_found, "User is not found!")}
    end
  end

  @doc """
  Esta função e ativada quando o usuário envia um argumento envalido
  """
  def call(_anything), do: {:error, Error.build(:bad_request, "ID not provided!")}
end
