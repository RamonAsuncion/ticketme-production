# defmodule LiveViewDashboardWeb.Components.ModuleComponent do
#   use Phoenix.LiveComponent
#   use TicketmeWeb, :live_view

#   @impl true
#   def render(assigns) do
#     ~H"""
#     <div class="w-full md:w-[250px] flex flex-col min-h-0">
#       <div class="flex-1 border border-gray-200 bg-gray-50 p-5 rounded-lg">
#         <h3 class="font-bold text-sm mb-3">Available Modules</h3>
#         <div class="space-y-2 overflow-y-auto">
#           <%!--  --%>
#           <%= for module <- @available_modules do %>
#             <div
#               id={"module-#{module.id}"}
#               class="flex items-center gap-2 p-3 bg-white rounded-lg border border-gray-200 cursor-move hover:border-blue-500 transition-colors"
#               draggable="true"
#               data-module-id={module.id}
#             >
#               <.icon name={module.icon} class="w-5 h-5 text-gray-500" />
#               <span class="text-sm font-medium text-gray-700"><%= module.name %></span>
#             </div>
#           <% end %>
#         </div>
#       </div>
#     </div>
#     """
#   end

#   @impl true
#   def update(assigns, socket) do
#     {:ok, assign(socket, available_modules: assigns.available_modules)}
#   end

#   @impl true
#   def mount(socket) do
#     {:ok, socket}
#   end
# end
