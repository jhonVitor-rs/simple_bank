defmodule SimpleBank.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias SimpleBank.Account

  @fields_that_can_be_changes [
    :first_name,
    :last_name,
    :cpf,
    :birth,
    :address,
    :cep
  ]

  @required_fields [
    :first_name,
    :last_name,
    :cpf,
    :birth,
    :address,
    :cep
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {
    JasonV.Encoder,
    only: [
      :first_name,
      :last_name,
      :cpf,
      :birth,
      :address,
      :cep,
      :accounts
    ]
  }

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
