defmodule Ticketme.Repo.Migrations.AddMacAddressToDevices do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :mac_address, :string
    end

    create unique_index(:devices, [:mac_address])
  end
end
