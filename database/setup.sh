#!/usr/bin/env bash
# Creates the database owned by canteen_admin, runs migrations and sample data
# as that account, then applies access-control scripts 03-06.
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
DB_USER="${cfg[DB_USER]:-}"
DB_PASSWORD="${cfg[DB_PASSWORD]:-}"
DB_ADMIN_USER="${cfg[DB_ADMIN_USER]:-canteen_admin}"
DB_ADMIN_PASSWORD="${cfg[DB_ADMIN_PASSWORD]:-}"
[ "$DB_USER" = "canteen_app" ] || { echo "DB_USER must be canteen_app for the application." >&2; exit 1; }
[ "$DB_ADMIN_USER" = "canteen_admin" ] || { echo "DB_ADMIN_USER must be canteen_admin." >&2; exit 1; }
[ -n "$DB_PASSWORD" ] || { echo "DB_PASSWORD is empty in .env." >&2; exit 1; }
[ -n "$DB_ADMIN_PASSWORD" ] || { echo "DB_ADMIN_PASSWORD is empty in .env." >&2; exit 1; }

command -v psql >/dev/null || { echo "psql not found. Install PostgreSQL client tools." >&2; exit 1; }

if [ -z "${PGSUPERPASSWORD:-}" ]; then
  read -r -s -p "Password of the PostgreSQL superuser (postgres): " PGSUPERPASSWORD; echo
fi

echo "Creating database '$DB_NAME' owned by '$DB_ADMIN_USER' if missing..."
PGPASSWORD="$PGSUPERPASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d postgres \
  -v ON_ERROR_STOP=1 -q \
  -v dbname="$DB_NAME" -v dbuser="$DB_ADMIN_USER" \
  -f database/init/001_create_role_and_database.sql

export PGOPTIONS="-c client_min_messages=warning"

run_sql() {
  PGPASSWORD="$DB_ADMIN_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 -q -f "$1"
}

for f in database/migrations/*.sql; do echo "Migration: $f"; run_sql "$f"; done
for f in database/seed/*.sql;       do echo "Seed:      $f"; run_sql "$f"; done
for f in \
  db-access-control/03-database-privileges.sql \
  db-access-control/04-schema-and-table-privileges.sql \
  db-access-control/05-sequence-privileges.sql \
  db-access-control/06-default-privileges.sql; do
  echo "Access control: $f"
  PGPASSWORD="$PGSUPERPASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 -q -f "$f"
done

echo "Done. Database '$DB_NAME' is ready. Review and run db-access-control/07-security-restrictions.sql separately."
