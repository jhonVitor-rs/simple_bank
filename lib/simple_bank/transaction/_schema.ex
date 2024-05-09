defmodule SimpleBank.Transaction do
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
    :recipient_id
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
