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

    resources "/transactions", TransactionController, only: [:show, :create]
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
