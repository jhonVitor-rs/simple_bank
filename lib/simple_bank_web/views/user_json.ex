defmodule SimpleBankWeb.UserJSON do
  alias SimpleBankWeb.ErrorJSON

  alias SimpleBank.User

  def render("all_users.json", %{users: users}) do
    %{data: users}
  end

  def render("user.json", %{user: %User{} = user}) do
    %{user: user}
  end

  def render("error.json", %{result: result}) do
    ErrorJSON.error(result)
  end
end
