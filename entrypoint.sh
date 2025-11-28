#!/bin/bash
set -e

# Create storage directory if it doesn't exist (works with mounted volumes)
mkdir -p storage
chmod 777 storage 2>/dev/null || echo "Note: Could not chmod storage (running as non-root user, this is normal)"

# Check if we're in development mode
if [ "$RAILS_ENV" = "development" ]; then
  echo "Running in development mode - preparing database..."

  # Ensure BUNDLE_WITHOUT is unset or empty to install all gems including test
  if [ -n "$BUNDLE_WITHOUT" ] && [ "$BUNDLE_WITHOUT" != "" ]; then
    unset BUNDLE_WITHOUT
  fi

  # Check bundle dependencies
  # Gems are already installed during Docker build, so we only need to install
  # if Gemfile has changed (via volume mount) and new gems are needed
  echo "Checking bundle dependencies..."
  if bundle check >/dev/null 2>&1; then
    echo "All gems are installed."
  else
    echo "Gemfile may have changed. Installing missing gems to local path..."
    # Use local bundle path to avoid permission issues with system path
    export BUNDLE_PATH="/rails/vendor/bundle"
    mkdir -p "${BUNDLE_PATH}"
    bundle install
  fi

  # Create database if it doesn't exist
  ./bin/rails db:create || true
  
  # Run migrations
  ./bin/rails db:migrate

  # Run seed
  ./bin/rails db:seed

  # Enable SQLite WAL mode for better concurrency
  if [ -f storage/development.sqlite3 ]; then
    echo "PRAGMA journal_mode=WAL;" | sqlite3 storage/development.sqlite3 || true
  fi
elif [ "$RAILS_ENV" = "production" ]; then
  echo "Running in production mode - preparing database..."
  ./bin/rails db:prepare
fi

# Start the server (or whatever command was passed)
exec "$@"

