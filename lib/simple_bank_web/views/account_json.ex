defmodule SimpleBankWeb.AccountJSON do
  alias SimpleBankWeb.ErrorJSON

  def render("all_accounts.json", %{accounts: accounts}) do
    %{data: accounts}
  end

  def render("account.json", %{account: account}) do
    %{account: account}
  end

  def render("error.json", %{result: result}) do
    ErrorJSON.error(result)
  end

  def render("delete.json", %{message: message}) do
    %{message: message}
  end
end
