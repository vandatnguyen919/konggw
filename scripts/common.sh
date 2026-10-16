#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KONG_ADMIN_URL="${KONG_ADMIN_URL:-http://localhost:8001}"
DECK_KONG_ADDR="${DECK_KONG_ADDR:-http://kong-cp:8001}"
DECK_IMAGE="${DECK_IMAGE:-kong/deck:v1.68.0}"

deck() {
  (cd "$ROOT_DIR" && MSYS_NO_PATHCONV=1 docker compose --profile tools run --rm deck "$@")
}

require_tools() {
  command -v docker >/dev/null || { echo "docker is required" >&2; exit 1; }
  command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
}
