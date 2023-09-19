defmodule SimpleBankWeb.TransactionView do
  use SimpleBankWeb, :view

  def render("error.json", %{message: message, cause: cause}) do
    %{
      message: message,
      cause: cause
    }
  end

  def render("success.json", %{data: data}) do
    %{
      data: data
    }
  end
end
