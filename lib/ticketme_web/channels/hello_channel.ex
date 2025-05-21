defmodule TicketmeWeb.HelloChannel do
  use TicketmeWeb, :channel

  def join("hello", _message, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "hello", %{"message" => "hi"})
    {:noreply, socket}
  end
end
