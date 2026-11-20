#!/bin/bash
set -e

# Remove stale PID file if it exists
rm -f tmp/pids/server.pid

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -q 2>/dev/null; do
  sleep 2
done
echo "PostgreSQL is ready!"

export PGPASSWORD=$DB_PASSWORD

# Function to check if schema is fully loaded (check if core table exists)
schema_complete() {
  psql -h $DB_HOST -U $DB_USERNAME -d $DB_NAME -tAc "SELECT to_regclass('oh.projects')" 2>/dev/null | grep -q "oh.projects"
}

# Function to check if database exists
db_exists() {
  psql -h $DB_HOST -U $DB_USERNAME -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>/dev/null | grep -q 1
}

# Check if this is first run or restart
if db_exists && schema_complete; then
  echo "Database ready, starting application..."
else
  echo "First run detected, setting up database..."

  # Create database if it doesn't exist
  if ! db_exists; then
    echo "Creating database..."
    bundle exec rake db:create
  fi

  # Load structure (skip invalid \restrict line if present)
  # structure.sql already includes all migrations, no need to run db:migrate
  echo "Loading schema from structure.sql..."
  if head -1 db/structure.sql | grep -q '\\restrict'; then
    tail -n +2 db/structure.sql | psql -h $DB_HOST -U $DB_USERNAME -d $DB_NAME
  else
    psql -h $DB_HOST -U $DB_USERNAME -d $DB_NAME < db/structure.sql
  fi

  echo "Database setup complete!"
fi

exec "$@"
