#!/bin/bash

# AI generated with ChatGPT.
# Maintained by Ramon Asuncion

# Run gitlab-runner unregister --all-runners to unregister any existing runners.
# Run tail -f $HOME/.gitlab-runner/logs/gitlab-runner.log to see the logs in real time.

GITLAB_URL="https://gitlab.bucknell.edu"
REGISTRATION_TOKEN="glrt-t3_cmsPKz9Pg3ZWCdqzp6wb" # KEEP TOKEN PRIVATE.
RUNNER_NAME="shell-executor-runner--$(hostname)"
CONFIG_DIR="$HOME/.gitlab-runner"

# Postgres is needed to run mix test. I have installed it previously without sudo using this github post.
# This is only necessary because I don't have access to the postgresql database installed on linuxremote.
# https://gist.github.com/yunpengn/832aceac6998e2f894e5780229920cb5

# I've installed it in the worst directory.
PG_LOG="$HOME/.local/logfile"
PG_DATA="$HOME/.local/data"
PG_BIN="$HOME/.local/bin"

setup_postgresql() {
    echo "Setting up PostgreSQL..."

    # Check if PostgreSQL is running
    if ! "$PG_BIN/pg_ctl" status -D "$PG_DATA" > /dev/null 2>&1; then
        echo "Starting PostgreSQL..."
        "$PG_BIN/pg_ctl" -D "$PG_DATA" -l "$PG_LOG" start

        # Wait for PostgreSQL to start
        sleep 5
    else
        echo "PostgreSQL is already running"
    fi

    # Create test database if it doesn't exist
    if ! PGDATA="$PG_DATA" "$PG_BIN/psql" -d postgres -lqt | cut -d \| -f 1 | grep -qw ticketme_test; then
        echo "Creating test database..."
        PGDATA="$PG_DATA" "$PG_BIN/createdb" ticketme_test
    fi
}

reset_database() {
    echo "Resetting test database..."
    PGDATA="$PG_DATA" "$PG_BIN/dropdb" ticketme_test --if-exists
    PGDATA="$PG_DATA" "$PG_BIN/createdb" ticketme_test
}

if [ "$1" == "--reset-db" ]; then
    setup_postgresql
    reset_database
    exit 0
fi

cleanup() {
    echo "Cleaning up services..."
    "$PG_BIN/pg_ctl" -D "$PG_DATA" stop
    [ -f "$CONFIG_DIR/gitlab-runner.pid" ] && kill $(cat "$CONFIG_DIR/gitlab-runner.pid")
    exit 1
}

# Check if running on correct host
HOSTNAME=$(hostname)
if [[ ! $HOSTNAME =~ ^linuxremote[1-3]\.bucknell\.edu$ ]]; then
    echo "Run this script on linuxremote."
    exit 1
fi

setup_postgresql || {
    echo "Failed to setup PostgreSQL"
    exit 1
}

# Create config directory
mkdir -p "$CONFIG_DIR"

# Check if runner is already registered
if [ -f "$CONFIG_DIR/config.toml" ]; then
    echo "Removing existing runner configuration..."
    rm "$CONFIG_DIR/config.toml"
fi

# Register the runner
gitlab-runner register \
  --non-interactive \
  --url "$GITLAB_URL" \
  --token "$REGISTRATION_TOKEN" \
  --name "$RUNNER_NAME" \
  --executor "shell" \
  --config "$CONFIG_DIR/config.toml"

if [ $? -ne 0 ]; then
    echo "Error: Failed to register runner"
    exit 1
fi

# Create logs directory
mkdir -p "$CONFIG_DIR/logs"

# Check if runner is already running
if [ -f "$CONFIG_DIR/gitlab-runner.pid" ]; then
    OLD_PID=$(cat "$CONFIG_DIR/gitlab-runner.pid")
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "Runner is already running with PID $OLD_PID"
        exit 1
    else
        rm "$CONFIG_DIR/gitlab-runner.pid"
    fi
fi

# Start the runner
echo "Starting GitLab runner..."
nohup gitlab-runner run \
  --config "$CONFIG_DIR/config.toml" \
  > "$CONFIG_DIR/logs/gitlab-runner.log" 2>&1 &

# Save PID and verify process is running
PID=$!
sleep 2
if ps -p $PID > /dev/null 2>&1; then
    echo $PID > "$CONFIG_DIR/gitlab-runner.pid"
    echo "GitLab Runner has been started in the background (PID: $PID)"
    echo "Log file: $CONFIG_DIR/logs/gitlab-runner.log"
    echo "PID file: $CONFIG_DIR/gitlab-runner.pid"
else
    echo "Error: Runner failed to start. Check logs for details:"
    tail -n 10 "$CONFIG_DIR/logs/gitlab-runner.log"
    cleanup
    exit 1
fi