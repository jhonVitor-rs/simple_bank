defmodule SimpleBankWeb.Router do
  use SimpleBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SimpleBankWeb do
    pipe_through :api

    get "/users", UserController, :show
    get "/users/:user_name", UserController, :show_by_name
    get "/user_by_id/:id", UserController, :show_by_id

    post "/user", UserController, :create
    patch "/user/:id", UserController, :update
    delete "/user/:id", UserController, :delete

    get "/accounts", AccountController, :show
    get "/accounts/:user_id", AccountController, :show_by_user_id
    get "/account_by_id/:id", AccountController, :show_by_id
    get "/account_by_number/:number", AccountController, :show_by_number

    post "/account", AccountController, :create
    patch "/account/:id", AccountController, :update
    delete "/account/:id", AccountController, :delete

    get "/transaction_by_id/:id", TransactionController, :show_by_id

    post "/transaction", TransactionController, :create
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
