defmodule TicketmeWeb.PageController do
  use TicketmeWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def login(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :login, layout: false)
  end
end
