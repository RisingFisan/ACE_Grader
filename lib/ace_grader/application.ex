defmodule AceGrader.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AceGraderWeb.Telemetry,
      # Start the Ecto repository
      AceGrader.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: AceGrader.PubSub},
      # Start Finch
      {Finch, name: Swoosh.Finch},
      # Start the Endpoint (http/https)
      AceGraderWeb.Endpoint,
      # Start a worker by calling: AceGrader.Worker.start_link(arg)
      # {AceGrader.Worker, arg},
      AceGrader.Grader.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AceGrader.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AceGraderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
