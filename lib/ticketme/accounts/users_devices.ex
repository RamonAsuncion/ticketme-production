defmodule Ticketme.Accounts.UsersDevices do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "users_devices" do
    belongs_to :user, Ticketme.Accounts.User, on_replace: :delete
    belongs_to :device, Ticketme.Devices.Device, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(users_device, attrs) do
    users_device
    |> cast(attrs, [:user_id, :device_id])
    |> validate_required([:user_id, :device_id])
  end
end
