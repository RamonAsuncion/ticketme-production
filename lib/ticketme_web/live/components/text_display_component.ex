defmodule LiveViewDashboardWeb.Components.TextDisplayComponent do
  use Phoenix.Component

  # https://hexdocs.pm/phoenix_live_view/1.0.9/form-bindings.html#form-events
  attr :text, :string, default: ""
  attr :color, :string, default: "#FF00FF"
  attr :background, :string, default: "#003200"
  attr :x_pos, :integer, default: 0
  attr :y_pos, :integer, default: 22
  attr :font, :string, default: "9x18.bdf"
  attr :rows, :integer, default: 64
  attr :cols, :integer, default: 64

  attr :available_fonts, :list,
    default: [
      {"5x7.bdf", "Small 5x7"},
      {"5x8.bdf", "Small 5x8"},
      {"6x9.bdf", "Medium 6x9"},
      {"6x10.bdf", "Medium 6x10"},
      {"6x12.bdf", "Medium 6x12"},
      {"6x13.bdf", "Medium 6x13"},
      {"7x13.bdf", "Medium 7x13"},
      {"8x13.bdf", "Large 8x13"},
      {"9x15.bdf", "Large 9x15"},
      {"9x18.bdf", "Large 9x18"},
      {"10x20.bdf", "XL 10x20"}
    ]

  # Trying to give it that flowbite css card style. https://flowbite.com/docs/components/card/

  def text_display(assigns) do
    ~H"""
    <div class="w-full max-w-sm p-4 bg-white border border-gray-200 rounded-lg shadow-sm space-y-4 text-sm">
      <%!-- Reference: https://elixirforum.com/t/form-not-firing-phx-change-in-liveview/51319 --%>
      <form phx-change="update_display_settings" class="space-y-4">
        <!-- Title -->
        <h2 class="text-base font-semibold text-gray-800">Matrix Text Configuration</h2>
        <!-- Display Text -->
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Display Text</label>
          <textarea
            name="text"
            rows="2"
            class="w-full p-2 border border-gray-300 rounded-md text-sm text-gray-800 resize-none"
            placeholder="Enter display text..."
            phx-change="update_display_text"
            phx-debounce="300"
          ><%= @text %></textarea>
        </div>
        <!-- Colors -->
        <%!-- https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input/color --%>
        <%!-- FIXME: Let the browser handle it. I'm worried that not all the colors will be supported by the screen. --%>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block mb-1 text-sm font-medium text-gray-700">Text Color</label>
            <div class="flex items-center gap-3">
              <div class="w-6 h-6 rounded-full border" style={"background-color: #{@color}"}></div>
              <input
                type="color"
                name="color"
                value={@color}
                class="h-8 w-8 border-none cursor-pointer"
              />
            </div>
          </div>
          <div>
            <label class="block mb-1 text-sm font-medium text-gray-700">Background</label>
            <div class="flex items-center gap-3">
              <div class="w-6 h-6 rounded-full border" style={"background-color: #{@background}"}>
              </div>
              <input
                type="color"
                name="background"
                value={@background}
                class="h-8 w-8 border-none cursor-pointer"
              />
            </div>
          </div>
        </div>
        <!-- Position Sliders -->
        <div class="space-y-2">
          <%!-- https://flowbite.com/docs/forms/range/ --%>
          <!-- X Slider -->
          <div class="flex items-center gap-3">
            <label class="w-6 text-sm font-medium text-gray-700">X</label>
            <input
              type="range"
              name="x_pos"
              min="-32"
              max="64"
              value={@x_pos}
              phx-change="update_display_settings"
              class="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer transition-all ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 accent-blue-600"
            />
            <span class="text-xs text-gray-500 w-6 text-right"><%= @x_pos %></span>
          </div>
          <!-- Y Slider -->
          <div class="flex items-center gap-3">
            <label class="w-6 text-sm font-medium text-gray-700">Y</label>
            <input
              type="range"
              name="y_pos"
              min="0"
              max="64"
              value={@y_pos}
              phx-change="update_display_settings"
              class="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer transition-all ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 accent-blue-600"
            />
            <span class="text-xs text-gray-500 w-6 text-right"><%= @y_pos %></span>
          </div>
        </div>
        <!-- Matrix Size -->
        <div class="flex items-center gap-2">
          <label class="text-sm font-medium text-gray-700">Size</label>
          <input
            type="number"
            name="rows"
            min="8"
            max="128"
            step="8"
            value={@rows}
            class="w-16 px-2 py-1 border border-gray-300 rounded-md text-center text-sm"
          />
          <%!-- Special multiplication symbol --%>
          <span class="text-gray-500">×</span>
          <input
            type="number"
            name="cols"
            min="8"
            max="128"
            step="8"
            value={@cols}
            class="w-16 px-2 py-1 border border-gray-300 rounded-md text-center text-sm"
          />
        </div>
        <!-- Font -->
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Font</label>
          <select
            name="font"
            class="w-40 p-2 border border-gray-300 rounded-md text-sm focus:ring-blue-500 focus:border-blue-500"
          >
            <%!-- https://stackoverflow.com/questions/47533781/best-way-to-simulate-a-for-loop-in-elixir --%>
            <%= for {value, label} <- @available_fonts do %>
              <option value={value} selected={@font == value}><%= label %></option>
            <% end %>
          </select>
        </div>
        <!-- Apply Button (Keep it same style to existing back button) -->
        <div class="flex justify-end">
          <button
            type="button"
            phx-click="apply_display_settings"
            class="bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium px-4 py-2 rounded-md transition-colors"
          >
            Apply
          </button>
        </div>
      </form>
    </div>
    """
  end

  # https://stackoverflow.com/questions/33347909/convert-a-binary-string-to-hexadecimal-and-vice-versa-in-elixir
  def hex_to_rgb_str(hex_color) do
    hex = String.trim_leading(hex_color, "#")
    <<r, g, b>> = Base.decode16!(String.upcase(hex))
    "#{r},#{g},#{b}"
  end
end
