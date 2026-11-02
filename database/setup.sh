#!/usr/bin/env bash
# Creates the database login and database from .env, runs every migration in
# order, then loads the sample data. Safe to run again.
# Usage: ./database/setup.sh   (from the repository root)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

[ -f .env ] || { echo "Missing .env. Run: cp .env.example .env and edit it." >&2; exit 1; }

# Read KEY=VALUE lines without executing them, so passwords may contain any character.
declare -A cfg
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|'#'*) continue ;; esac
  key="${line%%=*}"; val="${line#*=}"
  cfg["$key"]="$val"
done < .env

DB_HOST="${cfg[DB_HOST]:-localhost}"
DB_PORT="${cfg[DB_PORT]:-5432}"
DB_NAME="${cfg[DB_NAME]:-canteen_db}"
DB_USER="${cfg[DB_USER]:-canteen_admin}"
DB_PASSWORD="${cfg[DB_PASSWORD]:-}"
[ -n "$DB_PASSWORD" ] || { echo "DB_PASSWORD is empty in .env." >&2; exit 1; }

command -v psql >/dev/null || { echo "psql not found. Install PostgreSQL client tools." >&2; exit 1; }

if [ -z "${PGSUPERPASSWORD:-}" ]; then
  read -r -s -p "Password of the PostgreSQL superuser (postgres): " PGSUPERPASSWORD; echo
fi

echo "Creating login '$DB_USER' and database '$DB_NAME' if missing..."
PGPASSWORD="$PGSUPERPASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d postgres \
  -v ON_ERROR_STOP=1 -q \
  -v dbname="$DB_NAME" -v dbuser="$DB_USER" -v dbpass="$DB_PASSWORD" \
  -f database/init/001_create_role_and_database.sql

export PGOPTIONS="-c client_min_messages=warning"

run_sql() {
  PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 -q -f "$1"
}

for f in database/migrations/*.sql; do echo "Migration: $f"; run_sql "$f"; done
for f in database/seed/*.sql;       do echo "Seed:      $f"; run_sql "$f"; done

echo "Done. Database '$DB_NAME' is ready."
