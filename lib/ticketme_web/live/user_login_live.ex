# https://flowbite.com/blocks/marketing/login/
# https://www.creative-tim.com/twcomponents/components/logins
# https://tailwindflex.com/tag/login
defmodule TicketmeWeb.UserLoginLive do
  use TicketmeWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        with token when not is_nil(token) <- session["user_token"],
             user <- Ticketme.Accounts.get_user_by_session_token(token) do
          user
        else
          _ -> nil
        end
      end)

    if socket.assigns.current_user do
      {:ok, push_navigate(socket, to: ~p"/dashboard")}
    else
      email = Phoenix.Flash.get(socket.assigns.flash, :email)
      form = to_form(%{"email" => email}, as: "user")

      error_message = Phoenix.Flash.get(socket.assigns.flash, :error)

      {:ok, assign(socket, form: form, error_message: error_message),
       temporary_assigns: [form: form]}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="flex flex-col md:flex-row h-screen">
        <!-- Left column - Login form -->
        <div class="flex-1 w-full md:w-1/2 bg-white flex items-center justify-center p-6">
          <div class="w-full max-w-md">
            <%= if @error_message do %>
              <div class="mb-4 p-4 rounded-md bg-red-50 border border-red-200">
                <p class="text-sm text-red-600"><%= @error_message %></p>
              </div>
            <% end %>
            <!-- Mobile logo (only visible on mobile) -->
            <div class="md:hidden flex justify-center mb-8">
              <img src={~p"/images/icon.png"} alt="TicketMe Icon" class="w-16 h-16" />
              <div class="ml-2">
                <div class="text-2xl font-bold text-gray-900">TicketMe</div>
                <div class="text-sm text-gray-600">IoT Product Management Portal</div>
              </div>
            </div>

            <h2 class="text-2xl font-bold text-gray-900 mb-6 text-left">
              Welcome back
            </h2>

            <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                required
                placeholder="Enter your email"
              />
              <.input
                field={@form[:password]}
                type="password"
                label="Password"
                required
                placeholder="••••••••"
              />

              <div class="flex items-center justify-between mt-4">
                <div class="flex items-center">
                  <.input field={@form[:remember_me]} type="checkbox" label="Remember me" />
                </div>
                <.link
                  href={~p"/users/reset_password"}
                  class="text-sm font-medium text-[#ff9f68] hover:underline"
                >
                  Forgot password?
                </.link>
              </div>

              <.button
                phx-disable-with="Logging in..."
                class="w-full mt-6 bg-[#ff9f68] hover:bg-[#ff8c4c]"
              >
                Sign into your account
              </.button>

              <p class="mt-4 text-sm text-gray-600 text-left">
                Don't have an account?
                <.link
                  navigate={~p"/users/register"}
                  class="ml-1 font-medium text-[#ff9f68] hover:underline"
                >
                  Sign up
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
            <h1 class="text-3xl font-bold mb-6">TicketMe</h1>
            <p class="text-lg mb-6">
              A IoT product management tool for monitoring devices and receiving alerts.
            </p>
            <ul class="space-y-2">
              <li class="flex items-center">
                <.icon name="hero-check-circle" class="w-5 h-5 mr-2" /> Real-time device monitoring
              </li>
              <li class="flex items-center">
                <.icon name="hero-check-circle" class="w-5 h-5 mr-2" /> Automated alert system
              </li>
              <li class="flex items-center">
                <.icon name="hero-check-circle" class="w-5 h-5 mr-2" /> Easy to use
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
