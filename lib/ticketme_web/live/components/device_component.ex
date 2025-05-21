defmodule TicketmeWeb.DeviceComponent do
  import TicketmeWeb.CoreComponents
  use Phoenix.LiveComponent
  use TicketmeWeb, :verified_routes

  def mount(socket) do
    {:ok, assign(socket, show_delete_modal: false, device_to_delete: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="mt-[140px] px-5 pb-10 w-full">
      <%= if Enum.empty?(@devices) do %>
        <div class="flex flex-col items-center justify-center py-16 text-center">
          <.icon name="hero-device-tablet" class="h-16 w-16 text-gray-300 mb-4" />
          <h3 class="text-xl font-semibold text-gray-700">No devices found</h3>
          <p class="text-gray-500 mt-2 max-w-md">
            You don't have any devices yet. Add a device to start monitoring.
          </p>
        </div>
      <% else %>
        <%= if @view_mode == "grid" do %>
          <div class="grid grid-cols-3 gap-4">
            <%= for device <- @devices do %>
              <%= render_device_grid(device, @myself) %>
            <% end %>
          </div>
        <% else %>
          <table class="min-w-full group bg-[#f9f9f9] rounded-[15px] p-5 shadow-sm hover:shadow-md
               relative transition-all duration-300 hover:bg-[#f1f1f1]">
            <thead>
              <tr class="bg-[#f9f9f9]">
                <th class="py-3 px-6 text-left">Device Name</th>
                <th class="py-3 px-6 text-left">Device Type</th>
                <th class="py-3 px-6 text-left">Status</th>
                <th class="py-3 px-6 text-right"></th>
              </tr>
            </thead>
            <tbody>
              <%= for device <- @devices do %>
                <%= render_device_row(device, @myself) %>
              <% end %>
            </tbody>
          </table>
        <% end %>
      <% end %>
      <%= if @show_delete_modal do %>
        <div class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
          <div class="bg-white p-6 rounded-lg shadow-xl max-w-md w-full mx-4">
            <h3 class="text-lg font-bold mb-4">Delete Device</h3>
            <p class="text-gray-600 mb-6">
              Are you sure you want to delete <%= @device_to_delete %>? This action cannot be undone.
            </p>
            <div class="flex justify-end space-x-4">
              <button
                phx-click="cancel_delete"
                phx-target={@myself}
                class="px-4 py-2 text-gray-600 bg-gray-100 rounded hover:bg-gray-200 transition-colors"
              >
                Cancel
              </button>
              <button
                phx-click="confirm_delete"
                phx-target={@myself}
                class="px-4 py-2 text-white bg-red-500 rounded hover:bg-red-600 transition-colors"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_device_grid(device, myself) do
    assigns = %{device: device, myself: myself}

    ~H"""
    <div
      class="h-[200px] group bg-[#f9f9f9] rounded-[15px] p-5 shadow-sm hover:shadow-md
             relative transition-all duration-300 hover:bg-[#f1f1f1]"
      draggable="true"
      phx-hook="DraggableDevice"
      id={"device-#{@device.device_name}"}
      data-device-id={@device.device_name}
    >
      <%!-- Delete device button --%>
      <button
        phx-click="show_delete_modal"
        phx-value-id={@device.device_name}
        phx-target={@myself}
        class="absolute top-[10px] right-[10px] text-[#e74c3c] hover:text-[#c0392b] opacity-0 group-hover:opacity-100 transition-opacity duration-300 z-10"
      >
        <.icon name="hero-trash" class="h-5 w-5" />
      </button>

      <.link
        navigate={
          ~p"/device_stats?device=#{@device.device_name}&mac_address=#{@device.mac_address}&id=#{@device.id}&device_type=#{@device.device_type}"
        }
        class="flex flex-col justify-center items-center text-center cursor-pointer h-full"
      >
        <img
          src={sensor_image(@device.device_type)}
          class="w-[50px] h-[50px] object-contain"
          style="image-rendering: crisp-edges;"
          alt="Device Image"
        />
        <div class="text-[22px] font-bold mt-[15px] text-gray-800">
          <%= @device.device_name %>
        </div>
        <div class="text-sm text-gray-500 -mt-1 mb-1">
          <%= case @device.device_type do
            "temperature_sensor" -> "Temperature Sensor"
            "humidity_sensor" -> "Humidity Sensor"
            "motion_sensor" -> "Motion Sensor"
            "light_sensor" -> "Light Sensor"
            "camera_sensor" -> "Camera"
            "other" -> "Other"
            _ -> "No sensor"
          end %>
        </div>
        <div class={status_color(@device.status)  <> " text-lg font-medium"}>
          <%= String.capitalize(@device.status) %>
        </div>
        <div class="absolute bottom-[10px] left-[10px] bg-black/50 text-white text-sm px-[5px] py-[5px] rounded opacity-0
                    group-hover:opacity-100 transition-opacity duration-300">
          View Stats
        </div>
      </.link>
    </div>
    """
  end

  # Renders a table row for each device.
  defp render_device_row(device, myself) do
    assigns = %{device: device, myself: myself}

    ~H"""
    <tr class="group relative bg-[#f9f9f9] hover:bg-[#f1f1f1] transition-all duration-300">
      <td class="py-3 px-6 relative">
        <div class="flex items-center">
          <img
            src={sensor_image(@device.device_type)}
            class="w-[25px] h-[25px] mr-4 object-contain"
            style="image-rendering: crisp-edges;"
            alt="Device Image"
          />
          <span class="font-bold text-gray-800 text-lg"><%= @device.device_name %></span>
        </div>
      </td>
      <td class="py-3 px-6 text-gray-500">
        <%= case @device.device_type do
          "temperature_sensor" -> "Temperature Sensor"
          "humidity_sensor" -> "Humidity Sensor"
          "motion_sensor" -> "Motion Sensor"
          "light_sensor" -> "Light Sensor"
          "camera_sensor" -> "Camera"
          _ -> "Other"
        end %>
      </td>
      <td class="py-3 px-6">
        <div class={status_color(@device.status)}>
          <%= String.capitalize(@device.status) %>
        </div>
      </td>
      <td class="py-3 px-6 text-right">
        <div class="flex items-center justify-end space-x-3">
          <button
            id={"copy-id-#{@device.id}"}
            phx-hook="Clipboard"
            data-copy-value={@device.id}
            phx-target={@myself}
            data-prevent-default="true"
            class="text-[#555555] hover:text-[#222020] transition-colors duration-200"
          >
            <.icon name="hero-key" class="h-5 w-5" />
          </button>

          <.link
            navigate={
              ~p"/device_stats?device=#{@device.device_name}&mac_address=#{@device.mac_address}&id=#{@device.id}&device_type=#{@device.device_type}"
            }
            class="text-blue-500 hover:text-blue-700"
          >
            <.icon name="hero-link" class="h-5 w-5" />
          </.link>

          <button
            phx-click="show_delete_modal"
            phx-value-id={@device.device_name}
            phx-target={@myself}
            class="text-[#e74c3c] hover:text-[#c0392b] transition-colors duration-200"
          >
            <.icon name="hero-trash" class="h-5 w-5" />
          </button>
        </div>
      </td>
    </tr>
    """
  end

  def handle_event("show_delete_modal", %{"id" => device_name}, socket) do
    {:noreply, assign(socket, show_delete_modal: true, device_to_delete: device_name)}
  end

  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, show_delete_modal: false, device_to_delete: nil)}
  end

  def handle_event("clipboard_copied", %{"text" => _copied_text}, socket) do
    {:noreply, socket}
  end

  def handle_event("confirm_delete", _, socket) do
    device_name = socket.assigns.device_to_delete

    # Update UI
    send(self(), {:remove_device, device_name})

    case Ticketme.Devices.get_device_by_name(device_name) do
      nil ->
        # No device found
        {:noreply, assign(socket, show_delete_modal: false, device_to_delete: nil)}

      device ->
        # Delete the device
        case Ticketme.Devices.delete_device(device) do
          {:ok, _} ->
            {:noreply, assign(socket, show_delete_modal: false, device_to_delete: nil)}

          {:error, _} ->
            # IO.inspect(error, label: "Error deleting device")
            {:noreply, assign(socket, show_delete_modal: false, device_to_delete: nil)}
        end
    end
  end

  def handle_event("remove_device", %{"id" => device_name}, socket) do
    send(self(), {:remove_device, device_name})
    {:noreply, socket}
  end

  defp sensor_image(device_type) do
    # https://icons8.com/icons (Use 25x25)
    case device_type do
      "temperature_sensor" -> ~p"/images/sensors/temperature-100.png"
      "humidity_sensor" -> ~p"/images/sensors/humidity-100.png"
      "motion_sensor" -> ~p"/images/sensors/motion-sensor-100.png"
      "light_sensor" -> ~p"/images/sensors/light-100.png"
      "camera_sensor" -> ~p"/images/sensors/camera-100.png"
      _ -> ~p"/images/sensors/raspberry-pi-100.png"
    end
  end

  defp status_color("active"), do: "text-[#4caf50]"
  defp status_color("online"), do: "text-[#4caf50]"
  defp status_color("offline"), do: "text-gray-400"
  defp status_color(_), do: "text-gray-500"
end
