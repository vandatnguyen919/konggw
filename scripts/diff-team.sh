#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

team="${1:-}"
case "$team" in
  products|orders) ;;
  *) echo "Usage: $0 products|orders" >&2; exit 2 ;;
esac

deck gateway diff "/workspace/teams/$team/kong.yaml" \
  --select-tag "team:$team" --kong-addr "$DECK_KONG_ADDR"
