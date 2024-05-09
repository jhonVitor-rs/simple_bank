defmodule SimpleBankWeb.ErrorJSON do
  import Ecto.Changeset, only: [traverse_errors: 2]

  alias Ecto.Changeset
  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  # def render(template, _assigns) do
  #   %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  # end

  @doc """
  Esta função é usada para renderizar erros, ela possui duas abordagems
  A primeira renderiza os erros que são representados por um Ecto.Changeset.
  A segunda é usada para renderizar erros que são representados por uma mensagem de erro.
  Ela chama a função translate_errors/1 para traduzir os erros no changeset e retorna um mapa com a mensagem de erro.
  """
  # def render("error.json", %{result: %Changeset{} = changeset}) do
  #   %{message: translate_errors(changeset)}
  # end

  def error(%Changeset{} = changeset) do
    %{message: translate_errors(changeset)}
  end

  # def render("error.json", %{result: error_message}) do
  #   %{message: error_message}
  # end
  def error(result) do
    %{message: result}
  end

  def translate_errors(%Changeset{} = changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", translate_value(value))
      end)
    end)
  end

  defp translate_value({:parameterized, Ecto.Enum, _map}), do: ""
  defp translate_value(value), do: to_string(value)
end
