#!/bin/bash
set -e

# Create storage directory if it doesn't exist (works with mounted volumes)
mkdir -p storage
chmod 777 storage 2>/dev/null || true

# Check if we're in development mode
if [ "$RAILS_ENV" = "development" ]; then
  echo "Running in development mode - preparing database..."

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

