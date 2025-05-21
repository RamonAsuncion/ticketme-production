defmodule TicketmeWeb.UserSettingsLive do
  use TicketmeWeb, :live_view
  alias Ticketme.Accounts

  # live view of site (opensoruce): https://flowbite-admin-dashboard.vercel.app/settings/
  # and some from their own website lmao https://flowbite.com/dashboard/account-settings/
  def render(assigns) do
    ~H"""
    <div class="px-4 pt-6">
      <div class="mb-4">
        <nav class="flex mb-5" aria-label="Breadcrumb">
          <ol class="inline-flex items-center space-x-1 text-sm font-medium md:space-x-2">
            <li class="inline-flex items-center">
              <.link
                navigate={~p"/"}
                class="inline-flex items-center text-gray-700 hover:text-[#ff9f68]"
              >
                <svg class="w-5 h-5 mr-2.5" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z">
                  </path>
                </svg>
                Home
              </.link>
            </li>
            <li>
              <div class="flex items-center">
                <svg class="w-6 h-6 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    fill-rule="evenodd"
                    d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                  >
                  </path>
                </svg>
                <span class="ml-1 text-gray-400 md:ml-2">Settings</span>
              </div>
            </li>
          </ol>
        </nav>
        <h1 class="text-xl font-semibold text-gray-900 sm:text-2xl">User Settings</h1>
      </div>

      <div class="grid grid-cols-1 gap-4 xl:grid-cols-2">
        <!-- Left Column -->
        <div class="space-y-4">
          <!-- General Information -->
          <div class="p-4 bg-white border border-gray-200 rounded-lg shadow-sm">
            <h3 class="mb-4 text-xl font-semibold">General Information</h3>
            <form action="#">
              <div class="grid grid-cols-6 gap-6">
                <div class="col-span-6 sm:col-span-3">
                  <label for="first-name" class="block mb-2 text-sm font-medium text-gray-900">
                    First Name
                  </label>
                  <input
                    type="text"
                    name="first-name"
                    id="first-name"
                    class="shadow-sm bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-[#ff9f68] focus:border-[#ff9f68] block w-full p-2.5"
                    placeholder="John"
                    value={@current_user.first_name}
                    required
                  />
                </div>
                <div class="col-span-6 sm:col-span-3">
                  <label for="last-name" class="block mb-2 text-sm font-medium text-gray-900">
                    Last Name
                  </label>
                  <input
                    type="text"
                    name="last-name"
                    id="last-name"
                    class="shadow-sm bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-[#ff9f68] focus:border-[#ff9f68] block w-full p-2.5"
                    placeholder="Doe"
                    value={@current_user.last_name}
                    required
                  />
                </div>
                <div class="col-span-6 sm:col-span-3">
                  <label for="email" class="block mb-2 text-sm font-medium text-gray-900">
                    Email
                  </label>
                  <div class="relative">
                    <input
                      type="email"
                      name="email"
                      id="email"
                      class="shadow-sm bg-gray-100 border border-gray-300 text-gray-600 sm:text-sm rounded-lg focus:ring-[#ff9f68] focus:border-[#ff9f68] block w-full p-2.5 pr-20"
                      value={@current_user.email}
                      required
                      disabled
                    />
                    <button
                      type="button"
                      class="absolute inset-y-0 right-0 flex items-center px-3 text-xs font-medium uppercase text-[#ff9f68] hover:text-[#ff8c4c] hover:underline"
                      phx-click="open_email_change_modal"
                    >
                      Change
                    </button>
                  </div>
                </div>
                <div class="col-span-6 sm:col-span-3">
                  <label for="role" class="block mb-2 text-sm font-medium text-gray-900">
                    Role
                  </label>
                  <input
                    type="text"
                    name="role"
                    id="role"
                    class="shadow-sm bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-[#ff9f68] focus:border-[#ff9f68] block w-full p-2.5"
                    placeholder="Developer"
                  />
                </div>
                <div class="col-span-6 sm:col-full">
                  <button class="text-white bg-[#ff9f68] hover:bg-[#ff8c4c] focus:ring-4 focus:ring-[#ff9f68]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center">
                    Update account
                  </button>
                </div>
              </div>
            </form>
          </div>
          <!-- Email Notifications -->
          <div class="p-4 bg-white border border-gray-200 rounded-lg shadow-sm">
            <div class="flow-root">
              <h3 class="text-xl font-semibold mb-4">Email Notifications</h3>
              <div class="divide-y divide-gray-200">
                <div class="flex items-center justify-between py-4">
                  <div class="flex flex-col flex-grow">
                    <div class="text-lg font-semibold text-gray-900">Device Alerts</div>
                    <div class="text-base font-normal text-gray-500">
                      Get notified when any of your devices report issues
                    </div>
                  </div>
                  <label class="relative flex items-center cursor-pointer">
                    <input type="checkbox" value="" class="sr-only peer" />
                    <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-[#ff9f68]/50 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#ff9f68]">
                    </div>
                  </label>
                </div>

                <div class="flex items-center justify-between py-4">
                  <div class="flex flex-col flex-grow">
                    <div class="text-lg font-semibold text-gray-900">System Updates</div>
                    <div class="text-base font-normal text-gray-500">
                      Receive updates about system maintenance and new features
                    </div>
                  </div>
                  <label class="relative flex items-center cursor-pointer">
                    <input type="checkbox" value="" class="sr-only peer" checked />
                    <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-[#ff9f68]/50 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#ff9f68]">
                    </div>
                  </label>
                </div>
              </div>
              <div class="mt-6">
                <button class="text-white bg-[#ff9f68] hover:bg-[#ff8c4c] focus:ring-4 focus:ring-[#ff9f68]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center">
                  Update preferences
                </button>
              </div>
            </div>
          </div>
        </div>
        <!-- Right Column -->
        <div>
          <!-- Password Settings -->
          <div class="p-4 bg-white border border-gray-200 rounded-lg shadow-sm">
            <h3 class="mb-4 text-xl font-semibold">Update password</h3>
            <.simple_form
              for={@password_form}
              id="password_form"
              action={~p"/users/log_in?_action=password_updated"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
            >
              <input type="hidden" name="user[email]" value={@current_email} />
              <div class="flex flex-col space-y-4">
                <div>
                  <.input
                    field={@password_form[:current_password]}
                    name="current_password"
                    type="password"
                    label="Current password"
                    required
                    class="shadow-sm bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-[#ff9f68] focus:border-[#ff9f68] block w-full p-2.5"
                  />
                </div>
                <div>
                  <.input
                    field={@password_form[:password]}
                    type="password"
                    label="New password"
                    required
                    class="shadow-sm bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-[#ff9f68] focus:border-[#ff9f68] block w-full p-2.5"
                  />
                </div>
                <div>
                  <.input
                    field={@password_form[:password_confirmation]}
                    type="password"
                    label="Confirm password"
                    required
                    class="shadow-sm bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-[#ff9f68] focus:border-[#ff9f68] block w-full p-2.5"
                  />
                </div>
                <div class="pt-2">
                  <button
                    type="submit"
                    phx-disable-with="Changing..."
                    class="text-white bg-[#ff9f68] hover:bg-[#ff8c4c] focus:ring-4 focus:ring-[#ff9f68]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center"
                  >
                    Update password
                  </button>
                </div>
              </div>
            </.simple_form>
          </div>
        </div>
      </div>
      <%!-- ADD FOR MODULE --%>
      <%!-- <div>
        <.simple_form
          for={@module_form}
          id="module_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_module"
          phx-submit="update_module"
          phx-trigger-action={@trigger_submit}
        >
          <.inputs_for :let={f} field={@module_form[:module_settings]} id="module_settings">
            <.input field={f[:module_1]} type="checkbox" label="Module 1" />
            <.input field={f[:module_2]} type="checkbox" label="Module 2" />
            <.input field={f[:module_3]} type="checkbox" label="Module 3" />
          </.inputs_for>
          <:actions>
            <.button phx-disable-with="Changing...">Change Modules</.button>
          </:actions>
        </.simple_form>
      </div> --%>
    </div>

    <%= if @show_email_change_modal do %>
      <div
        id="email-change-modal"
        class="overflow-y-auto overflow-x-hidden fixed inset-0 z-50 flex justify-center items-center w-full h-full bg-black bg-opacity-50"
      >
        <div class="relative p-4 w-full max-w-md max-h-full">
          <%!-- Modal content --%>
          <div class="relative bg-white rounded-lg shadow-sm">
            <%!-- Modal header --%>
            <div class="flex items-center justify-between p-4 md:p-5 border-b rounded-t border-gray-200">
              <h3 class="text-xl font-semibold text-gray-900">
                Change Email Address
              </h3>
              <button
                type="button"
                phx-click="close_email_change_modal"
                class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center"
              >
                <svg
                  class="w-3 h-3"
                  aria-hidden="true"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 14 14"
                >
                  <path
                    stroke="currentColor"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
                  />
                </svg>
                <span class="sr-only">Close modal</span>
              </button>
            </div>

            <%!-- Modal body --%>
            <div class="p-4 md:p-5">
              <.form
                for={@email_form}
                id="email_form"
                phx-submit="update_email"
                phx-change="validate_email"
                class="space-y-4"
              >
                <div>
                  <label for="current-email" class="block mb-2 text-sm font-medium text-gray-900">
                    Old Email Address
                  </label>
                  <input
                    type="email"
                    name="current-email"
                    id="current-email"
                    class="bg-gray-100 border border-gray-300 text-gray-600 text-sm rounded-lg block w-full p-2.5"
                    value={@current_email}
                    disabled
                  />
                </div>
                <div>
                  <label for="user[email]" class="block mb-2 text-sm font-medium text-gray-900">
                    Type Your New Email Address
                  </label>
                  <%!-- #TODO: I have the org specific placeholder that I can use. --%>
                  <.input
                    field={@email_form[:email]}
                    type="email"
                    placeholder="name@example.com"
                    required
                    value=""
                    class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-[#ff9f68] focus:border-[#ff9f68] block w-full p-2.5"
                  />
                </div>
                <input
                  type="hidden"
                  name="current_password"
                  value={@email_form_current_password || ""}
                />
                <div class="flex justify-end space-x-2 pt-2">
                  <button
                    type="submit"
                    class="text-white bg-[#ff9f68] hover:bg-[#ff8c4c] focus:ring-4 focus:ring-[#ff9f68]/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center"
                  >
                    Change Email
                  </button>
                  <button
                    type="button"
                    class="text-gray-700 bg-gray-200 hover:bg-gray-300 focus:ring-4 focus:ring-gray-200/50 font-medium rounded-lg text-sm px-5 py-2.5 text-center"
                    phx-click="close_email_change_modal"
                  >
                    Close
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    # ADD FOR MODULE
    # module_changeset = Accounts.change_module_settings(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      # ADD FOR MODULE
      # |> assign(:module_form, to_form(module_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:show_email_change_modal, false)

    {:ok, assign(socket, page_title: "Settings")}
  end

  def handle_event("open_email_change_modal", _params, socket) do
    {:noreply, assign(socket, show_email_change_modal: true)}
  end

  def handle_event("close_email_change_modal", _params, socket) do
    {:noreply, assign(socket, show_email_change_modal: false)}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  # ADD FOR MODULE
  # def handle_event("validate_module", %{"user" => params}, socket) do
  #   module_form =
  #     socket.assigns.current_user
  #     |> Accounts.change_module_settings(params)
  #     |> Map.put(:action, :validate)
  #     |> to_form()

  #   {:noreply, assign(socket, module_form: module_form)}
  # end

  # def handle_event("update_module", %{"user" => params}, socket) do
  #   user = socket.assigns.current_user

  #   case Accounts.update_module_settings(user, params) do
  #     {:ok, user} ->
  #       module_form =
  #         user
  #         |> Accounts.change_module_settings(params)
  #         |> to_form()

  #       {:noreply, assign(socket, trigger_submit: true, module_form: module_form)}

  #     {:error, changeset} ->
  #       {:noreply, assign(socket, module_form: to_form(changeset))}
  #   end
  # end
end
