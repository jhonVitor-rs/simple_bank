#!/bin/bash
# Docker entrypoint script.

# Define as variáveis de ambiente necessárias
export PGHOST=${HOSTNAME}
export PGPORT=5432
export PGUSER=${POSTGRES_USER}
export PGPASSWORD=${POSTGRES_PASSWORD}
export PGDATABASE=${POSTGRES_DB}

# Wait until Postgres is ready
echo "Testing if Postgres is accepting connections. ${PGHOST} ${PGPORT} ${PGUSER}"
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."
  mix ecto.setup
  # mix test

  echo "Database $PGDATABASE created."
fi

exec mix phx.server
