defmodule Ticketme.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ticketme.Devices` context.
  """

  @doc """
  Generate a unique device device_id.
  """
  def unique_device_device_id, do: "some device_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        device_id: unique_device_device_id(),
        device_name: "some device_name",
        device_type: "some device_type",
        is_active: true,
        last_active_at: ~U[2025-02-26 00:43:00Z]
      })
      |> Ticketme.Devices.create_device()

    device
  end
end
