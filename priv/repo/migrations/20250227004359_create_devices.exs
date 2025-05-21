defmodule Ticketme.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :device_name, :string
      add :device_id, :string
      add :device_type, :string
      add :is_active, :boolean, default: false, null: false
      add :last_active_at, :utc_datetime
      add :created_user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:devices, [:device_id])
    create index(:devices, [:created_user_id])
  end
end
