defmodule Mix.Tasks.ResetTables do
  use Mix.Task

  @shortdoc "Drops, recreates and migrates database."

  def run(_) do
    # Start the application to ensure Repo is loaded
    Mix.Task.run("app.start")

    alias Ticketme.Repo
    alias Ecto.Adapters.SQL

    Mix.shell().info("Resetting tables...")

    # Drop all tables
    drop_all_tables()

    # Run migrations
    Mix.Task.run("ecto.migrate")

    # Seed the database
    # Mix.Task.run("run", ["priv/repo/seeds.exs"])
  end

  defp drop_all_tables do
    alias Ecto.Adapters.SQL
    alias Ticketme.Repo

    query = """
    DO $$ DECLARE
      r RECORD;
    BEGIN
      FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = current_schema()) LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
      END LOOP;
    END $$;
    """

    SQL.query!(Repo, query, [])
    Mix.shell().info("Dropped all tables.")
  end
end
