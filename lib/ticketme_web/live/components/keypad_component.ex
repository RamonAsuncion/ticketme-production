defmodule LiveViewDashboardWeb.Components.KeypadComponent do
  use Phoenix.Component

  # Attributes
  attr :id, :string, default: "keypad-component"
  attr :correct_code, :string, default: "1234"
  attr :max_attempts, :integer, default: 5
  attr :current_input, :string, default: ""
  attr :attempts, :integer, default: 0
  attr :is_unlocked, :boolean, default: false
  attr :message, :string, default: nil
  attr :locked_out, :boolean, default: false
  attr :lockout_remaining, :integer, default: 0

  def keypad_display(assigns) do
    ~H"""
    <div
      class="bg-white rounded-lg shadow-sm p-4 flex flex-col h-full border border-gray-200"
      id={@id}
      style="min-height: 350px;"
    >
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-sm font-bold text-gray-800">Security Keypad</h3>
        <div class="flex items-center gap-2">
          <span class="text-xs text-gray-500">
            Attempts: <span class="font-medium"><%= @attempts %></span> / <%= @max_attempts %>
          </span>
        </div>
      </div>

      <div class="flex-grow flex flex-col items-center justify-center">
        <div class={
          (@is_unlocked && "text-green-500") || (@locked_out && "text-red-500") || "text-gray-600"
        }>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-16 h-16 mb-4"
          >
            <%= if @is_unlocked do %>
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M13.5 10.5V6.75a4.5 4.5 0 1 1 9 0v3.75M3.75 21.75h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H3.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z"
              />
            <% else %>
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z"
              />
            <% end %>
          </svg>
        </div>

        <div class="flex justify-center space-x-2 mb-6">
          <%= for i <- 1..4 do %>
            <div class="w-3 h-3 rounded-full border border-gray-300 flex items-center justify-center">
              <%= if String.length(@current_input) >= i do %>
                <div class="w-2 h-2 rounded-full bg-gray-800"></div>
              <% end %>
            </div>
          <% end %>
        </div>

        <%= if @locked_out do %>
          <div class="mb-4 text-sm px-3 py-2 rounded-md bg-red-100 text-red-700">
            System locked. Reset in <%= @lockout_remaining %>s
          </div>
        <% else %>
          <%= if @message do %>
            <div class={
              "mb-4 text-sm px-3 py-2 rounded-md " <>
              if(@is_unlocked, do: "bg-green-100 text-green-700", else: "bg-red-100 text-red-700")
            }>
              <%= @message %>
            </div>
          <% end %>
        <% end %>

        <div class="grid grid-cols-3 gap-3 mb-4">
          <%= for number <- 1..9 do %>
            <div class="bg-gray-100 w-12 h-12 rounded-md flex items-center justify-center text-lg font-medium text-gray-700">
              <%= number %>
            </div>
          <% end %>
          <div class="bg-gray-100 w-12 h-12 rounded-md flex items-center justify-center text-sm font-medium text-gray-700">
            Clear
          </div>
          <div class="bg-gray-100 w-12 h-12 rounded-md flex items-center justify-center text-lg font-medium text-gray-700">
            0
          </div>
          <div class="bg-yellow-500 w-12 h-12 rounded-md flex items-center justify-center text-lg font-medium text-white">
            #
          </div>
        </div>
        <!-- Debug information -->
        <div class="mt-4 text-xs text-gray-400 text-left w-full">
          <p>Current input: "<%= @current_input %>" (length: <%= String.length(@current_input) %>)</p>
          <p>Correct code: "<%= @correct_code %>"</p>
          <p>Attempts: <%= @attempts %>/<%= @max_attempts %></p>
          <p>Locked out: <%= @locked_out %></p>
          <p>Is unlocked: <%= @is_unlocked %></p>
          <p>Message: <%= @message %></p>
        </div>
      </div>
    </div>
    """
  end
end
