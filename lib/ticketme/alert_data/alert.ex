defmodule Ticketme.Repo.Migrations.CreateAlerts do
  use Ecto.Migration

  def change do
    create table(:alerts) do
      add :message, :text
      add :timestamp, :naive_datetime

      timestamps()
    end
  end
end
