defmodule Ticketme.Repo.Migrations.AddEmbeddedFieldToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :module_settings, :map
    end
  end
end
