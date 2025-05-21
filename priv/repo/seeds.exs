# Script for populating the database and converting data to JSON.
# Run this script with:
#
#     mix run priv/repo/seeds.exs
#

alias Ticketme.Accounts

case Accounts.get_user_by_email("admin@bucknell.edu") do
  nil ->
    {:ok, _admin} =
    Accounts.register_user(%{
      email: "admin@bucknell.edu",
      password: "bucknell1234",
      first_name: "Admin",
      last_name: "User"
    })

    IO.puts("Admin user created.")
  _user ->
    IO.puts("Admin user already created")
end
