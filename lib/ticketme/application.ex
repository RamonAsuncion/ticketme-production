defmodule Ticketme.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TicketmeWeb.Telemetry,
      Ticketme.Repo,
      {DNSCluster, query: Application.get_env(:ticketme, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ticketme.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ticketme.Finch},
      # Start a worker by calling: Ticketme.Worker.start_link(arg)
      # {Ticketme.Worker, arg},
      # Start to serve requests, typically the last entry
      TicketmeWeb.Endpoint

      # Start the TemperatureFetcher GenServer
      # {Ticketme.SensorData.TemperatureFetcher, []}
      # Ticketme.SensorData.TemperatureFetcher
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ticketme.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TicketmeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
