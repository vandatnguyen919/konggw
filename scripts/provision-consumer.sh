#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

require_tools
consumer="${CONSUMER_NAME:-runtime-demo}"
key="${CONSUMER_KEY:-$(openssl rand -hex 12)}"

curl -fsS -X POST "$KONG_ADMIN_URL/consumers" \
  --data-urlencode "username=$consumer" >/dev/null 2>&1 || true
curl -fsS -X POST "$KONG_ADMIN_URL/consumers/$consumer/key-auth" \
  --data-urlencode "key=$key" >/dev/null

for proxy in http://localhost:8000 http://localhost:8010; do
  status=0
  for attempt in {1..15}; do
    status="$(curl -sS -o /dev/null -w '%{http_code}' "$proxy/api/products" \
      -H "X-API-Key: $key")"
    [[ "$status" == "200" ]] && break
    sleep 2
  done
  [[ "$status" == "200" ]] || {
    echo "Consumer failed through $proxy after waiting for config replication: HTTP $status" >&2
    exit 1
  }
done

echo "Consumer $consumer is active on both data planes."
echo "API key: $key"
