# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Summary of Endpoint documentation page:
# config/dev.exs -  development environment
# config/prod.exs - production environment
# config/runtime.exs - runtime configuration settings (when application starts)
# config.exs - general configuration file that is loaded for all environments

config :ticketme,
  ecto_repos: [Ticketme.Repo],
  generators: [timestamp_type: :utc_datetime]

config :ticketme, Ticketme.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: "a650f6fd06f1482e4569b85bebe545dd-10b6f382-8954f9c7",
  domain: "sandboxf95566671b144e2094e48b754a71452b.mailgun.org"

config :swoosh, :api_client, Swoosh.ApiClient.Hackney

# Configures the endpoint
config :ticketme, TicketmeWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TicketmeWeb.ErrorHTML, json: TicketmeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Ticketme.PubSub,
  live_view: [signing_salt: "L7QIsnkd"],
  socket_path: "/socket",
  live_socket_path: "/live"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  ticketme: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  ticketme: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
