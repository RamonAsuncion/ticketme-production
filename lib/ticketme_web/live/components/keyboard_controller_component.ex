defmodule LiveViewDashboardWeb.Components.KeyboardControllerComponent do
  use Phoenix.Component

  def keyboard_controller_display(assigns) do
    assigns = assign_new(assigns, :keyboard_text, fn -> "" end)

    ~H"""
    <div
      class="bg-white rounded-lg shadow-sm p-4 flex flex-col h-full border border-gray-200"
      id="keyboard-component"
      phx-hook="KeyboardController"
      style="min-height: 250px;"
    >
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-sm font-bold text-gray-800">Keyboard Input</h3>
        <div class="flex items-center gap-1.5">
          <span class="px-1.5 py-0.5 text-xs bg-gray-200 rounded-md text-gray-600 font-mono">
            ESC
          </span>
          <span class="text-xs text-gray-500">to exit</span>
        </div>
      </div>

      <div class="flex-grow flex flex-col min-h-0">
        <div class="bg-white rounded border border-gray-200 flex-grow flex flex-col min-h-0">
          <div class="overflow-y-auto p-3 flex-grow min-h-0">
            <%= if @keyboard_text != "" do %>
              <pre class="whitespace-pre-wrap font-mono text-sm text-gray-700 break-words"><%= @keyboard_text %></pre>
            <% else %>
              <span class="text-gray-400 font-mono text-sm">Waiting for keyboard input...</span>
            <% end %>
          </div>
        </div>

        <div class="absolute bottom-2 right-2 flex items-center">
          <div class="w-2 h-4 bg-emerald-500 animate-pulse"></div>
        </div>
      </div>
    </div>
    """
  end
end
