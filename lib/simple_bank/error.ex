defmodule SimpleBank.Error do
  alias Ecto.Changeset

  @keys [:status, :result]

  @enforce_keys @keys

  defstruct @keys

  @type t :: %__MODULE__{
    result: String.t() | Changeset.t() | atom(),
    status: atom()
  }

  @spec build(atom(), String.t() | Changeset.t() | atom()) :: t
  @doc """
  Build error messages.
  """
  def build(status, result) do
    %__MODULE__{
      result: result,
      status: status
    }
  end
end
