defmodule LiveViewDashboardWeb.Components.WebcamDisplayComponent do
  use Phoenix.Component

  def webcam_display(assigns) do
    assigns = assign_new(assigns, :streaming, fn -> false end)
    assigns = assign_new(assigns, :device_name, fn -> nil end)

    ~H"""
    <div class="bg-white rounded-lg shadow-sm p-4 flex flex-col h-full border border-gray-200">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-sm font-bold text-gray-800">Camera Feed</h3>
        <div class="flex items-center gap-2">
          <span class={"inline-flex items-center px-2 py-1 text-xs font-medium rounded-md #{if @streaming, do: "bg-green-100 text-green-800", else: "bg-gray-100 text-gray-800"}"}>
            <span class={"mr-1.5 flex w-2 h-2 rounded-full #{if @streaming, do: "bg-green-500 animate-pulse", else: "bg-gray-400"}"}>
            </span>
            <%= if @streaming, do: "Live", else: "Off" %>
          </span>
        </div>
      </div>

      <div class="relative bg-black rounded overflow-hidden flex-grow">
        <%= if @webcam_frame do %>
          <img
            src={"data:image/jpeg;base64,#{@webcam_frame}"}
            alt="Webcam Feed"
            class="w-full h-full object-contain"
          />
        <% else %>
          <div class="absolute inset-0 flex flex-col items-center justify-center text-gray-400">
            <svg class="w-12 h-12 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="1.5"
                d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
              />
            </svg>
            <p class="text-sm">Waiting for camera feed...</p>
            <button
              phx-click="toggle_webcam"
              class="mt-4 px-3 py-1.5 bg-blue-500 text-white text-sm rounded-md hover:bg-blue-600 transition-colors"
            >
              Start Camera
            </button>
          </div>
        <% end %>

        <%= if @webcam_frame do %>
          <div class="absolute top-2 right-2">
            <button
              phx-click="toggle_webcam"
              class="bg-red-500 hover:bg-red-600 text-white p-1 rounded-full shadow-md transition-colors"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fill-rule="evenodd"
                  d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                  clip-rule="evenodd"
                />
              </svg>
            </button>
          </div>
        <% end %>
      </div>

      <%= if @webcam_frame do %>
        <div class="mt-2 text-xs text-gray-500 flex items-center justify-between">
          <span>Device: <%= @device_name || "Unknown" %></span>
          <span>Resolution: 640×480</span>
        </div>
      <% end %>
    </div>
    """
  end
end
