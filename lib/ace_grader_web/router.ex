defmodule AceGraderWeb.Router do
  use AceGraderWeb, :router

  import AceGraderWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AceGraderWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug AceGraderWeb.Plugs.SetCurrentPath
    plug AceGraderWeb.Plugs.Locale, "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", AceGraderWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ace_grader, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AceGraderWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AceGraderWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AceGraderWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", AceGraderWeb do
    pipe_through [:browser, :require_teacher_user]

    post "/exercises/:id/duplicate", ExerciseController, :duplicate
    delete "/exercises/:id", ExerciseController, :delete
    if Application.compile_env(:ace_grader, :dev_routes) do
      delete "/exercises/:exercise_id/submissions/:id", SubmissionController, :delete
    end

    live_session :require_teacher_user,
      on_mount: [{AceGraderWeb.UserAuth, :ensure_teacher}] do
        live "/exercises/new", ExerciseLive.Form
        live "/exercises/:id/edit", ExerciseLive.Form
    end
  end

  scope "/", AceGraderWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AceGraderWeb.UserAuth, :ensure_authenticated}] do

      live "/exercises/:id/editor", ExerciseLive.Editor
      live "/exercises/:exercise_id/submissions/:id", SubmissionLive.Show

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", AceGraderWeb do
    pipe_through [:browser]

    resources "/exercises", ExerciseController, only: [:index, :show]
    get "/users/:username", UserController, :show

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AceGraderWeb.UserAuth, :mount_current_user}] do

      live "/", HomeLive

      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
