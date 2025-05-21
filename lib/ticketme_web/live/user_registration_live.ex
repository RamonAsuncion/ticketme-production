# https://flowbite.com/blocks/marketing/register/#register-form-with-description
defmodule TicketmeWeb.UserRegistrationLive do
  use TicketmeWeb, :live_view

  alias Ticketme.Accounts
  alias Ticketme.Accounts.User

  # Copied and pasted over from user_login_live.ex.
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="flex flex-col md:flex-row h-screen">
        <!-- Left column - Registration form -->
        <div class="flex-1 w-full md:w-1/2 bg-white flex items-center justify-center p-6">
          <div class="w-full max-w-md">
            <!-- Mobile logo (only visible on mobile) -->
            <div class="md:hidden flex justify-center mb-8">
              <img src={~p"/images/icon.png"} alt="TicketMe Icon" class="w-16 h-16" />
              <div class="ml-2">
                <div class="text-2xl font-bold text-gray-900">TicketMe</div>
                <div class="text-sm text-gray-600">IoT Product Manager</div>
              </div>
            </div>

            <h2 class="text-2xl font-bold text-gray-900 mb-6 text-left">
              Create an account
            </h2>

            <.simple_form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              phx-trigger-action={@trigger_submit}
              action={~p"/users/log_in?_action=registered"}
              method="post"
            >
              <.error :if={@check_errors}>
                Oops, something went wrong! Please check the errors below.
              </.error>

              <div class="grid grid-cols-2 gap-4">
                <.input
                  field={@form[:first_name]}
                  type="text"
                  label="First Name"
                  required
                  placeholder="e.g. John"
                />
                <.input
                  field={@form[:last_name]}
                  type="text"
                  label="Last Name"
                  required
                  placeholder="e.g. Doe"
                />
              </div>
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                required
                placeholder={get_email_placeholder()}
                phx-debounce="blur"
              />
              <%!-- valid_domain() might be enough. --%>
              <%!-- <%= if hint = get_domain_hint() do %>
                <p class="mt-1 text-sm text-gray-500"><%= hint %></p>
              <% end %> --%>
              <.input
                field={@form[:password]}
                type="password"
                label="Password"
                required
                placeholder="••••••••"
              />

              <.button
                phx-disable-with="Creating account..."
                class="w-full mt-6 bg-[#ff9f68] hover:bg-[#ff8c4c]"
              >
                Create account
              </.button>

              <p class="mt-4 text-sm text-gray-600 text-left">
                Already have an account?
                <.link navigate={~p"/"} class="ml-1 font-medium text-[#ff9f68] hover:underline">
                  Log in
                </.link>
              </p>
            </.simple_form>
          </div>
        </div>
        <!-- Right column - App description -->
        <div class="hidden md:flex md:w-1/2 bg-[#ff9f68] p-10 flex-col justify-center items-center text-white">
          <div class="max-w-md mx-auto">
            <div class="mb-8 flex justify-center">
              <img src={~p"/images/icon.png"} alt="TicketMe Icon" class="w-24 h-24" />
            </div>
            <h1 class="text-3xl font-bold mb-6">Join TicketMe Today</h1>
            <p class="text-lg mb-6">
              Create your account to access our IoT product management platform and start monitoring your devices efficiently.
            </p>
            <ul class="space-y-2">
              <li class="flex items-center">
                <.icon name="hero-check-circle" class="w-5 h-5 mr-2" />
                Track device performance in real-time
              </li>
              <li class="flex items-center">
                <.icon name="hero-check-circle" class="w-5 h-5 mr-2" />
                Get instant notifications for critical issues
              </li>
              <li class="flex items-center">
                <.icon name="hero-check-circle" class="w-5 h-5 mr-2" />
                Simple interface for quick deployment
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  # defp get_domain_hint do
  #   # case TicketmeWeb.Helpers.DomainHelpers.allowed_email_domain() do
  #   "Only @example.com emails allowed"
  #   # nil -> nil
  #   # domain -> "Only @#{domain} emails allowed"
  #   # end
  # end

  defp get_email_placeholder do
    case TicketmeWeb.Helpers.DomainHelpers.allowed_email_domain() do
      nil ->
        "name@example.com"

      domain ->
        # Main domain (last two parts)
        domain_parts = String.split(domain, ".")

        main_domain =
          if length(domain_parts) > 2 do
            # If there is a subdomain only take last two parts.
            Enum.take(domain_parts, -2) |> Enum.join(".")
          else
            domain
          end

        "name@#{main_domain}"
    end
  end
end
