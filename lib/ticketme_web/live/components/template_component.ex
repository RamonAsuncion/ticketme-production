defmodule LiveViewDashboardWeb.Components.ComponentTemplate do
  use Phoenix.Component

  # import LiveViewDashboardWeb.Components.ComponentTemplate
  # <.display title="My Custom Component" />

  attr :title, :string, default: "Component Title"

  def display(assigns) do
    assigns = assign_new(assigns, :status, fn -> "inactive" end)

    ~H"""
    <div class="bg-white rounded-lg shadow-sm p-4 flex flex-col h-full border border-gray-200">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-sm font-bold text-gray-800"><%= @title %></h3>
        <div class="flex items-center gap-2"></div>
      </div>

      <div class="flex-grow">
        <div class="bg-white rounded border border-gray-200 relative h-full">
          <div class="overflow-y-auto p-3 h-full"></div>
        </div>

        <div class="mt-2 text-xs text-gray-500 flex items-center justify-between"></div>
      </div>
    </div>
    """
  end

  # def format_data(data), do: ...
end
