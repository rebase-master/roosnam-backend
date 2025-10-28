#!/bin/bash
set -e

# Enable SQLite WAL mode for better concurrency
echo "PRAGMA journal_mode=WAL;" | sqlite3 db/production.sqlite3 || true

# Migrate database
bundle exec rails db:migrate

# Start the server
exec "$@"

