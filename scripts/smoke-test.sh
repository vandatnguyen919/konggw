#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
admin_url="${KONG_ADMIN_URL_LOCAL:-http://localhost:8001}"

echo "Building Java services..."
./gradlew build

echo "Checking container health..."
health="$(docker compose ps --format '{{.Service}} {{.Health}} {{.State}}')"
for service in postgres products-service orders-service kong-cp kong-dp-products kong-dp-orders; do
  grep -Eq "^$service healthy " <<< "$health" || {
    echo "Expected healthy container: $service" >&2
    echo "$health" >&2
    exit 1
  }
done

echo "Checking Manager and control-plane clustering..."
[[ "$(curl -sS -o /dev/null -w '%{http_code}' http://localhost:8002)" == "200" ]]
data_planes="$(curl -fsS "$admin_url/clustering/data-planes")"
[[ "$(grep -o '"sync_status":"normal"' <<< "$data_planes" | wc -l)" -ge 2 ]]

echo "Checking policy and team isolation..."
bash scripts/policy-fixture-test.sh
bash scripts/sync-platform.sh
bash scripts/sync-team.sh products
products_state="$(curl -fsS "$admin_url/services")"
grep -Fq '"name":"orders-service"' <<< "$products_state"
bash scripts/sync-team.sh orders
orders_state="$(curl -fsS "$admin_url/services")"
grep -Fq '"name":"products-service"' <<< "$orders_state"

assert_status() {
  local expected="$1"
  shift
  local actual
  actual="$(curl -sS -o /tmp/kong-smoke-body -w '%{http_code}' "$@")"
  [[ "$actual" == "$expected" ]] || {
    echo "Expected HTTP $expected, got $actual" >&2
    cat /tmp/kong-smoke-body >&2
    exit 1
  }
}

echo "Checking unauthenticated rejection..."
assert_status 401 http://localhost:8000/api/products

echo "Provisioning a runtime consumer on the control plane..."
consumer_name="smoke-$(date +%s)"
provisioned="$(CONSUMER_NAME="$consumer_name" bash scripts/provision-consumer.sh)"
key="$(awk '/API key:/ {print $3}' <<< "$provisioned")"
[[ -n "$key" ]] || { echo "Consumer key was not returned" >&2; exit 1; }

for proxy in http://localhost:8000 http://localhost:8010; do
  echo "Checking authenticated traffic through $proxy..."
  assert_status 200 "$proxy/api/products" -H "X-API-Key: $key"
  grep -Fq '"service":"products-service"' /tmp/kong-smoke-body
  grep -Fq "\"x-consumer-username\":\"$consumer_name\"" /tmp/kong-smoke-body
  grep -Eq '"x-correlation-id":"[^"]+"' /tmp/kong-smoke-body
done

echo "Checking the orders team route..."
assert_status 200 http://localhost:8010/api/orders -H "X-API-Key: $key"
grep -Fq '"service":"orders-service"' /tmp/kong-smoke-body

echo "Checking rate limiting..."
assert_status 200 "http://localhost:8000/api/products" -H "X-API-Key: $key"
assert_status 429 "http://localhost:8000/api/products" -H "X-API-Key: $key"

echo "Smoke test passed. Visual Manager review remains judgment pending."
