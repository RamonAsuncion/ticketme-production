defmodule TicketmeWeb.DeviceDashboardLive do
  use TicketmeWeb, :live_view
  import(Phoenix.Component)

  def mount(_params, session, socket) do
    # Initialize empty list of devices

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ticketme.PubSub, "device_updates")
      push_event(socket, "request-local-storage", %{})
    end

    #  https://www.leanpanda.com/blog/authentication-and-authorisation-in-phoenix-liveview/
    socket =
      assign_new(socket, :current_user, fn ->
        with token when not is_nil(token) <- session["user_token"],
             user <- Ticketme.Accounts.get_user_by_session_token(token) do
          user
        else
          _ -> nil
        end
      end)

    # preload devices
    db_devices =
      case socket.assigns.current_user do
        nil ->
          []

        user ->
          user
          |> Ticketme.Repo.preload(:devices)
          |> Map.get(:devices, [])
      end

    # IO.inspect(db_devices, label: "DB Devices")

    devices =
      Enum.map(db_devices, fn device ->
        %{
          id: device.device_id,
          device_name: device.device_name,
          # Include MAC address
          mac_address: device.mac_address,
          status: if(device.is_active, do: "active", else: "inactive"),
          device_type: device.device_type,
          position: 0
        }
      end)

    socket =
      assign(socket,
        show_profile_menu: false,
        show_add_device_modal: false,
        form_errors: [],
        device_form:
          to_form(%{
            "device_name" => "",
            "device_id" => "",
            "device_type" => "",
            "is_active" => false,
            "use_default_image" => true
          })
      )

    if connected?(socket) do
      for device <- devices do
        Phoenix.PubSub.broadcast(
          Ticketme.PubSub,
          "device_commands",
          {:request_status, device.mac_address}
        )
      end
    end

    {:ok,
     assign(socket,
       page_title: "Main",
       devices: devices,
       dragging: nil,
       view_mode: "grid",
       devices_loading: connected?(socket)
     )}
  end

  def render(assigns) do
    # TailwindCSS translated by Nolan Sauers - copied and pasted to the class
    ~H"""
    <%!-- Header --%>
    <div class="grid grid-rows-[auto,1fr] h-screen overflow-auto px-5 py-0">
      <div class="w-full h-[120px] fixed top-0 left-0 bg-white shadow-sm z-50 flex flex-col justify-center px-5">
        <div class="flex justify-between items-center w-full">
          <div class="flex items-center">
            <img src={~p"/images/icon.png"} alt="TicketMe Icon" class="w-[60px] h-[60px] mr-2" />
            <div>
              <div class="text-3xl font-bold text-[#333] font-inter">TicketMe</div>
              <div class="text-base text-[#888] font-inter">IoT Management Portal</div>
            </div>
          </div>
          <%!-- Profile container --%>
          <div class="flex items-center relative">
            <button
              id="col-row-toggle-button"
              phx-click="col-row-toggle"
              phx-hook="ViewModeToggle"
              class="flex items-center justify-center h-10 w-10 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md mr-4 transition-colors duration-200"
              aria-label={
                if @view_mode == "grid", do: "Switch to column view", else: "Switch to grid view"
              }
            >
              <%= if @view_mode == "grid" do %>
                <.icon name="hero-table-cells" class="h-6 w-6 text-gray-600" />
              <% else %>
                <.icon name="hero-view-columns" class="h-6 w-6 text-gray-600" />
              <% end %>
            </button>
            <button
              phx-click="open_add_device_modal"
              class="flex items-center justify-center h-10 w-10 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md mr-4 transition-colors duration-200"
              aria-label="Add device"
            >
              <.icon name="hero-plus" class="h-6 w-6" />
            </button>

            <div class="relative">
              <div phx-click="toggle_profile_menu">
                <.initials_avatar
                  first_name={@current_user.first_name || "?"}
                  last_name={@current_user.last_name || "?"}
                  class="w-[40px] h-[40px] cursor-pointer hover:opacity-80 select-none"
                />
              </div>

              <%= if @show_profile_menu do %>
                <div class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50">
                  <%= if @current_user do %>
                    <div class="px-4 py-3 border-b">
                      <span class="block text-sm font-semibold text-gray-900">
                        <%= @current_user.first_name %> <%= @current_user.last_name %>
                      </span>
                      <span class="block text-sm text-gray-500 truncate">
                        <%= @current_user.email %>
                      </span>
                    </div>
                    <.link
                      href={~p"/users/settings"}
                      class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                    >
                      Settings
                    </.link>
                    <.link
                      href={~p"/users/log_out"}
                      method="delete"
                      class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                    >
                      Sign out
                    </.link>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
      <.live_component
        module={TicketmeWeb.DeviceComponent}
        id="devices"
        devices={@devices}
        view_mode={@view_mode}
        loading={@devices_loading}
      />
      <%!-- Add device modal --%>
      <%= if @show_add_device_modal do %>
        <div
          id="device-crud-modal"
          class="overflow-y-auto overflow-x-hidden fixed inset-0 z-50 flex justify-center items-center w-full h-full bg-black bg-opacity-50"
        >
          <div class="relative p-4 w-full max-w-md max-h-full">
            <%!-- Modal content --%>
            <div class="relative bg-white rounded-lg shadow-sm">
              <%!-- Modal header --%>
              <div class="flex items-center justify-between p-4 md:p-5 border-b rounded-t border-gray-200">
                <h3 class="text-lg font-semibold text-gray-900">
                  Add New Device
                </h3>
                <button
                  type="button"
                  phx-click="close_add_device_modal"
                  class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center"
                >
                  <svg
                    class="w-3 h-3"
                    aria-hidden="true"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 14 14"
                  >
                    <path
                      stroke="currentColor"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
                    />
                  </svg>
                  <span class="sr-only">Close modal</span>
                </button>
              </div>

              <%!-- Modal body --%>
              <.form for={@device_form} phx-submit="save_device" class="p-4 md:p-5">
                <%= if @form_errors && length(@form_errors) > 0 do %>
                  <div class="mb-4 p-4 border border-red-300 bg-red-50 rounded-md">
                    <h4 class="text-red-800 font-medium mb-1">
                      <span class="inline-flex items-center">
                        <.icon name="hero-exclamation-circle" class="w-4 h-4 mr-1.5" />
                        Unable to create device
                      </span>
                    </h4>
                    <ul classG="list-disc pl-5 text-sm text-red-700">
                      <%= for error <- @form_errors do %>
                        <li><%= error %></li>
                      <% end %>
                    </ul>
                  </div>
                <% end %>
                <div class="grid gap-4 mb-4 grid-cols-2">
                  <div class="col-span-2">
                    <label for="device_name" class="block mb-2 text-sm font-medium text-gray-900">
                      Device Name
                    </label>
                    <.input
                      id="device_name"
                      name="device_name"
                      type="text"
                      required
                      class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                      placeholder="Enter device name"
                      value={@device_form[:device_name].value}
                    />
                  </div>

                  <div class="col-span-2">
                    <label for="mac_address" class="block mb-2 text-sm font-medium text-gray-900">
                      MAC Address
                    </label>
                    <.input
                      id="mac_address"
                      name="mac_address"
                      type="text"
                      required
                      class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                      placeholder="Enter MAC address (e.g., AA:BB:CC:DD:EE:FF)"
                      value={@device_form[:mac_address].value}
                    />
                  </div>

                  <div class="col-span-2 sm:col-span-1">
                    <label for="device_type" class="block mb-2 text-sm font-medium text-gray-900">
                      Device Type
                    </label>
                    <select
                      name="device_type"
                      id="device_type"
                      class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                      disabled={
                        not is_nil(@device_form[:device_id].value) and
                          @device_form[:device_id].value != ""
                      }
                    >
                      <option
                        value="temperature_sensor"
                        selected={@device_form[:device_type].value == "temperature_sensor"}
                      >
                        Temperature Sensor
                      </option>
                      <option
                        value="humidity_sensor"
                        selected={@device_form[:device_type].value == "humidity_sensor"}
                      >
                        Humidity Sensor
                      </option>
                      <option
                        value="motion_sensor"
                        selected={@device_form[:device_type].value == "motion_sensor"}
                      >
                        Motion Sensor
                      </option>
                      <option
                        value="light_sensor"
                        selected={@device_form[:device_type].value == "light_sensor"}
                      >
                        Light Sensor
                      </option>
                      <option
                        value="camera_sensor"
                        selected={@device_form[:device_type].value == "camera_sensor"}
                      >
                        Camera
                      </option>
                      <option value="other" selected={@device_form[:device_type].value == "other"}>
                        Other
                      </option>
                    </select>
                  </div>
                  <div class="col-span-2 sm:col-span-1">
                    <label for="device_id" class="block mb-2 text-sm font-medium text-gray-900">
                      Device ID
                    </label>
                    <.input
                      id="device_id"
                      name="device_id"
                      type="text"
                      class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                      placeholder="Enter device ID"
                      value={@device_form[:device_id].value}
                      phx-change="validate_device_form"
                    />
                    <p class="text-xs text-gray-500 mt-1">
                      Leave empty for new device or enter ID to connect existing
                    </p>
                  </div>
                </div>

                <div class="flex items-center justify-end space-x-4">
                  <button
                    type="button"
                    phx-click="close_add_device_modal"
                    class="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-blue-300 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    class="text-white inline-flex items-center bg-[#ff9f68] hover:bg-[#ff8c4c] focus:ring-4 focus:outline-none focus:ring-[#ff9f68]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center"
                  >
                    <svg
                      class="me-1 -ms-1 w-5 h-5"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z"
                        clip-rule="evenodd"
                      >
                      </path>
                    </svg>
                    Add Device
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def initials_avatar(assigns) do
    ~H"""
    <div class={[
      "flex items-center justify-center rounded-full bg-gray-200 text-gray-700",
      @class
    ]}>
      <span class="text-sm font-medium">
        <%= String.first(@first_name) %><%= String.first(@last_name) %>
      </span>
    </div>
    """
  end

  def handle_info({:device_status_update, mac_address, status}, socket) do
    normalized_status =
      case status do
        "online" -> "active"
        other -> other
      end

    devices =
      Enum.map(socket.assigns.devices, fn device ->
        if device.mac_address == mac_address do
          %{device | status: normalized_status}
        else
          device
        end
      end)

    {:noreply, assign(socket, devices: devices)}
  end

  def handle_info({:add_device, new_device}, socket) do
    # Log new device addition
    # IO.inspect(new_device, label: "New Device Added")

    # Append the new device to the existing device list
    updated_devices = [new_device | socket.assigns.devices]
    {:noreply, assign(socket, devices: updated_devices)}
  end

  def handle_info({:remove_device, device_name}, socket) do
    devices =
      Enum.filter(socket.assigns.devices, fn device -> device.device_name != device_name end)

    {:noreply, assign(socket, devices: devices)}
  end

  # HomeLive
  # device creation logic and management

  # DeviceComponent
  # UI rendering of devices
  # user interactions with existing devices
  # event forwarding to parent

  def handle_event("validate_device_form", %{"device_id" => device_id} = params, socket) do
    # Updating the form state based on the changes of device ID.
    # This allows me to use the disable attribute on the device type dropdown.
    # IO.inspect(params["device_type"], label: "device_type")

    device_form =
      %{
        "device_name" => params["device_name"],
        "device_id" => device_id,
        "mac_address" => params["mac_address"],
        "device_type" => params["device_type"],
        "is_active" => false
      }
      |> to_form()

    {:noreply, assign(socket, device_form: device_form)}
  end

  def handle_event("save_device", device_params, socket) do
    # Default device_id uses the mac address (with no colons)
    # to create new device it checks if device with mac address exists
    # if mac address exists it associates the device with current user
    # no device with mac address then it create one.
    device_name = device_params["device_name"]
    mac_address = device_params["mac_address"]

    if is_nil(mac_address) or mac_address == "" do
      # Generate a fallback MAC or return error
      {:noreply, assign(socket, form_errors: ["MAC address is required"])}
    else
      # Mac address should be unique.
      device_id =
        if is_nil(device_params["device_id"]) or device_params["device_id"] == "",
          do: String.replace(mac_address, ":", "") |> String.downcase(),
          else: device_params["device_id"]

      #  Create device attributes
      device_attrs = %{
        device_name: device_name,
        device_id: device_id,
        mac_address: mac_address,
        device_type: device_params["device_type"],
        is_active: false,
        last_active_at: DateTime.utc_now()
      }

      # Debugging
      # IO.inspect(device_params, label: "Device Params")
      # Debugging
      # IO.inspect(device_attrs, label: "Device Attributes")

      # First check if there's already a device with this MAC address
      existing_device = Ticketme.Devices.get_device_by_mac_address(mac_address)

      case existing_device do
        %Ticketme.Devices.Device{} = device ->
          # Device with this MAC address already exists, connect it to the user
          case Ticketme.Devices.assign_device_to_user_by_id(
                 socket.assigns.current_user.id,
                 device
               ) do
            {:ok, _} ->
              new_device = %{
                device_name: Map.get(device, :device_name, device_name),
                id: device.device_id,
                mac_address: device.mac_address,
                status: "unknown",
                device_type: device.device_type
              }

              send(self(), {:add_device, new_device})
              {:noreply, assign(socket, show_add_device_modal: false)}

            {:error, _} ->
              # IO.inspect(reason, label: "Error connecting existing device")
              {:noreply, socket |> put_flash(:error, "Failed to connect to existing device.")}
          end

        nil ->
          # No device with this MAC address exists, create a new one
          case Ticketme.Devices.create_and_assign_device(
                 socket.assigns.current_user.id,
                 device_attrs
               ) do
            {:ok, {:ok, device}} when is_map(device) ->
              #  Debugging
              # IO.inspect(device, label: "Created Device")

              new_device = %{
                device_name: Map.get(device, :device_name, device_name),
                id: device.device_id,
                mac_address: device.mac_address,
                status: "unknown",
                device_type: device.device_type,
                position: length(socket.assigns.devices)
              }

              send(self(), {:add_device, new_device})
              {:noreply, assign(socket, show_add_device_modal: false)}

            {:error, %Ecto.Changeset{} = changeset} ->
              errors = format_changeset_errors(changeset)
              # IO.inspect(errors, label: "Formatted Errors")
              {:noreply, assign(socket, form_errors: errors)}

            {:error, _} ->
              # IO.inspect(reason, label: "Error Creating Device")
              {:noreply, socket |> put_flash(:error, "Failed to add device. Please try again.")}
          end
      end
    end
  end

  def handle_event("close_add_device_modal", _params, socket) do
    {:noreply, assign(socket, show_add_device_modal: false, form_errors: [])}
  end

  def handle_event("set-view-mode", %{"view_mode" => view_mode}, socket) do
    {:noreply, assign(socket, :view_mode, view_mode)}
  end

  def handle_event("col-row-toggle", _params, socket) do
    new_mode = if socket.assigns.view_mode == "grid", do: "column", else: "grid"

    push_event(socket, "update-local-storage", %{view_mode: new_mode})

    {:noreply, assign(socket, :view_mode, new_mode)}
  end

  def handle_event("open_add_device_modal", _params, socket) do
    IO.puts("Opening device modal.")
    {:noreply,
     assign(socket,
       show_add_device_modal: true,
       form_errors: [],
       device_form:
         to_form(%{
           "device_name" => "",
           "device_id" => "",
           "mac_address" => "",
           "device_type" => "",
           "is_active" => false,
           "use_default_image" => true
         })
     )}
  end

  def handle_event("toggle_profile_menu", _, socket) do
    {:noreply, assign(socket, show_profile_menu: !socket.assigns.show_profile_menu)}
  end

  def handle_event("drag_start", %{"device" => device_id}, socket) do
    {:noreply, assign(socket, dragging: device_id)}
  end

  def handle_event("request-local-storage", %{"view_mode" => view_mode}, socket) do
    {:noreply, assign(socket, :view_mode, view_mode)}
  end

  def handle_event("drop", %{"device" => target_id, "source" => source_id}, socket) do
    devices = socket.assigns.devices

    # Find the index of the source and target devices
    source_idx = Enum.find_index(devices, fn device -> device.device_name == source_id end)
    target_idx = Enum.find_index(devices, fn device -> device.device_name == target_id end)

    if source_idx && target_idx do
      # Swap the devices
      devices =
        List.replace_at(devices, source_idx, Enum.at(devices, target_idx))
        |> List.replace_at(target_idx, Enum.at(devices, source_idx))

      {:noreply, assign(socket, devices: devices)}
    else
      {:noreply, socket}
    end
  end

  # https://elixirforum.com/t/collecting-and-formatting-changeset-errors/20191/3
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, errors} ->
      field_name = Phoenix.Naming.humanize(field)
      "#{field_name} #{Enum.join(errors, ", ")}"
    end)
  end
end
