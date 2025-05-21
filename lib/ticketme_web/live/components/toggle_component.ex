defmodule LiveViewDashboardWeb.Components.ToggleComponent do
  use Phoenix.Component

  attr :label, :string, default: "LED"
  attr :status, :boolean, default: false
  attr :id, :string, required: true
  attr :type, :string, default: "led"
  attr :color, :string, default: "#FFCC00"
  attr :location, :string, default: "GPIO 18"
  attr :description, :string, default: ""

  # https://tailwindcss.com/plus/ui-blocks
  # https://tw-elements.com/docs/standard/forms/switch/
  # https://flowbite.com/docs/components/buttons/
  # Mix of TailwindUI components and Flowbite toggle switch.
  def toggle_switch(assigns) do
    ~H"""
    <div
      class="bg-white rounded-lg shadow-sm p-4 flex flex-col border border-gray-200"
      id={"toggle-component-#{@id}"}
    >
      <div class="flex items-center justify-between mb-2">
        <div class="flex items-center gap-2">
          <div class="flex h-4 w-4 rounded-full" style={"background-color: #{@color}"}></div>
          <h3 class="text-sm font-bold text-gray-800">
            <%= @label %> <span class="text-xs font-normal text-gray-500">(<%= @location %>)</span>
          </h3>
        </div>

        <div class="flex items-center">
          <div class={"h-2 w-2 rounded-full mr-2 #{if @status, do: "bg-green-500", else: "bg-red-500"}"}>
          </div>
          <span class="text-xs font-medium text-gray-600">
            <%= if @status, do: "ON", else: "OFF" %>
          </span>
        </div>
      </div>

      <div class="flex items-center justify-between mt-2">
        <span class="text-xs text-gray-500"><%= @description %></span>

        <label class="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            value=""
            class="sr-only peer"
            phx-click="toggle_accessory"
            phx-value-id={@id}
            phx-value-type={@type}
            checked={@status}
          />
          <%!-- https://flowbite.com/docs/forms/toggle/ --%>
          <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600">
          </div>
        </label>
      </div>
    </div>
    """
  end

  def accessory_grid(assigns) do
    ~H"""
    <div class="grid grid-cols-1 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
      <%= for accessory <- @accessories do %>
        <.toggle_switch
          id={accessory.id}
          label={accessory.label}
          status={accessory.status}
          type={accessory.type}
          color={accessory.color}
          location={accessory.location}
          description={accessory.description}
        />
      <% end %>
    </div>
    """
  end
end
