defmodule SimpleBankWeb.UserController do
  use SimpleBankWeb, :controller
  use PhoenixSwagger

  alias SimpleBankWeb.FallbackController
  alias SimpleBank.User

  action_fallback FallbackController

  def swagger_definitions do
    %{
      UserRequest:
        swagger_schema do
          title "User Request"
          description "POST body for creating a user"
          type :object

          properties do
            first_name :string, "Fist Name", required: true
            last_name :string, "Last Name", required: true
            cpf :string, "CPF", required: true
            birth :string, "Birth date", format: "date", required: true
            address :string, "Address", required: true
            cep :string, "CEP", required: true
          end
        end,
      UserResponse:
        swagger_schema do
          title "User Response"
          description "Response schema for a single user"
          type :object

          properties do
            id :string, "User ID", required: true
            first_name :string, "Fist Name", required: true
            last_name :string, "Last Name", required: true
            cpf :string, "CPF", required: true
            birth :string, "Birth date", format: "date", required: true
            address :string, "Address", required: true
            cep :string, "CEP", required: true
            inserted_at :string, "Insertion date", format: "date_time"
            updated_at :string, "Update date", format: "date-time"
            accounts(:array, "User Account", Schema.array(:UserAccount))
          end
        end,
      UserAccount:
        swagger_schema do
          title "User Account"
          description "Account schema that is returned along with the user"
          type :object

          properties do
            id :string, "Account ID", required: true
            number :integer, "Number", required: true
            balance :string, "Balance", format: "decimal", required: true
            type :string, "Type", required: true
            inserted_at :string, "Insertion date", format: "date_time"
            updated_at :string, "Update date", format: "date-time"
          end
        end
      ,
      UsersResponse:
        swagger_schema do
          title "Users Response"
          description "Response schema for a many user"
          type :object

          properties do
            id :string, "User ID", required: true
            first_name :string, "Fist Name", required: true
            last_name :string, "Last Name", required: true
            cpf :string, "CPF", required: true
            accounts(:array, "Users Account", Schema.array(:UsersAccount))
          end
        end,
      UsersAccount:
        swagger_schema do
          title "Usera Account"
          description "Account schema that is returned along with the usera"
          type :object

          properties do
            id :string, "Account ID", required: true
            number :integer, "Number", required: true
            type :string, "Type", required: true
          end
        end
    }
  end

  swagger_path :index do
    get "/api/users"
    summary "List all users"
    description "List all users in the database"
    produces "application/json"
    tag "Users"
    response 200, "OK", Schema.ref(:UsersResponse)
    response 404, "Not Found"
  end
  def index(conn, _params) do
    with {:ok, users} <- SimpleBank.get_users() do
      conn
      |> put_status(:ok)
      |> render("all_users.json", users: users)
    end
  end

  swagger_path :show do
    get "/api/users/{id}"
    summary "Get a user by ID"
    description "Get a specified user by their ID"
    produces "application/json"
    tag "Users"
    parameter :id, :path, :binary, "User ID", required: true
    response 200, "OK", Schema.ref(:UserResponse)
    response 400, "Bad Request"
    response 404, "Not Found"
  end
  def show(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- SimpleBank.get_user_by_id(id) do
      conn
      |> put_status(:ok)
      |> render("user.json", user: user)
    end
  end

  swagger_path :show_by_name do
    get "/api/users/name/{name}"
    summary "Get users by name"
    description "Get users that match the search by name"
    produces "application/json"
    tag "Users"
    parameter :name, :path, :string, "User name", required: true
    response 200, "OK", Schema.ref(:UsersResponse)
    response 404, "Not Found"
  end
  def show_by_name(conn, %{"user_name" => user_name}) do
    with {:ok, users} <- SimpleBank.get_user_by_name(user_name) do
      conn
      |> put_status(:ok)
      |> render("all_users.json", users: users)
    end
  end

  swagger_path :create do
    post "/api/users"
    summary "Create a new user"
    description "Creates a new user in the database"
    produces "application/json"
    tag "Users"
    consumes "application/json"

    parameter :user, :body, Schema.ref(:UserRequest), "User data", required: true

    response 200, "OK", Schema.ref(:UserResponse)
    response 400, "Bad Request"
  end
  def create(conn, params) do
    params =
      params
      |> Enum.map(fn {k, v} ->
        key = String.to_atom(k)
        value = if key == :birth, do: Date.from_iso8601!(v), else: v
        {key, value}
      end)
      |> Enum.into(%{})

    with {:ok, %User{} = user} <- SimpleBank.create_user(params) do
      conn
      |> put_status(:created)
      |> render("user.json", user: user)
    end
  end

  swagger_path :update do
    put "/api/users/{id}"
    summary "Update a existing user"
    description "Update a existing user in the database"
    produces "application/json"
    tag "Users"
    consumes "application/json"

    parameters do
      id :path, :binary, "User ID", required: true

      user :body, Schema.ref(:UserRequest), "User data"
    end

    response 200, "OK", Schema.ref(:UserResponse)
    response 400, "Bad Request"
    response 404, "Not Found"
  end
  def update(conn, params) do
    params =
      params
      |> Enum.map(fn {k, v} ->
        key = String.to_atom(k)
        value = if key == :birth, do: Date.from_iso8601!(v), else: v
        {key, value}
      end)
      |> Enum.into(%{})

    with {:ok, %User{} = user} <- SimpleBank.update_user(params) do
      conn
      |> put_status(:ok)
      |> render("user.json", user: user)
    end
  end

  swagger_path :delete do
    delete "/api/users/{id}"
    summary "Delete a user"
    description "Deletes an existing user from the system"
    produces "application/json"
    tag "Users"

    parameter :id, :path, :binary, "User ID", required: true

    response 204, "No Content"
    response 404, "Not Found"
  end
  # def delete(conn, %{"id" => id}) do
  #   with {:ok, %User{}} <- SimpleBank.delete_user(id) do
  #     conn
  #     |> put_status(:no_content)
  #     |> render("delete.json", message: "User deleted with success!")
  #   end
  # end
end
