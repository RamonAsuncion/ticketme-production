defmodule TicketmeWeb.UserForgotPasswordLive do
  use TicketmeWeb, :live_view

  alias Ticketme.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="flex flex-col md:flex-row h-screen">
        <!-- Left column - Password reset form -->
        <div class="flex-1 w-full md:w-1/2 bg-white flex items-center justify-center p-6">
          <div class="w-full max-w-md">
            <!-- Mobile logo (only visible on mobile) -->
            <div class="md:hidden flex justify-center mb-8">
              <img src={~p"/images/icon.png"} alt="TicketMe Icon" class="w-16 h-16" />
              <div class="ml-2">
                <div class="text-2xl font-bold text-gray-900">TicketMe</div>
                <div class="text-sm text-gray-600">IoT Product Management Portal</div>
              </div>
            </div>

            <h2 class="text-2xl font-bold text-gray-900 mb-6 text-left">
              Forgot your password?
            </h2>
            <p class="text-gray-600 mb-6">
              We'll send a password reset link to your inbox.
            </p>

            <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                placeholder="Enter your email"
                required
              />
              <:actions>
                <.button
                  phx-disable-with="Sending..."
                  class="w-full mt-6 bg-[#ff9f68] hover:bg-[#ff8c4c]"
                >
                  Send password reset instructions
                </.button>
              </:actions>
            </.simple_form>
            <p class="mt-4 text-sm text-gray-600 text-left">
              Remember your password?
              <.link navigate={~p"/"} class="ml-1 font-medium text-[#ff9f68] hover:underline">
                Sign in
              </.link>
            </p>
            <p class="mt-2 text-sm text-gray-600 text-left">
              Don't have an account?
              <.link
                navigate={~p"/users/register"}
                class="ml-1 font-medium text-[#ff9f68] hover:underline"
              >
                Sign up
              </.link>
            </p>
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

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
