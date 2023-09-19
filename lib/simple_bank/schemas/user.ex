defmodule SimpleBank.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias SimpleBank.Schemas.Transaction

  @fields [:firstName, :lastName, :document, :email, :password, :balance, :userType]
  @derive {Jason.Encoder, only: [:id, :firstName, :lastName, :document, :email, :balance, :userType, :sent_transactions, :received_transactions]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :balance, :float
    field :password, :string
    field :firstName, :string
    field :lastName, :string
    field :document, :string
    field :email, :string
    field :userType, :string

    has_many :sent_transactions, Transaction, foreign_key: :sender_id
    has_many :received_transactions, Transaction, foreign_key: :receiver_id

    timestamps()
  end

  @doc false
  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:firstName, :lastName, :document, :email, :password, :balance, :userType])
    |> validate_required([:firstName, :lastName, :document, :email, :password, :balance, :userType])
    |> unique_constraint(:document, message: "This document has already been registered!")
    |> unique_constraint(:email, message: "This email has already been registered!")
    |> validate_inclusion(:userType, ["common", "merchant"], message: "Invalid input type, the expected type is common or merchant!")
    |> validate_format(:email, ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "Invalid email format!")
    |> validate_length(:password, min: 8, message: "Password too short, min 8 characters!")
    |> validate_length(:firstName, min: 3, message: "Very short first name min 3 letters!")
    |> validate_length(:lastName, min: 3, message: "Very short last name min 3 letters!")
    |> validate_number(:balance, greater_than_or_equal_to: 0, message: "Account value must be positive!")
  end
end
