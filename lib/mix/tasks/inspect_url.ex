defmodule Mix.Tasks.InspectUrl do
  use Mix.Task

  # Generated mostly by ChatGPT and modified by Ramon Asuncion.

  @shortdoc "Inspect URLs"
  def run(_) do
    # Load the application AND runtime config
    Application.ensure_all_started(:ticketme)

    # Force loading of runtime config
    # This is a bit of a hack but will load runtime.exs
    Application.get_env(:phoenix, :json_library)

    endpoint = TicketmeWeb.Endpoint

    # Get current environment
    IO.puts("Current environment: #{Mix.env()}")

    # Get configuration directly from process rather than compile-time config
    endpoint_config = Application.get_env(:ticketme, endpoint)
    url = endpoint_config[:url]
    socket_path = endpoint_config[:socket_path]
    live_socket_path = endpoint_config[:live_socket_path]

    # Print configuration
    IO.puts("\nRaw configuration:")
    IO.puts("URL config: #{inspect(url)}")
    IO.puts("Socket path: #{inspect(socket_path)}")
    IO.puts("LiveView socket path: #{inspect(live_socket_path)}")

    # Build and print full URLs
    scheme = url[:scheme] || "http"
    host = url[:host] || "localhost"
    port = url[:port]
    path = url[:path] || ""

    port_str = if port && port not in [80, 443], do: ":#{port}", else: ""
    base_url = "#{scheme}://#{host}#{port_str}#{path}"
    socket_url = "#{scheme}://#{host}#{port_str}#{socket_path}"
    live_socket_url = "#{scheme}://#{host}#{port_str}#{live_socket_path}"

    IO.puts("\nConstructed URLs:")
    IO.puts("Base URL: #{base_url}")
    IO.puts("Socket URL: #{socket_url}")
    IO.puts("LiveView socket URL: #{live_socket_url}")

    # Show both configs for comparison
    IO.puts("\nConfig from different sources:")
    IO.puts("From endpoint.config(): #{inspect(endpoint.config(:url))}")

    IO.puts(
      "From Application.get_env(): #{inspect(Application.get_env(:ticketme, TicketmeWeb.Endpoint)[:url])}"
    )
  end
end
