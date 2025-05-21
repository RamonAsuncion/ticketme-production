defmodule LiveViewDashboardWeb.Components.MatrixControllerComponent do
  use Phoenix.Component

  # https://hexdocs.pm/phoenix_live_view/1.0.9/form-bindings.html#form-events
  attr :text, :string, default: ""
  attr :color, :string, default: "#FF00FF"
  attr :background, :string, default: "#000000"
  attr :speed, :integer, default: 10
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

  def matrix_controller_display(assigns) do
    ~H"""
    <div
      class="bg-white rounded-lg shadow-sm p-4 flex flex-col h-full border border-gray-200"
      style="min-height: 350px;"
    >
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-sm font-bold text-gray-800">LED Matrix Controller</h3>
      </div>

      <div class="flex-grow">
        <%!-- Reference: https://elixirforum.com/t/form-not-firing-phx-change-in-liveview/51319 --%>
        <form phx-change="update_display_settings" class="space-y-4">
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
            <!-- Position Sliders -->
            <div class="space-y-3">
              <!-- Speed Slider -->
              <div>
                <div class="flex items-center justify-between mb-1">
                  <label class="text-sm font-medium text-gray-700">Speed</label>
                  <span class="text-xs text-gray-500 w-8 text-right"><%= @speed %></span>
                </div>
                <input
                  type="range"
                  name="speed"
                  min="1"
                  max="30"
                  value={@speed}
                  class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer transition-all ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 accent-blue-600"
                />
              </div>
              <!-- Y Slider -->
              <div>
                <div class="flex items-center justify-between mb-1">
                  <label class="text-sm font-medium text-gray-700">Y Position</label>
                  <span class="text-xs text-gray-500 w-8 text-right"><%= @y_pos %></span>
                </div>
                <input
                  type="range"
                  name="y_pos"
                  min="0"
                  max="64"
                  value={@y_pos}
                  class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer transition-all ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 accent-blue-600"
                />
              </div>
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
              <%= for {value, label} <- @available_fonts do %>
                <option value={value} selected={@font == value}><%= label %></option>
              <% end %>
            </select>
          </div>
          <!-- Apply Button -->
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
