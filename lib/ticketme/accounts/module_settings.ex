defmodule Ticketme.Accounts.ModuleSettings do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :module_1, :boolean, default: false
    field :module_2, :boolean, default: false
    field :module_3, :boolean, default: false
  end

  def changeset(module_settings, params) do
    module_settings
    |> cast(params, ~w(module_1 module_2 module_3)a)
  end
end
