#!/usr/bin/env bash
# Loads .env into environment variables, then starts the API on port 8080.
# The Spring Boot app reads environment variables, not the .env file itself.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
[ -f .env ] || { echo "Missing .env. Run: cp .env.example .env and edit it." >&2; exit 1; }
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|'#'*) continue ;; esac
  export "${line%%=*}=${line#*=}"
done < .env
exec mvn spring-boot:run
