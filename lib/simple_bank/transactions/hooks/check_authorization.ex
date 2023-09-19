defmodule SimpleBank.Transactions.Hooks.CheckAuthorization do
  import HTTPoison

  def check_authorization do
    url = "https://run.mocky.io/v3/8fafdd68-a090-496f-8c9a-3442cf30dae6"

    case get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"message" => "Autorizado" }} ->
            {:ok, "Autorizado"}
          _->
            {:error, "Autorização negada", "Erro na autenticação da API"}
        end
      {:ok, _} ->
        {:error, "Autorização inválida", "Erro na autenticação da API"}
      {:error, reason} ->
        {:error, "Erro ao consultar serviço de autorização", "#{reason}"}
    end
  end
end
