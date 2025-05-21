defmodule TicketmeWeb.PageLive.Components.AlertComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="alert-container mt-4" id="alerts-banner" phx-hook="AlertBanner">
      <div
        class="alert-banner fixed top-0 left-1/2 transform -translate-x-1/2 bg-red-500 text-white text-center py-3 px-4 rounded-lg shadow-lg flex items-center justify-between hidden"
        style="display: none;"
      >
        <div class="flex-1">
          <span class="alert-message text-sm font-medium"></span>
        </div>
        <button
          class="close-btn text-xl font-semibold ml-3"
          phx-click="close_alert"
          phx-target="#alerts-banner"
        >
          &times;
        </button>
      </div>

      <h3 class="text-lg font-semibold text-gray-900 mb-2">Alert History</h3>
      <div class="overflow-auto rounded-lg shadow-md max-h-64 bg-white">
        <table class="min-w-full table-fixed bg-gray-100">
          <thead class="bg-gray-200">
            <tr>
              <th class="text-left p-3 text-sm font-medium text-gray-700 w-1/3">Timestamp</th>
              <th class="text-left p-3 text-sm font-medium text-gray-700">Message</th>
            </tr>
          </thead>
          <tbody>
            <%= for alert <- @alerts do %>
              <tr class="hover:bg-gray-50">
                <td class="p-3 text-sm text-gray-600"><%= format_timestamp(alert.timestamp) %></td>
                <td class="p-3 text-sm text-red-500"><%= alert.message %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp format_timestamp(timestamp) do
    timestamp
    |> NaiveDateTime.to_string()
    |> String.replace("T", " ")
  end
end
