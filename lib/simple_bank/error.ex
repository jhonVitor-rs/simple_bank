defmodule SimpleBank.Error do
  alias Ecto.Changeset

  @keys [:status, :result]

  @enforce_keys @keys

  defstruct @keys

  @type t :: %__MODULE__{
    result: String.t() | Changeset.t() | atom(),
    status: atom()
  }

  @spec build(atom(), String.t() | Changeset.t()) :: t
  @doc """
  Build error messages.
  """
  def build(status, result) do
    %__MODULE__{
      result: result,
      status: status
    }
  end

  @doc """
  Error default message for status :not_found.
  """
  @spec build_user_not_found :: t
  def build_user_not_found, do: build(:not_found, "User not found")
end
