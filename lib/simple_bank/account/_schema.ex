defmodule SimpleBank.Account do
  @moduledoc """
  Modulo Account para o SimpleBank

  Este modulo define o schema para a tabela "accounts" e fornece funçoes para
  manipular registros de contas, incluindo a criação de um changeset para
  validação de dados das contas

  Campos do schema:
  - :number - O número da conta gerado pelo sistema(integer)
  - :balance - O saldo disponível na conta (decimal)
  - :type - O tipo da conta que pode ser corrente (:chain), poupança (:saving) e salário (:wage)
  - :user - Faz referência ao usuário a quem a conta pertence (User.t() ou NotLoaded.t()),
  - :transaction_sent - Faz referência as transações feitas pela conta (lista de Transaction.t() ou NotLoaded.t())
  - :transaction_received - Faz referência as transações que a conta recebeu (lista de Transaction.t() ou NotLoaded.t())
  - :inserted_at - A data e hora da criação da conta (Datetime.t())
  - :updated_at - A data e hora da ultima atualização do resgistro da conta (Datetime.t())

  Os campos :number, :type, e :user_id são obrigatórios para
  a criação de uma noca conta.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Association.NotLoaded
  alias SimpleBank.{User, Transaction}

  # Lista de campos que podem ser alterados diretamente
  @field_that_can_be_changes [
    :number,
    :balance,
    :type,
    :user_id
  ]

  # Lista de campos obrigatórios
  @required_fields [
    :number,
    :type,
    :user_id
  ]

  # Define o campo id como chave primária e configura para ser gerado automaticamente
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  #Define o tipo t para o módulo Account
  @type t :: %__MODULE__{
    id: binary(),
    number: integer(),
    balance: Decimal.t(),
    type: :chain | :savings | :wage,
    # user_id: binary(),
    user: User.t() | NotLoaded.t(),
    transactions_sent: [Transaction.t()] | NotLoaded.t(),
    transactions_received: [Transaction.t()] | NotLoaded.t(),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  # Define quais campos serão incluídos na codificação para JSON
  @derive {
    Jason.Encoder,
    only: [
      :number,
      :balance,
      :type,
      :user,
      :transactions_sent,
      :transactions_received,
      :inserted_at,
      :updated_at
    ]
  }

  # Define o schema para a tabela "accounts"
  schema "accounts" do
    field :number, :integer
    field :balance, :decimal, default: 0
    field :type, Ecto.Enum, values: [:chain, :savings, :wage]

    belongs_to :user, User, type: :binary_id

    has_many :transactions_sent, Transaction
    has_many :transactions_received, Transaction

    timestamps()
  end

  # Define a função changeset com a sua especificação
  @spec changeset(Ecto.Schema.t() | %__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(struct \\ %__MODULE__{}, %{} = params) do
    struct
    |> cast(params, @field_that_can_be_changes)
    |> validate_required(@required_fields)
    |> cast_assoc(:user)
    |> validate_number(:number, greater_than_or_equal_to: 0)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> unique_constraint(:number)
  end
end
