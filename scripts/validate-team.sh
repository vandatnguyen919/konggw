#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

team="${1:-}"
case "$team" in
  products|orders) ;;
  *) echo "Usage: $0 products|orders" >&2; exit 2 ;;
esac

deck file validate "/workspace/teams/$team/kong.yaml"
echo "team-$team configuration is valid."
