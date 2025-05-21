defmodule TicketmeWeb.ErrorJSONTest do
  use TicketmeWeb.ConnCase, async: true

  test "renders 404" do
    assert TicketmeWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert TicketmeWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
