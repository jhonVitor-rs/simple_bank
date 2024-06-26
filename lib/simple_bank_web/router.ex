defmodule SimpleBankWeb.Router do
  use SimpleBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SimpleBankWeb do
    pipe_through :api

    resources "/users", UserController, only: [:index, :show, :create, :update, :delete]
    get "/users/name/:user_name", UserController, :show_by_name, as: :show_by_name

    resources "/accounts", AccountController, only: [:index, :show, :create, :update, :delete]
    get "/accounts/user_id/:user_id", AccountController, :show_by_user_id, as: :show_by_user_id
    get "/accounts/number/:number", AccountController, :show_by_number, as: :show_by_number
    get "/accounts/type/:type", AccountController, :show_by_type, as: :show_by_type

    resources "/transactions", TransactionController, only: [:show, :create]
  end

  scope "/api/swagger" do
    forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :simple_bank, swagger_file: "swagger.json")
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Simple Bank",
        description: "API Documentation for Simple Bank v1, developed to simulate simple bank transactions.",
        termsOfService: "Open for public",
        contact: %{
          name: "João Vitor Rankel Siben",
          email: "joaovitor.jvrs6@gmail.com"
        }
      },
      consumes: ["application/json"],
      produces: ["application/json"],
      tags: [
        %{name: "Users", description: "User resources"},
        %{name: "Accounts", description: "Accounts resources"},
        %{name: "Transactions", description: "Trasactions routes"}
      ]
    }
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:simple_bank, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: SimpleBankWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
