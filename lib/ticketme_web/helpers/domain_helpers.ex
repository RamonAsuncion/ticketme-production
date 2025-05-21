defmodule TicketmeWeb.Helpers.DomainHelpers do
  # Forum on structure https://elixirforum.com/t/where-do-you-organize-your-helper-functions/62440/8

  @doc """
  Returns the domain for the email based on the current host.
  In dev/test all domains are allowed.
  In prod only emails matching the root domain name are allowed.
  """
  def allowed_email_domain do
    case Application.get_env(:ticketme, :env) do
      :dev ->
        nil

      :test ->
        nil

      _ ->
        # Host from endpoint config
        endpoint_config = Application.get_env(:ticketme, TicketmeWeb.Endpoint)
        host = get_in(endpoint_config, [:url, :host])

        # Return nil (allowed all) for localhost and dev.
        case host do
          "localhost" -> nil
          nil -> nil
          # TODO: edge case when it's an ip address (nil)
          host -> host
        end
    end
  end

  @doc """
  Checks if email is from the allowed domain.
  Return {true, nil} if allowed, {false, error_message} if not.
  """
  def valid_domain?(email) when is_binary(email) do
    domain = allowed_email_domain()

    cond do
      # Allow all domain in dev
      domain == nil ->
        {true, nil}

      # Check if email matches the domain. Remove subdomain.
      true ->
        [_, email_domain] = String.split(email, "@", parts: 2)
        base_domain = domain

        domain_parts = String.split(email_domain, ".")
        email_base_domain = Enum.join(Enum.take(domain_parts, -2), ".")

        if email_base_domain == base_domain do
          {true, nil}
        else
          {false, "must be from the #{domain} domain"}
        end
    end
  end
end
