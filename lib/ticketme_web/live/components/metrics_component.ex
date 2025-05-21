defmodule TicketmeWeb.PageLive.Components.MetricsComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="metrics-container">
      <div class="flex items-center justify-between">
        <h2 clas="text-2xl font-semibold text-gray-900">Office Temperature Management</h2>
        <div class="flex items-center space-x-6">
          <div class="flex items-center">
            <div class="h-3 w-3 rounded-full bg-blue-500 mr-2"></div>
            <span class="text-sm text-gray-600">
              Current Temperature: <span class="current-temperature"><%= @metrics[:current_temperature] %></span>°C
            </span>
          </div>
          <div class="flex items-center">
            <div class="h-3 w-3 rounded-full bg-red-500 mr-2"></div>
            <span class="text-sm text-gray-600">
              High Temperature: <span class="high-temperature"><%= @metrics[:high_temperature] %></span>°C
            </span>
          </div>
          <div class="flex items-center">
            <div class="h-3 w-3 rounded-full bg-green-500 mr-2"></div>
            <span class="text-sm text-gray-600">
              Low Temperature: <span class="low-temperature"><%= @metrics[:low_temperature] %></span>°C
            </span>
          </div>
        </div>
      </div>
      <div class="relative">
        <canvas
          id="metrics-chart"
          phx-hook="MetricsChart"
          data-metrics={@temperatures}
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
