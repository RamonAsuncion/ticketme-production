defmodule Ticketme.Repo do
  use Ecto.Repo,
    otp_app: :ticketme,
    adapter: Ecto.Adapters.Postgres
end
