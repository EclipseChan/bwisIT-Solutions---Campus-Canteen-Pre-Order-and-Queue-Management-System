#!/usr/bin/env bash
# TEMPLATE ONLY — no backup has been created.
# Configure PGHOST, PGPORT, PGDATABASE, PGUSER and BACKUP_DIR locally after
# confirming the target and authorization. Do not put passwords in this file
# or command line. Use approved .pgpass or an interactive prompt.
set -euo pipefail

for name in PGHOST PGPORT PGDATABASE PGUSER BACKUP_DIR; do
  if [[ -z "${!name:-}" ]]; then
    printf 'Required environment variable %s is not set.\n' "$name" >&2
    exit 2
  fi
done
case "$BACKUP_DIR" in
  /*) ;;
  *)
    printf 'BACKUP_DIR must be an absolute path outside this repository.\n' >&2
    exit 2
    ;;
esac

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/../.." && pwd -P)"
mkdir -p -- "$BACKUP_DIR"
backup_root="$(cd -- "$BACKUP_DIR" && pwd -P)"
case "$backup_root" in
  "$repo_root"|"$repo_root"/*)
    printf 'BACKUP_DIR must be outside this repository.\n' >&2
    exit 2
    ;;
esac

stamp="$(date '+%Y%m%d-%H%M%S')"
safe_database_name="$(printf '%s' "$PGDATABASE" | sed 's/[^A-Za-z0-9_.-]/_/g')"
dump_path="$backup_root/${safe_database_name}_activity6_${stamp}.dump"
pg_dump --host="$PGHOST" --port="$PGPORT" --username="$PGUSER" \
  --dbname="$PGDATABASE" --format=custom --file="$dump_path"

if command -v sha256sum >/dev/null 2>&1; then
  checksum="$(sha256sum "$dump_path" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
  checksum="$(shasum -a 256 "$dump_path" | awk '{print $1}')"
else
  printf 'Neither sha256sum nor shasum is available; checksum was not recorded.\n' >&2
  exit 3
fi

bytes="$(wc -c < "$dump_path" | tr -d '[:space:]')"
printf 'Backup created: %s; bytes=%s; SHA256=%s; local_time=%s\n' \
  "$(basename -- "$dump_path")" "$bytes" "$checksum" "$(date '+%Y-%m-%dT%H:%M:%S%z')"
printf 'Keep this data-bearing dump outside Git and the submission ZIP.\n'
