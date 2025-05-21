defmodule TicketmeWeb.ThemeToggleButton do
  # This is how you use: <.live_component module={TicketmeWeb.ThemeToggleButton} id="dark-mode-button" />
  use Phoenix.LiveComponent
  import TicketmeWeb.CoreComponents

  def mount(socket) do
    {:ok, assign(socket, dark_mode: false)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, id: assigns.id)}
  end

  def handle_event("toggle_dark_mode", _, socket) do
    new_dark_mode = !socket.assigns.dark_mode

    {:noreply,
     socket
     |> assign(:dark_mode, new_dark_mode)
     |> push_event("toggle-theme", %{dark_mode: new_dark_mode})}
  end

  def render(assigns) do
    ~H"""
    <button
      id={@id}
      class="self-end dark-mode-toggle p-2"
      phx-click="toggle_dark_mode"
      phx-target={@myself}
      phx-hook="ThemeToggle"
    >
      <%= if @dark_mode do %>
        <.icon name="hero-sun" class="h-5 w-5" />
      <% else %>
        <.icon name="hero-moon" class="h-5 w-5" />
      <% end %>
    </button>
    """
  end
end
