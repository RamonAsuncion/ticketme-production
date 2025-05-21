defmodule Ticketme.Repo.Migrations.AddDeviceData do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :device_data, :map
    end
  end
end
