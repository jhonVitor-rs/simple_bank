defmodule SimpleBank.Transaction do
  @moduledoc """
  Modulo Transaction para o SimpleBank

  Este módulo define o schema para a tabela "transactions" e fornece uma função
  para manipular registros de transações, incluindo a criação de um changeset para
  validação de dados das transações

  Campos do schema:
  - :number - O número da transação gerado pelo sistema (integer)
  - :amount - O valor da transação (decimal)
  - :type - O tipo da transação que pode transferência (:transfer), deposito (:deposit) ou saque (:withdraw)
  - :status - O status em que a transação se encontra, que pode ser pendente (:pending), completa (:complete) ou incompleta (:incomplete)
  - :account - Faz referência a conta a qual a transação pertence (Account.t() ou NotLoaded.t())
  - :recipient - Faz referência a conta que recebeu a transação (account.t() on NotLoaded.t())
  - :inserted_at - A data em que a transação foi criada (Datetime.t())
  - :updated_at - A data em que a transação foi atualizada (Datetime.t())

  Os campos :number, :type, :status, :account_id e recipient_id são obrigatórios
  para a criação de uma nova transação
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Association.NotLoaded
  alias SimpleBank.Account

  @field_that_can_be_changes [
    :number,
    :amount,
    :type,
    :status,
    :account_id,
    :recipient_id
  ]

  @required_fields [
    :number,
    :type,
    :status,
    :account_id,
    ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @type t :: %__MODULE__{
    id: binary(),
    number: integer(),
    amount: Decimal.t(),
    type: :transfer | :deposit | :withdraw,
    status: :pending | :complete | :incomplete,
    # account_id: binary(),
    account: Account.t() | NotLoaded.t(),
    # recipient_id: binary(),
    recipient: Account.t() | NotLoaded.t(),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  @derive {
    Jason.Encoder,
    only: [
      :number,
      :amount,
      :type,
      :status,
      :recipient,
      :inserted_at,
      :updated_at
    ]
  }

  schema "transactions" do
    field :number, :integer
    field :amount, :decimal, default: 0
    field :type, Ecto.Enum, values: [:transfer, :deposit, :withdraw]
    field :status, Ecto.Enum, values: [:pending, :complete, :incomplete]

    belongs_to :account, Account, type: :binary_id
    belongs_to :recipient, Account, type: :binary_id

    timestamps()
  end

  @spec changeset(Ecto.Schema.t() | %__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(struct \\ %__MODULE__{}, %{} = params) do
    struct
    |> cast(params, @field_that_can_be_changes)
    |> validate_required(@required_fields)
    |> cast_assoc(:account)
    |> cast_assoc(:recipient)
    |> validate_number(:number, greater_than_or_equal_to: 0)
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> unique_constraint(:number)
  end
end
