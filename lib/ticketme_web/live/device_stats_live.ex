defmodule TicketmeWeb.DeviceStatsLive do
  use TicketmeWeb, :live_view

  import LiveViewDashboardWeb.Components.DynamicChartComponent
  import LiveViewDashboardWeb.Components.MatrixControllerComponent
  import LiveViewDashboardWeb.Components.KeyboardControllerComponent
  import LiveViewDashboardWeb.Components.WebcamDisplayComponent
  import LiveViewDashboardWeb.Components.ToggleComponent
  import LiveViewDashboardWeb.Components.KeypadComponent

  @commands [
    %{command: "show memory", description: "Display system memory usage", exec: "free -h"},
    %{command: "show cpu", description: "Display CPU information", exec: "lscpu"},
    %{command: "show disk", description: "Show disk usage", exec: "df -h"},
    %{command: "show network", description: "Display network interfaces", exec: "ip addr"},
    %{command: "show processes", description: "List running processes", exec: "ps aux"},
    %{command: "reboot", description: "Reboot the device", exec: "sudo reboot", privileged: true},
    %{
      command: "cpu usage",
      description: "Get current CPU usage percentage",
      exec: "top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4\"%\"}'"
    },
    %{command: "cpu cores", description: "Get CPU core count", exec: "nproc"},
    %{
      command: "cpu freq",
      description: "Get CPU frequency",
      exec:
        "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null | awk '{printf \"%.0f MHz\", $1/1000}' || echo 'N/A'"
    },
    %{
      command: "cpu temp",
      description: "Get CPU temperature",
      exec: "vcgencmd measure_temp | cut -d= -f2 || echo 'N/A'"
    }
  ]

  def mount(params, _session, socket) do
    # from URL
    device_name = params["device"]
    mac_address = params["mac_address"]
    device_type = params["device_type"] || "unknown"

    # IO.puts("Device Stats mounted for device: #{device_name}")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ticketme.PubSub, "device_logs")
      Phoenix.PubSub.subscribe(Ticketme.PubSub, "device_updates")

      # Get device status on mount.
      Phoenix.PubSub.broadcast(
        Ticketme.PubSub,
        "device_commands",
        {:request_status, mac_address}
      )
    end

    {:ok,
     assign(socket,
       page_title: "Device Stats",
       keyboard_text: "",
       keyboard_active: false,
       device_name: device_name,
       mac_address: mac_address,
       device_type: device_type,
       modules: [],
       logs: [],
       command: "",
       device_status: "unknown",
       display_text: "",
       text_color: "#FF00FF",
       background_color: "#003200",
       speed: 10,
       y_pos: 22,
       selected_font: "9x18.bdf",
       matrix_rows: 64,
       matrix_cols: 64,
       available_modules: [
         %{
           id: "generic-chart",
           name: "Data Chart",
           type: "chart",
           icon: "hero-chart-bar"
         },
         %{
           id: "matrix-controller",
           name: "LED Matrix Controller",
           type: "matrixController",
           icon: "hero-document-text"
         },
         %{
           id: "text-display",
           name: "Keyboard Input",
           type: "textDisplay",
           icon: "hero-document-text"
         },
         %{
           id: "accessory-controls",
           name: "Accessory Controls",
           type: "accessoryControls",
           icon: "hero-adjustments-horizontal"
         },
         %{
           id: "webcam-feed",
           name: "Camera Feed",
           type: "webcamFeed",
           icon: "hero-video-camera"
         },
         %{
           id: "keypad-security",
           name: "Security Keypad",
           type: "keypad",
           icon: "hero-lock-closed"
         }
       ],
       current_input: "",
       locked_out: false,
       lockout_remaining: 0,
       lockout_timer_ref: nil,
       attempts: 0,
       is_unlocked: false,
       message: nil,
       correct_code: "1234",
       max_attempts: 5,
       metrics: [],
       available_sensors: [],
       active_sensors: [],
       sensor_data: %{},
       metrics_history_limit: 10,
       active_components: [],
       webcam_frame: nil,
       accessories: [
         %{
           id: "led_1",
           label: "Main LED",
           status: false,
           type: "led",
           color: "#FFCC00",
           location: "GPIO 18",
           description: "Main indicator light"
         },
         %{
           id: "led_2",
           label: "Status LED",
           status: false,
           type: "led",
           color: "#00CCFF",
           location: "GPIO 23",
           description: "System status indicator"
         },
         %{
           id: "relay_1",
           label: "Relay",
           status: false,
           type: "relay",
           color: "#FF5500",
           location: "GPIO 24",
           description: "Power control relay"
         },
         %{
           id: "buzzer_1",
           label: "Buzzer",
           status: false,
           type: "buzzer",
           color: "#CC00FF",
           location: "GPIO 25",
           description: "Alert sound"
         }
       ]
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen flex flex-col">
      <div class="flex flex-col md:flex-row flex-1 gap-5 p-5 overflow-hidden">
        <%!-- Main Content Area --%>
        <div class="flex-1 flex flex-col gap-5 min-w-0">
          <%!-- Device Info --%>
          <div class="flex-1 flex flex-col bg-gray-50 border border-gray-200 rounded-lg overflow-hidden min-h-0">
            <div class="p-5 border-b border-gray-200">
              <div class="flex items-center gap-4">
                <button
                  class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition-colors text-sm"
                  phx-click="back"
                >
                  Back
                </button>
                
                <%!-- playing around with indicators https://flowbite.com/docs/components/indicators/ --%>
                <h1 class="text-2xl font-bold text-gray-800 flex items-center gap-2">
                  <%= @device_name %>
                  <div class="flex items-center">
                    <span class={"flex w-3 h-3 #{status_color(@device_status)} rounded-full"}></span>
                  </div>
                </h1>
                
                <div class="text-sm text-gray-500 mt-1">
                  <%= format_device_type(@device_type) %>
                </div>
              </div>
            </div>
            
            <div class="flex-1 p-5 overflow-y-auto">
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <%= for component_id <- @active_components do %>
                  <%= case component_id do %>
                    <% "chart" -> %>
                      <div class="lg:col-span-2 bg-white rounded-lg shadow-sm p-4 min-h-[300px]">
                        <%!-- <.chart metrics={@metrics} /> --%>
                        <.chart
                          metrics={@metrics}
                          available_sensors={@available_sensors}
                          active_sensors={@active_sensors}
                        />
                      </div>
                    <% "accessories" -> %>
                      <div class="lg:col-span-2 bg-white rounded-lg shadow-sm p-4 min-h-[300px]">
                        <div class="flex items-center justify-between mb-4">
                          <h3 class="text-lg font-bold text-gray-800">Device Accessories</h3>
                        </div>
                         <.accessory_grid accessories={@accessories} />
                      </div>
                    <% "matrix" -> %>
                      <div class="min-h-[350px] min-w-[250px]">
                        <.matrix_controller_display
                          text={@display_text}
                          color={@text_color}
                          background={@background_color}
                          speed={@speed}
                          y_pos={@y_pos}
                          font={@selected_font}
                          rows={@matrix_rows}
                          cols={@matrix_cols}
                        />
                      </div>
                    <% "keyboard" -> %>
                      <div class="min-h-[250px] min-w-[250px]">
                        <.keyboard_controller_display keyboard_text={@keyboard_text} />
                      </div>
                    <% "webcam" -> %>
                      <div class="min-h-[300px] min-w-[300px]">
                        <.webcam_display
                          webcam_frame={@webcam_frame}
                          streaming={@streaming}
                          device_name={@device_name}
                        />
                      </div>
                    <% "keypad" -> %>
                      <div class="min-h-[350px] min-w-[250px]">
                        <.keypad_display
                          id="security-keypad"
                          phx-hook="KeypadController"
                          current_input={@current_input}
                          attempts={@attempts}
                          is_unlocked={@is_unlocked}
                          message={@message}
                          correct_code={@correct_code}
                          max_attempts={@max_attempts}
                          locked_out={@locked_out}
                          lockout_remaining={@lockout_remaining}
                        />
                      </div>
                    <% _ -> %>
                  <% end %>
                <% end %>
              </div>
              
              <%!-- <div class="rounded-lg p-3 min-h-[150px]" id="column-3" data-status="3"></div> --%>
            </div>
             <%!-- #TODO: Have an icon on the far right of the section to maximize and minimize.--%>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"></div>
          </div>
           <%!-- System Logs --%>
          <div class="h-[200px] flex flex-col border border-gray-200 bg-gray-50 rounded-lg overflow-hidden">
            <div class="p-4 border-b border-gray-200">
              <div class="text-sm font-bold text-gray-800">System Logs</div>
            </div>
            
            <div class="flex-1 p-4 overflow-y-auto">
              <div class="bg-white rounded-lg p-3 text-xs h-full">
                <div class="space-y-1 h-full">
                  <%= for log <- @logs do %>
                    <div class="py-1 border-b border-gray-100 last:border-0">
                      <%!-- Preserving whitespace: https://tailwindcss.com/docs/white-space --%> <pre class="whitespace-pre-wrap font-mono text-gray-700"><%= log %></pre>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
           <%!-- Terminal --%>
          <div class="border border-gray-200 bg-gray-50 rounded-lg p-4">
            <div class="relative">
              <form
                phx-submit="execute_command"
                class="flex items-center bg-white rounded border border-gray-200"
              >
                <.icon name="hero-chevron-right" class="w-4 h-4 text-gray-400 ml-2 shrink-0" />
                <input
                  type="text"
                  name="command"
                  value={@command}
                  class="w-full px-2 py-1.5 text-sm border-none focus:ring-0 font-mono text-gray-700"
                  placeholder="Type 'help' to see available commands..."
                />
              </form>
            </div>
          </div>
        </div>
         <%!-- Sidebar --%>
        <div class="w-full md:w-[250px] flex flex-col min-h-0">
          <div class="flex-1 border border-gray-200 bg-gray-50 p-5 rounded-lg">
            <h3 class="font-bold text-sm mb-3">Available Modules</h3>
            
            <div class="space-y-2 overflow-y-auto">
              <%= for module <- @available_modules do %>
                <%= if module.name == "Data Chart" do %>
                  <button
                    phx-click="toggle_component_1"
                    id={"module-#{module.id}"}
                    class="w-full flex items-center gap-2 p-3 bg-white rounded-lg border border-gray-200 hover:border-blue-500 transition-colors text-left"
                  >
                    <.icon name={module.icon} class="w-5 h-5 text-gray-500" />
                    <span class="text-sm font-medium text-gray-700">
                      <%= if "chart" in @active_components, do: "Remove ", else: "Add " %><%= module.name %>
                    </span>
                  </button>
                <% end %>
                
                <%= if module.name == "LED Matrix Controller" do %>
                  <button
                    phx-click="toggle_component_2"
                    id={"module-#{module.id}"}
                    class="w-full flex items-center gap-2 p-3 bg-white rounded-lg border border-gray-200 hover:border-blue-500 transition-colors text-left"
                  >
                    <.icon name={module.icon} class="w-5 h-5 text-gray-500" />
                    <span class="text-sm font-medium text-gray-700">
                      <%= if "matrix" in @active_components, do: "Remove ", else: "Add " %><%= module.name %>
                    </span>
                  </button>
                <% end %>
                
                <%= if module.name == "Keyboard Input" do %>
                  <button
                    phx-click="toggle_component_3"
                    id={"module-#{module.id}"}
                    class="w-full flex items-center gap-2 p-3 bg-white rounded-lg border border-gray-200 hover:border-blue-500 transition-colors text-left"
                  >
                    <.icon name={module.icon} class="w-5 h-5 text-gray-500" />
                    <span class="text-sm font-medium text-gray-700">
                      <%= if "keyboard" in @active_components, do: "Remove ", else: "Add " %><%= module.name %>
                    </span>
                  </button>
                <% end %>
                
                <%= if module.name == "Camera Feed" do %>
                  <button
                    phx-click="toggle_component_4"
                    id={"module-#{module.id}"}
                    class="w-full flex items-center gap-2 p-3 bg-white rounded-lg border border-gray-200 hover:border-blue-500 transition-colors text-left"
                  >
                    <.icon name={module.icon} class="w-5 h-5 text-gray-500" />
                    <span class="text-sm font-medium text-gray-700">
                      <%= if "webcam" in @active_components, do: "Remove ", else: "Add " %><%= module.name %>
                    </span>
                  </button>
                <% end %>
                
                <%= if module.name == "Accessory Controls" do %>
                  <button
                    phx-click="toggle_component_5"
                    id={"module-#{module.id}"}
                    class="w-full flex items-center gap-2 p-3 bg-white rounded-lg border border-gray-200 hover:border-blue-500 transition-colors text-left"
                  >
                    <.icon name={module.icon} class="w-5 h-5 text-gray-500" />
                    <span class="text-sm font-medium text-gray-700">
                      <%= if "accessories" in @active_components, do: "Remove ", else: "Add " %><%= module.name %>
                    </span>
                  </button>
                <% end %>
                
                <%= if module.name == "Security Keypad" do %>
                  <button
                    phx-click="toggle_component_6"
                    id={"module-#{module.id}"}
                    class="w-full flex items-center gap-2 p-3 bg-white rounded-lg border border-gray-200 hover:border-blue-500 transition-colors text-left"
                  >
                    <.icon name={module.icon} class="w-5 h-5 text-gray-500" />
                    <span class="text-sm font-medium text-gray-700">
                      <%= if "keypad" in @active_components, do: "Remove ", else: "Add " %><%= module.name %>
                    </span>
                  </button>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def log_message(message, socket) do
    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y-%m-%d %H:%M:%S")
    new_log = "#{timestamp} system: #{message}"

    {:noreply,
     socket
     |> update(:logs, fn logs -> [new_log | logs] end)
     |> assign(command: "")}
  end

  defp format_metrics_for_chart(sensor_data, active_sensors, available_sensors) do
    # Get timestamps (x-axis) from the first active sensor, or empty if none
    timestamps =
      case Enum.find(active_sensors, fn id -> Map.has_key?(sensor_data, id) end) do
        nil ->
          []

        sensor_id ->
          sensor_data
          |> Map.get(sensor_id, [])
          |> Enum.map(& &1.time)
          |> Enum.reverse()
      end

    # Get sensor data series
    series =
      active_sensors
      |> Enum.map(fn sensor_id ->
        sensor_info = Enum.find(available_sensors, fn s -> s.id == sensor_id end)

        values =
          sensor_data
          |> Map.get(sensor_id, [])
          |> Enum.map(& &1.value)
          |> Enum.reverse()

        %{
          id: sensor_id,
          label: "#{sensor_info.name} (#{sensor_info.unit})",
          data: values,
          color: sensor_info.color
        }
      end)

    %{
      timestamps: timestamps,
      series: series
    }
  end

  # Used help of ChatGPT to generate the chart data.

  def handle_info({:sensor_data, device_mac, data}, socket)
      when device_mac == socket.assigns.mac_address do
    # Get current timestamp for chart display
    # display_time = DateTime.utc_now() |> Calendar.strftime("%H:%M:%S")
    display_time = DateTime.utc_now() |> Calendar.strftime("%m-%d %H:%M")

    # Update available sensors list if new sensors found
    available_sensors =
      if socket.assigns.available_sensors == [] and Map.has_key?(data, "sensors") do
        data["sensors"]
        |> Map.keys()
        |> Enum.map(fn sensor_id ->
          sensor_info = data["sensors"][sensor_id]

          %{
            id: sensor_id,
            name: sensor_info["name"],
            unit: sensor_info["unit"],
            color: sensor_info["color"]
          }
        end)
      else
        socket.assigns.available_sensors
      end

    # Update active sensors if empty and sensors are available
    active_sensors =
      if socket.assigns.active_sensors == [] and available_sensors != [] do
        # Activate first sensor by default (even when all of them are unselected)
        [List.first(available_sensors).id]
      else
        socket.assigns.active_sensors
      end

    # Get updated readings
    readings = Map.get(data, "readings", %{})

    # Update sensor data history (limited to last metrics_history_limit points)
    sensor_data =
      socket.assigns.sensor_data
      |> Map.new(fn {sensor_id, history} ->
        if Map.has_key?(readings, sensor_id) do
          {
            sensor_id,
            # Take only the maximum amount of points defined by the metrics_history_limit.
            Enum.take(
              [%{value: readings[sensor_id], time: display_time} | history],
              socket.assigns.metrics_history_limit
            )
          }
        else
          {sensor_id, history}
        end
      end)

    sensor_data =
      readings
      |> Map.keys()
      |> Enum.reduce(sensor_data, fn sensor_id, acc ->
        if Map.has_key?(acc, sensor_id) do
          acc
        else
          Map.put(acc, sensor_id, [%{value: readings[sensor_id], time: display_time}])
        end
      end)

    metrics = format_metrics_for_chart(sensor_data, active_sensors, available_sensors)

    {:noreply,
     assign(socket,
       sensor_data: sensor_data,
       available_sensors: available_sensors,
       active_sensors: active_sensors,
       metrics: metrics
     )}
  end

  def handle_event("toggle_accessory", %{"id" => id, "type" => type}, socket) do
    accessories = socket.assigns.accessories
    mac_address = socket.assigns.mac_address

    # Find the accessory and toggle its status
    updated_accessories =
      Enum.map(accessories, fn accessory ->
        if accessory.id == id do
          new_status = !accessory.status
          command = "#{type}_control:#{id}:#{if new_status, do: "on", else: "off"}"

          # Send command to device
          Phoenix.PubSub.broadcast(
            Ticketme.PubSub,
            "device_commands",
            {:send_command, mac_address, command}
          )

          # Log the action
          message =
            "Setting #{accessory.label} (#{accessory.location}) to #{if new_status, do: "ON", else: "OFF"}"

          log_message(message, socket)

          # Return updated accessory
          %{accessory | status: new_status}
        else
          accessory
        end
      end)

    {:noreply, assign(socket, accessories: updated_accessories)}
  end

  def handle_event("toggle_sensor", %{"id" => sensor_id}, socket) do
    active_sensors = socket.assigns.active_sensors

    new_active_sensors =
      if sensor_id in active_sensors do
        List.delete(active_sensors, sensor_id)
      else
        active_sensors ++ [sensor_id]
      end

    metrics =
      format_metrics_for_chart(
        socket.assigns.sensor_data,
        new_active_sensors,
        socket.assigns.available_sensors
      )

    {:noreply, assign(socket, active_sensors: new_active_sensors, metrics: metrics)}
  end

  def handle_event("toggle_component_1", _params, socket) do
    active_components = socket.assigns.active_components
    comp_id = "chart"
    mac_address = socket.assigns.mac_address

    new_active_components =
      if comp_id in active_components do
        # https://hexdocs.pm/elixir/1.15.8/List.html#:~:text=delete(list%2C%20element),-View%20Source&text=%3A%3A%20list()-,Deletes%20the%20given%20element%20from%20the%20list%20.,the%20first%20occurrence%20is%20removed.
        List.delete(active_components, comp_id)
      else
        # https://stackoverflow.com/questions/35528875/add-new-element-to-list
        active_components ++ [comp_id]
      end

    new_state = comp_id in new_active_components
    command = if new_state, do: "start_sensors", else: "stop_sensors"

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, mac_address, command}
    )

    {:noreply,
     assign(socket,
       active_components: new_active_components,
       show_component_1: new_state
     )}
  end

  def handle_event("toggle_component_2", _params, socket) do
    active_components = socket.assigns.active_components
    comp_id = "matrix"
    # mac_address = socket.assigns.mac_address

    new_active_components =
      if comp_id in active_components do
        List.delete(active_components, comp_id)
      else
        active_components ++ [comp_id]
      end

    # Keep the existing behavior for controlling the device
    show_matrix = comp_id in new_active_components

    {:noreply,
     assign(socket,
       active_components: new_active_components,
       show_component_2: show_matrix
     )}
  end

  def handle_event("toggle_component_3", _params, socket) do
    active_components = socket.assigns.active_components
    comp_id = "keyboard"
    mac_address = socket.assigns.mac_address

    new_active_components =
      if comp_id in active_components do
        List.delete(active_components, comp_id)
      else
        active_components ++ [comp_id]
      end

    new_state = comp_id in new_active_components
    command = if new_state, do: "start_keyboard", else: "stop_keyboard"

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, mac_address, command}
    )

    {:noreply,
     assign(socket,
       active_components: new_active_components,
       show_component_3: new_state
     )}
  end

  def handle_event("toggle_component_4", _params, socket) do
    active_components = socket.assigns.active_components
    comp_id = "webcam"
    mac_address = socket.assigns.mac_address

    new_active_components =
      if comp_id in active_components do
        List.delete(active_components, comp_id)
      else
        active_components ++ [comp_id]
      end

    new_state = comp_id in new_active_components
    command = if new_state, do: "start_webcam", else: "stop_webcam"

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, mac_address, command}
    )

    {:noreply,
     assign(socket,
       active_components: new_active_components,
       show_component_4: new_state,
       streaming: new_state
     )}
  end

  def handle_event("toggle_component_5", _params, socket) do
    active_components = socket.assigns.active_components
    comp_id = "accessories"

    new_active_components =
      if comp_id in active_components do
        List.delete(active_components, comp_id)
      else
        active_components ++ [comp_id]
      end

    {:noreply, assign(socket, active_components: new_active_components)}
  end

  def handle_event("start_keyboard", _params, socket) do
    mac_address = socket.assigns.mac_address
    IO.puts("Manually starting keyboard for #{mac_address}")

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, mac_address, "start_keyboard"}
    )

    {:noreply, assign(socket, keyboard_active: true)}
  end

  def handle_event("toggle_component_6", _params, socket) do
    active_components = socket.assigns.active_components
    comp_id = "keypad"
    mac_address = socket.assigns.mac_address

    new_active_components =
      if comp_id in active_components do
        List.delete(active_components, comp_id)
      else
        active_components ++ [comp_id]
      end

    new_state = comp_id in new_active_components
    command = if new_state, do: "start_keypad", else: "stop_keypad"

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, mac_address, command}
    )

    {:noreply, assign(socket, active_components: new_active_components)}
  end

  def handle_event("stop_keyboard", _params, socket) do
    mac_address = socket.assigns.mac_address
    IO.puts("Manually stopping keyboard for #{mac_address}")

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, mac_address, "stop_keyboard"}
    )

    {:noreply, assign(socket, keyboard_active: false)}
  end

  # Duplicate of start / stop keyboard but for webcam.
  def handle_event("toggle_webcam", _params, socket) do
    streaming = not socket.assigns.streaming
    mac_address = socket.assigns.mac_address

    command = if streaming, do: "start_webcam", else: "stop_webcam"

    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, mac_address, command}
    )

    {:noreply, assign(socket, streaming: streaming)}
  end

  def handle_event("back", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  def handle_event("update_display_text", %{"text" => text}, socket) do
    {:noreply, assign(socket, display_text: text)}
  end

  def handle_event("update_display_settings", params, socket) do
    socket =
      socket
      |> maybe_update_param(params, "color", :text_color)
      |> maybe_update_param(params, "background", :background_color)
      |> maybe_update_param(params, "speed", :speed, &parse_integer/1)
      |> maybe_update_param(params, "y_pos", :y_pos, &parse_integer/1)
      |> maybe_update_param(params, "font", :selected_font)
      |> maybe_update_param(params, "rows", :matrix_rows, &parse_integer/1)
      |> maybe_update_param(params, "cols", :matrix_cols, &parse_integer/1)

    {:noreply, socket}
  end

  def handle_event("apply_display_settings", _params, socket) do
    display_data = %{
      "text" => socket.assigns.display_text,
      "font" => socket.assigns.selected_font,
      "rows" => socket.assigns.matrix_rows,
      "cols" => socket.assigns.matrix_cols,
      "speed" => socket.assigns.speed,
      "y_pos" => socket.assigns.y_pos,
      "text_color" => hex_to_rgb_str(socket.assigns.text_color),
      "bg_color" => hex_to_rgb_str(socket.assigns.background_color)
    }

    command = "display_text:" <> Jason.encode!(display_data)

    # Send the command to the device
    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, socket.assigns.mac_address, command}
    )

    log_message("Sending Keyboard Input command to device", socket)
  end

  def handle_event("keyboard_escape", _params, socket) do
    {:noreply, assign(socket, keyboard_text: "", keyboard_active: false)}
  end

  def handle_info({:keyboard_input, device_mac, "EXIT_KEYBOARD_MODE"}, socket)
      when device_mac == socket.assigns.mac_address do
    {:noreply, assign(socket, keyboard_text: "", keyboard_active: false)}
  end

  def handle_info({:keyboard_input, device_mac, text}, socket)
      when device_mac == socket.assigns.mac_address do
    IO.puts("Keyboard input received: #{text} from device #{device_mac}")
    current_text = socket.assigns.keyboard_text

    new_text =
      cond do
        text == "\b" ->
          # Handle backspace: remove last character
          String.slice(current_text, 0..-2//-1)

        true ->
          # Append new text
          current_text <> text
      end

    {:noreply, assign(socket, keyboard_text: new_text, keyboard_active: true)}
  end

  def handle_event("toggle_led", %{"state" => state}, socket) do
    Phoenix.PubSub.broadcast(
      Ticketme.PubSub,
      "device_commands",
      {:send_command, socket.assigns.mac_address, "led #{state}"}
    )

    log_message("turning LED #{state}", socket)
  end

  def handle_event("start_keyboard", _params, socket) do
    mac_address = socket.assigns.mac_address

    TicketmeWeb.Endpoint.broadcast(
      "device_commander",
      "send_command",
      %{mac_address: mac_address, command: "start_keyboard"}
    )

    {:noreply, socket}
  end

  def handle_event("stop_keyboard", _params, socket) do
    mac_address = socket.assigns.mac_address

    TicketmeWeb.Endpoint.broadcast(
      "device_commander",
      "send_command",
      %{mac_address: mac_address, command: "stop_keyboard"}
    )

    {:noreply, socket}
  end

  def handle_event("keypad-press", %{"key" => key}, socket) do
    if String.length(socket.assigns.current_input) < 4 do
      current_input = socket.assigns.current_input <> key
      IO.puts("Keypad press: #{key}, Current input: #{current_input}")
      socket = assign(socket, :current_input, current_input)
      socket = push_event(socket, "keypad-updated", %{current_input: current_input})
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keypad-clear", _, socket) do
    IO.puts("Keypad clear")
    socket = assign(socket, :current_input, "")
    socket = push_event(socket, "keypad-updated", %{current_input: ""})
    {:noreply, socket}
  end

  def handle_event("keypad-submit", _params, socket) do
    %{
      current_input: input,
      correct_code: correct_code,
      attempts: attempts,
      max_attempts: max_attempts,
      locked_out: locked_out
    } = socket.assigns

    # Debug log
    IO.puts("Keypad submit: input=#{input}, correct=#{correct_code}, attempts=#{attempts}")

    # If system is locked out, ignore submission
    if locked_out do
      {:noreply, socket}
    else
      attempts = attempts + 1

      socket =
        socket
        |> assign(:attempts, attempts)
        |> assign(:current_input, "")

      # Compare input with correct code directly to ensure proper matching
      is_correct = input == correct_code
      IO.puts("Code match check: #{is_correct}")

      socket =
        if is_correct do
          # Cancel any existing lockout timer
          if Map.get(socket.assigns, :lockout_timer_ref) do
            Process.cancel_timer(socket.assigns.lockout_timer_ref)
          end

          socket
          |> assign(:is_unlocked, true)
          |> assign(:message, "Access granted!")
          |> assign(:attempts, 0)
        else
          message = "Incorrect code. Try again."

          socket =
            if attempts >= max_attempts do
              # Debug log
              IO.puts("Max attempts reached, locking out")

              lockout_seconds = 5

              timer_ref =
                Process.send_after(self(), :reset_keypad_lockout, lockout_seconds * 1000)

              socket
              |> assign(:locked_out, true)
              |> assign(:lockout_remaining, lockout_seconds)
              |> assign(:lockout_timer_ref, timer_ref)
              |> start_countdown_timer()
            else
              socket
            end

          socket
          |> assign(:is_unlocked, false)
          |> assign(:message, message)
        end

      # Log the updated state for debugging
      IO.puts(
        "Updated state - Unlocked: #{socket.assigns.is_unlocked}, Message: #{socket.assigns.message}"
      )

      {:noreply, socket}
    end
  end

  def handle_info(:reset_keypad_lockout, socket) do
    # Debug log
    IO.puts("Keypad lockout reset")

    socket =
      socket
      |> assign(:locked_out, false)
      |> assign(:attempts, 0)
      |> assign(:message, nil)
      |> assign(:lockout_timer_ref, nil)
      |> assign(:lockout_remaining, 0)

    # Push an event to the client for debugging
    socket =
      push_event(socket, "keypad-updated", %{
        locked_out: false,
        attempts: 0,
        message: nil
      })

    {:noreply, socket}
  end

  def handle_info(:countdown_tick, socket) do
    remaining = socket.assigns.lockout_remaining - 1

    # Debug log
    IO.puts("Keypad lockout countdown: #{remaining}")

    socket = assign(socket, :lockout_remaining, remaining)

    # Push an event to the client for debugging
    socket =
      push_event(socket, "keypad-updated", %{
        lockout_remaining: remaining
      })

    if remaining > 0 do
      # Continue countdown
      Process.send_after(self(), :countdown_tick, 1000)
      {:noreply, socket}
    else
      # Countdown complete (the actual reset is handled by :reset_keypad_lockout)
      {:noreply, socket}
    end
  end

  defp start_countdown_timer(socket) do
    Process.send_after(self(), :countdown_tick, 1000)
    socket
  end

  def handle_event(
        "execute_command",
        %{"command" => _command},
        %{assigns: %{device_status: "offline"}} = socket
      ) do
    log_message("device offline", socket)
  end

  def handle_event(
        "execute_command",
        %{"command" => _command},
        %{assigns: %{device_status: "unknown"}} = socket
      ) do
    log_message("device status unknown, waiting for connection...", socket)
  end

  def handle_event("execute_command", %{"command" => "help"}, socket) do
    help_text = """
    Available commands:
    #{Enum.map_join(@commands, "\n", fn cmd -> "  #{cmd.command} - #{cmd.description}" end)}
    """

    log_message("help\n#{help_text}", socket)
  end

  def handle_event("execute_command", %{"command" => command}, socket) do
    case Enum.find(@commands, fn cmd -> cmd.command == command end) do
      nil ->
        log_message("#{command}: command not found", socket)

      command_data ->
        # IO.puts("[LiveView] Broadcasting command: #{inspect(command_data)}")
        # IO.puts("[LiveView] To device: #{socket.assigns.device_name}")
        # IO.puts("[LiveView] Current device status: #{socket.assigns.device_status}")

        Phoenix.PubSub.broadcast(
          Ticketme.PubSub,
          "device_commands",
          {:send_command, socket.assigns.mac_address, command_data.exec}
        )

        log_message("executing #{command}", socket)
    end
  end

  def handle_info({:device_status_update, device_mac, status}, socket) do
    if device_mac == socket.assigns.mac_address do
      {:noreply, assign(socket, device_status: status)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:webcam_frame, device_mac, %{"frame" => frame_base64}}, socket)
      when device_mac == socket.assigns.mac_address do
    {:noreply, assign(socket, webcam_frame: frame_base64)}
  end

  def handle_info({:keypad_press, device_mac, key}, socket)
      when device_mac == socket.assigns.mac_address do
    handle_event("keypad-press", %{"key" => key}, socket)
  end

  def handle_info({:keypad_clear, device_mac}, socket)
      when device_mac == socket.assigns.mac_address do
    handle_event("keypad-clear", %{}, socket)
  end

  def handle_info({:keypad_submit, device_mac}, socket)
      when device_mac == socket.assigns.mac_address do
    handle_event("keypad-submit", %{}, socket)
  end

  def handle_info({type, device_mac, content}, socket)
      when device_mac == socket.assigns.mac_address do
    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y-%m-%d %H:%M:%S")
    prefix = if type == :command_result, do: "result:", else: "system:"

    safe_content =
      cond do
        is_binary(content) -> content
        true -> inspect(content)
      end

    new_log = "#{timestamp} #{prefix} #{safe_content}"

    {:noreply, update(socket, :logs, fn logs -> [new_log | logs] end)}
  end

  def handle_info({:keypad_press, device_mac, key}, socket)
      when device_mac == socket.assigns.mac_address do
    handle_event("keypad-press", %{"key" => key}, socket)
  end

  def handle_info({:keypad_clear, device_mac}, socket)
      when device_mac == socket.assigns.mac_address do
    handle_event("keypad-clear", %{}, socket)
  end

  def handle_info({:keypad_submit, device_mac}, socket)
      when device_mac == socket.assigns.mac_address do
    handle_event("keypad-submit", %{}, socket)
  end

  # https://stackoverflow.com/questions/51717731/how-to-understand-get-value-from-map-by-its-key-in-elixir

  def handle_info(_, socket), do: {:noreply, socket}

  defp status_color(status) do
    case status do
      "online" -> "bg-green-500"
      "offline" -> "bg-red-500"
      "unknown" -> "bg-gray-200"
      _ -> "bg-gray-200"
    end
  end

  defp format_device_type(device_type) do
    case device_type do
      "temperature_sensor" -> "Temperature Sensor"
      "humidity_sensor" -> "Humidity Sensor"
      "motion_sensor" -> "Motion Sensor"
      "light_sensor" -> "Light Sensor"
      "camera_sensor" -> "Camera"
      "other" -> "Other"
      _ -> "Unknown Sensor Type"
    end
  end

  defp maybe_update_param(
         socket,
         params,
         param_key,
         assign_key,
         transform_fn \\ &Function.identity/1
       ) do
    case Map.get(params, param_key) do
      nil -> socket
      value -> assign(socket, assign_key, transform_fn.(value))
    end
  end

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> 0
    end
  end

  defp parse_integer(value), do: value
end
