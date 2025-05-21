defmodule LiveViewDashboardWeb.Components.DynamicChartComponent do
  use Phoenix.Component

  def chart(assigns) do
    ~H"""
    <div class="w-full space-y-4">
      <div class="flex items-center justify-between">
        <h2 class="text-2xl font-semibold text-gray-900">Sensor Data</h2>
        <div class="flex items-center space-x-4">
          <%= for sensor <- @available_sensors do %>
            <div class="flex items-center">
              <button
                phx-click="toggle_sensor"
                phx-value-id={sensor.id}
                class={"flex items-center px-2 py-1 rounded-full text-xs #{if sensor.id in @active_sensors, do: "bg-blue-100 border-blue-500", else: "bg-gray-100 border-gray-300"} border"}
              >
                <div class="h-3 w-3 rounded-full mr-2" style={"background-color: #{sensor.color}"}>
                </div>
                <span><%= sensor.name %></span>
              </button>
            </div>
          <% end %>
        </div>
      </div>

      <div class="relative">
        <canvas
          id="dynamic-chart"
          phx-hook="DynamicChart"
          data-metrics={Jason.encode!(@metrics)}
          class="rounded-lg"
          width="600"
          height="300"
        >
        </canvas>
      </div>
    </div>
    """
  end
end
