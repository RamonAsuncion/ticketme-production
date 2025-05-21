defmodule Ticketme.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices" do
    field :device_name, :string
    field :device_id, :string
    field :mac_address, :string
    field :device_type, :string
    field :is_active, :boolean, default: false
    field :last_active_at, :utc_datetime
    field :created_user_id, :id

    many_to_many :users, Ticketme.Accounts.User,
      join_through: "users_devices",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [
      :device_name,
      :device_id,
      :mac_address,
      :device_type,
      :is_active,
      :last_active_at
    ])
    |> validate_required([
      :device_name,
      :device_id,
      :mac_address,
      :device_type,
      :is_active,
      :last_active_at
    ])
    |> unique_constraint(:device_id)
  end
end
