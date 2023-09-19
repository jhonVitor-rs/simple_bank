defmodule SimpleBank.Schemas.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias SimpleBank.Schemas.User

  @derive {Jason.Encoder, only: [:id, :amount, :sender_id, :receiver_id, :status, :created_at]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :status, :string
    field :amount, :float
    field :created_at, :naive_datetime

    belongs_to :sender, User
    belongs_to :receiver, User

    timestamps()
  end

  @doc false
  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:amount, :status, :sender_id, :receiver_id])
    |> validate_required([:amount, :status, :sender_id, :receiver_id])
    |> validate_number(:amount, greater_than_or_equal_to: 0.1, message: "The transaction amount must be greater than zero!")
  end
end
