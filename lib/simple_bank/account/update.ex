defmodule SimpleBank.Account.Update do
  @moduledoc """
  Modulo Account.Update para Atualização de Contas para o SimpleBank

  Este módulo define o serviço de atualização para a tabela "accounts",
  fornecendo uma função para atualização que deverá receber como parametrp os campos:
  - :id - Um ID unico gerado pelo sistema, ele será enviado junto da URL (binary())
  - :number - O número da conta que serve como identificador no sistema para executar as transações (integer)
  - :balance - O valor disponivel para movientação na conta (decimal)
  - :type - O tipo especifico da conta que pode ser corrente (:chain), poupança (:saving) e salário (:wage)
  - :user_id - O ID que refeência o usuário a quem a conta pertence
  """

  alias SimpleBank.{Account, Repo, Error}

  @type account_params :: %{
    id: binary(),
    number: integer(),
    balance: Decimal.t(),
    type: :chain | :savings | :wage,
    user_id: binary()
  }

  @spec call(%{id: binary()}) ::
        {:error, Error.t()} | {:ok, Account.t()}
  def call(%{"id" => id} = params) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
        account <- Repo.get(User, uuid) do
      account
      |> Account.changeset(params)
      |> Repo.update()
    else
      :error -> {:error, Error.build(:bad_request, "ID must be a valid UUID!")}
      {:error, result} -> {:error, Error.build(:bad_request, result)}
      nil -> {:error, Error.build(:not_found, "Account is not found!")}
    end
  end

  @doc """
  Está é a função privada chamada para gerar um número aleatório para a conta
  """
  def call(_anything), do: {:error, Error.build(:bad_request, "ID not provided!")}
end
