defmodule SimpleBank.User do
  @moduledoc """
  Módulo User para o SimpleBank.

  Este módulo define o schema para a tabela "users" e fornece funções para
  manipular registros de usuários, incluindo a criação de um changeset para
  validação de dados do usuário.

  Campos do schema:
  - :first_name - O primeiro nome do usuário (string)
  - :last_name - O sobrenome do usuário (string)
  - :cpf - O CPF do usuário (string)
  - :birth - A data de nascimento do usuário (date)
  - :address - O endereço do usuário (string)
  - :cep - O CEP do usuário (string)
  - :accounts - As contas associadas ao usuário (lista de Account.t() ou NotLoaded.t())
  - :inserted_at - A data e hora de criação do registro do usuário (DateTime.t())
  - :updated_at - A data e hora da última atualização do registro do usuário (DateTime.t())

  Os campos :first_name, :last_name, :cpf, :birth, :address e :cep são todos
  campos obrigatórios e devem ser fornecidos ao criar ou atualizar um usuário.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Association.NotLoaded
  alias SimpleBank.Account

  # Lista de campos que podem ser alterados
  @fields_that_can_be_changes [
    :first_name,
    :last_name,
    :cpf,
    :birth,
    :address,
    :cep
  ]

  # Lista de campos obrigatórios
  @required_fields [
    :first_name,
    :last_name,
    :cpf,
    :birth,
    :address,
    :cep
  ]

  # Define o campo id como chave primária e configura para ser gerado automaticamente
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  # Define o tipo t para o módulo User
  @type t :: %__MODULE__{
    id: binary(),
    first_name: String.t(),
    last_name: String.t(),
    cpf: String.t(),
    birth: Date.t(),
    address: String.t(),
    cep: String.t(),
    accounts: [Account.t()] | NotLoaded.t(),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  # Define quais campos serão incluídos na codificação para JSON
  @derive {
    Jason.Encoder,
    only: [
      :id,
      :first_name,
      :last_name,
      :cpf,
      :birth,
      :address,
      :cep,
      :accounts,
      :inserted_at,
      :updated_at
    ]
  }

  # Define o schema para a tabela "users"
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :cpf, :string
    field :birth, :date
    field :address, :string
    field :cep, :string

    has_many :accounts, Account

    timestamps()
  end

  # Define a função changeset com sua especificação
  @spec changeset(Ecto.Schema.t() | %__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(struct \\ %__MODULE__{}, %{} = params) do
    struct
    |> cast(params, @fields_that_can_be_changes)
    |> validate_required(@required_fields)
    |> validate_length(:first_name, min: 3)
    |> validate_length(:last_name, min: 3)
    |> unique_constraint(:cpf)
  end
end
