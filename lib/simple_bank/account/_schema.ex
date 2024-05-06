defmodule SimpleBank.Account do
  use Ecto.Schema

  import Ecto.Changeset

  alias SimpleBank.User

  @field_that_can_be_changes [
    :number,
    :balance,
    :type,
    :user_id
  ]

  @required_fields [
    :number,
    :type,
    :user_id
  ]

  @primary_key {:id, :binary_id, autogenerate: true}

  @derive {
    JasonV.Encode,
    only: [
      :number,
      :balance,
      :type,
      :user_id
    ]
  }

  schema "account" do
    field :number, :integer
    field :balance, :decimal, default: 0
    field :type, Ecto.Enum, values: [:chain, :savings, :wage]

    belongs_to :user, User, type: :binary_id

    timestamps()
  end

  @spec changeset(Ecto.Schema.t() | %__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(struct \\ %__MODULE__{}, %{} = params) do
    struct
    |> cast(params, @field_that_can_be_changes)
    |> validate_required(@required_fields)
    |> cast_assoc(:user)
    |> validate_number(:number, greater_than_or_equal_to: 0)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end
end
