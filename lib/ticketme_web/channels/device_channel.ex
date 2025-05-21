defmodule TicketmeWeb.DeviceChannel do
  use Phoenix.Channel

  def join("device:" <> mac_address, _params, socket) do
    Phoenix.PubSub.subscribe(Ticketme.PubSub, "device_commands")
    {:ok, assign(socket, :mac_address, mac_address)}
  end

  # TODO: Add authorization currently accepts any device. Restricted channel using the device_id.

  def handle_in("device_status", %{"mac_address" => mac_address, "status" => status}, socket) do
    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_updates",
      {:device_status_update, mac_address, status}
    )

    {:reply, :ok, socket}
  end

  def handle_in("command_result", %{"mac_address" => mac_address, "result" => result}, socket) do
    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_logs",
      {:command_result, mac_address, result}
    )

    {:reply, :ok, socket}
  end

  def handle_in("system_log", %{"mac_address" => mac_address, "message" => message}, socket) do
    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_logs",
      {:new_log, mac_address, message}
    )

    {:reply, :ok, socket}
  end

  def handle_in("sensor_data", %{"mac_address" => mac_address, "data" => data}, socket) do
    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_updates",
      {:sensor_data, mac_address, data}
    )

    {:reply, :ok, socket}
  end

  def handle_in("heartbeat", _payload, socket) do
    # device_id = socket.assigns.device_id
    # IO.puts("Received heartbeat from device #{device_id}")
    # IO.puts("Full payload: #{inspect(payload)}")

    response = %{
      event: "heartbeat",
      payload: %{status: "ok"}
    }

    # IO.puts("Sending response: #{inspect(response)}")

    {:reply, {:ok, response}, socket}
  end

  def handle_in("webcam_frame", %{"frame" => frame_base64, "mac_address" => mac_address}, socket) do
    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_updates",
      {:webcam_frame, mac_address, %{"frame" => frame_base64}}
    )

    {:reply, :ok, socket}
  end

  def handle_in("keyboard_input", %{"mac_address" => mac_address, "text" => text}, socket) do
    IO.puts("Device channel received keyboard input: #{text} from device #{mac_address}")

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_updates",
      {:keyboard_input, mac_address, text}
    )

    {:reply, :ok, socket}
  end

  def handle_in("keypad-press", %{"mac_address" => mac_address, "key" => key}, socket) do
    IO.puts("Channel received keypad-press: #{key} from #{mac_address}")

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_updates",
      {:keypad_press, mac_address, key}
    )

    {:reply, :ok, socket}
  end

  def handle_in("keypad-clear", %{"mac_address" => mac_address}, socket) do
    IO.puts("Channel received keypad-clear from #{mac_address}")

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_updates",
      {:keypad_clear, mac_address}
    )

    {:reply, :ok, socket}
  end

  def handle_in("keypad-submit", %{"mac_address" => mac_address}, socket) do
    IO.puts("Channel received keypad-submit from #{mac_address}")

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_updates",
      {:keypad_submit, mac_address}
    )

    {:reply, :ok, socket}
  end

  def handle_info({:send_command, mac_address, command}, socket) do
    if mac_address == socket.assigns.mac_address do
      push(socket, "execute_command", %{command: command})
    end

    {:noreply, socket}
  end

  def handle_info({:request_status, requested_mac_address}, socket) do
    if requested_mac_address == socket.assigns.mac_address do
      Phoenix.PubSub.broadcast(
        Ticketme.PubSub,
        "device_updates",
        {:device_status_update, socket.assigns.mac_address, "online"}
      )
    end

    {:noreply, socket}
  end
end
