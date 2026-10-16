#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

deck gateway sync /workspace/platform/kong.yaml \
  --select-tag owner:platform --kong-addr "$DECK_KONG_ADDR"
