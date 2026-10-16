#!/usr/bin/env bash
set -euo pipefail

key="${CONSUMER_KEY:-}"
[[ -n "$key" ]] || { echo "Set CONSUMER_KEY from provision-consumer.sh." >&2; exit 2; }

docker compose stop kong-cp
trap 'docker compose start kong-cp >/dev/null' EXIT
for proxy in http://localhost:8000 http://localhost:8010; do
  status="$(curl -sS -o /dev/null -w '%{http_code}' "$proxy/api/products" \
    -H "X-API-Key: $key")"
  [[ "$status" == "200" ]] || { echo "Outage demo failed at $proxy" >&2; exit 1; }
done
echo "Both data planes served cached configuration while the control plane was stopped."
docker compose start kong-cp >/dev/null
trap - EXIT
until curl -fsS http://localhost:8001/clustering/status >/dev/null; do sleep 2; done
echo "Control plane restarted and clustering endpoint is responding."
