defmodule Ticketme.Devices do
  @moduledoc """
  The Devices context.
  """

  import Ecto.Query, warn: false
  alias Ticketme.Repo

  alias Ticketme.Devices.Device
  alias Ticketme.Accounts.User
  alias Ticketme.Accounts.UsersDevices

  @doc """
  Returns all devices associated with the given user.

  ## Examples

      iex> list_devices_for_user(user)
      [%Device{}, ...]

  """
  def list_devices_for_user(%User{} = user) do
    user = Repo.preload(user, :devices)
    user.devices
  end

  @doc """
  Returns all users associated with the given device.

  ## Examples

      iex> list_users_for_device(device)
      [%User{}, ...]

  """
  def list_users_for_device(%Device{} = device) do
    device = Repo.preload(device, :users)
    device.users
  end

  @doc """
  Returns the list of devices.

  ## Examples

      iex> list_devices()
      [%Device{}, ...]

  """
  def list_devices do
    Repo.all(Device)
  end

  @doc """
  Gets a single device.

  Raises `Ecto.NoResultsError` if the Device does not exist.

  ## Examples

      iex> get_device!(123)
      %Device{}

      iex> get_device!(456)
      ** (Ecto.NoResultsError)

  """
  def get_device!(id), do: Repo.get!(Device, id)

  @doc """
  Creates a device.

  ## Examples

      iex> create_device(%{field: value})
      {:ok, %Device{}}

      iex> create_device(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_device(attrs \\ %{}) do
    %Device{}
    |> Device.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a device.

  ## Examples

      iex> update_device(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device(%Device{} = device, attrs) do
    device
    |> Device.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a device.

  ## Examples

      iex> delete_device(device)
      {:ok, %Device{}}

      iex> delete_device(device)
      {:error, %Ecto.Changeset{}}

  """
  def delete_device(%Device{} = device) do
    Repo.delete(device)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking device changes.

  ## Examples

      iex> change_device(device)
      %Ecto.Changeset{data: %Device{}}

  """
  def change_device(%Device{} = device, attrs \\ %{}) do
    Device.changeset(device, attrs)
  end

  @doc """
  Associates a device with a user.

  ## Examples

      iex> associate_device_with_user(user, device)
      {:ok, %User{}}

  """

  def associate_device_with_user(user_or_id, device_or_id) do
    user =
      case user_or_id do
        %Ticketme.Accounts.User{} = user -> user
        user_id when is_integer(user_id) -> Repo.get!(Ticketme.Accounts.User, user_id)
      end

    device =
      case device_or_id do
        %Ticketme.Devices.Device{} = device -> device
        device_id when is_integer(device_id) -> Repo.get!(Ticketme.Devices.Device, device_id)
      end

    %Ticketme.Accounts.UsersDevices{}
    |> Ticketme.Accounts.UsersDevices.changeset(%{user_id: user.id, device_id: device.id})
    |> Repo.insert(on_conflict: :nothing)
  end

  def create_and_assign_device(user_id, attrs) do
    Repo.transaction(fn ->
      case create_device(attrs) do
        {:ok, device} ->
          case associate_device_with_user(user_id, device) do
            {:ok, _} -> {:ok, device}
            {:error, _} -> Repo.rollback("Failed to associate device with user")
          end

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Dissociates a device from a user.

  ## Examples

      iex> dissociate_device_from_user(user, device)
      {:ok, %User{}}

  """
  def dissociate_device_from_user(%User{} = user, %Device{} = device) do
    user = Repo.preload(user, :devices)
    updated_devices = user.devices |> Enum.reject(&(&1.id == device.id))

    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:devices, updated_devices)
    |> Repo.update()
  end

  @doc """
  Gets a single device by name.

  Returns nil if the Device does not exist.

  ## Examples

      iex> get_device_by_name("My Device")
      %Device{}

      iex> get_device_by_name("Nonexistent Device")
      nil

  """
  def get_device_by_name(name) when is_binary(name) do
    Repo.get_by(Device, device_name: name)
  end

  @doc """
  Gets a single device by MAC address.

  Returns nil if the Device does not exist.

  ## Examples

      iex> get_device_by_mac_address("AA:BB:CC:DD:EE:FF")
      %Device{}

      iex> get_device_by_mac_address("Nonexistent MAC")
      nil

  """
  def get_device_by_mac_address(mac_address) when is_binary(mac_address) do
    Repo.get_by(Device, mac_address: mac_address)
  end

  @doc """
  Assigns an existing device to a user.

  ## Examples

      iex> assign_device_to_user(user, device)
      {:ok, %Device{}}

  """
  def assign_device_to_user(%User{} = user, %Device{} = device) do
    assign_device_to_user_by_id(user.id, device)
  end

  @doc """
  Assigns an existing device to a user.

  ## Examples

      iex> assign_device_to_user(user_id, device)
      {:ok, %Device{}}

  """
  def assign_device_to_user_by_id(user_id, %Device{} = device) when is_integer(user_id) do
    Repo.transaction(fn ->
      case Repo.insert(%UsersDevices{user_id: user_id, device_id: device.id}) do
        {:ok, _} -> {:ok, device}
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end
end
