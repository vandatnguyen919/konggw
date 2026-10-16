#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for fixture in missing-tag platform-plugin service-without-auth; do
  if "$ROOT_DIR/scripts/policy-check.sh" "$ROOT_DIR/scripts/fixtures/$fixture" >/dev/null 2>&1; then
    echo "Policy unexpectedly accepted $fixture" >&2
    exit 1
  fi
done
"$ROOT_DIR/scripts/policy-check.sh" "$ROOT_DIR/teams"
echo "All policy fixtures behaved as expected."
