defmodule TicketmeWeb.Router do
  use TicketmeWeb, :router

  import TicketmeWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {TicketmeWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", TicketmeWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live("/", UserLoginLive, :new)
  end

  scope "/", TicketmeWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/dashboard", DeviceDashboardLive, :index)
    live("/device_stats", DeviceStatsLive, :index)
  end

  # Dev routes
  if Application.compile_env(:ticketme, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard "/dashboard", metrics: TicketmeWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", TicketmeWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TicketmeWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", TicketmeWeb do
    pipe_through([:browser, :require_authenticated_user])
    # resources("/devices", DeviceController)

    live_session :require_authenticated_user,
      on_mount: [{TicketmeWeb.UserAuth, :ensure_authenticated}] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)
    end
  end

  scope "/", TicketmeWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{TicketmeWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end
end
