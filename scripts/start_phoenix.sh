mix deps.get
mix ecto.reset
mix ecto.migrate
npm install --prefix assets
mix phx.server
echo "Running at http://localhost:4000"
