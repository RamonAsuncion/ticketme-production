defmodule TicketmeWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use TicketmeWeb, :controller` and
  `use TicketmeWeb, :live_view`.
  """
  use TicketmeWeb, :html

  embed_templates "layouts/*"
end
