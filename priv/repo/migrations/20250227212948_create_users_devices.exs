defmodule Ticketme.Repo.Migrations.CreateUsersDevices do
  use Ecto.Migration

  def change do
    create table(:users_devices, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :device_id, references(:devices, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime, updated_at: false)
      add :updated_at, :utc_datetime, null: false, default: fragment("now()")
    end
  end
end
