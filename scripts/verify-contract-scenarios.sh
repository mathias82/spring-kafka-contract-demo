#!/usr/bin/env bash
set -euo pipefail

APP_PID=""
APP_PORT=""

cleanup_app() {
  if [ -n "${APP_PID}" ] && kill -0 "${APP_PID}" 2>/dev/null; then
    kill "${APP_PID}" 2>/dev/null || true
    wait "${APP_PID}" 2>/dev/null || true
  fi
  APP_PID=""
  APP_PORT=""
}

trap cleanup_app EXIT

start_app() {
  local schema_file="$1"
  local log_file="$2"
  local port="$3"

  cleanup_app
  rm -f "$log_file"
  APP_PORT="$port"

  mvn -B spring-boot:run \
    -Dspring-boot.run.arguments="--server.port=${port} --kafka.contract.subjects[0].schema-file=classpath:schemas/${schema_file}" \
    >"$log_file" 2>&1 &
  APP_PID=$!
}

wait_for_ready() {
  local log_file="$1"
  local url="http://localhost:${APP_PORT}/api/orders/events"

  for attempt in {1..60}; do
    if curl --fail --silent "$url" >/dev/null; then
      return 0
    fi

    if ! kill -0 "$APP_PID" 2>/dev/null; then
      echo "Application exited before becoming ready"
      cat "$log_file"
      return 1
    fi

    sleep 2
  done

  echo "Application did not become ready"
  cat "$log_file"
  return 1
}

echo "=== Scenario 1: baseline v1 starts and completes Kafka round trip ==="
start_app "order-event-v1.avsc" "scenario-v1.log" 18081
wait_for_ready "scenario-v1.log"

order_id="scenario-$(date +%s)-$RANDOM"
curl --fail --silent \
  -H 'Content-Type: application/json' \
  -d "{\"orderId\":\"$order_id\",\"amount\":42.50,\"createdAt\":\"2026-08-30T00:00:00Z\"}" \
  "http://localhost:${APP_PORT}/api/orders" >/dev/null

for attempt in {1..60}; do
  events="$(curl --fail --silent "http://localhost:${APP_PORT}/api/orders/events")"
  if printf '%s' "$events" | grep -Fq "$order_id"; then
    echo "PASS: v1 round trip observed for $order_id"
    break
  fi

  if ! kill -0 "$APP_PID" 2>/dev/null; then
    echo "Application exited before event was consumed"
    cat scenario-v1.log
    exit 1
  fi

  if [ "$attempt" = "60" ]; then
    echo "Produced order was not observed by the consumer"
    cat scenario-v1.log
    exit 1
  fi

  sleep 2
done

cleanup_app

echo "=== Scenario 2: backward-compatible v2 is accepted at startup ==="
start_app "order-event-v2.avsc" "scenario-v2.log" 18082
wait_for_ready "scenario-v2.log"
echo "PASS: v2 compatible evolution accepted"
cleanup_app

echo "=== Scenario 3: breaking v3 is rejected at startup ==="
start_app "order-event-v3.avsc" "scenario-v3.log" 18083

for attempt in {1..45}; do
  if ! kill -0 "$APP_PID" 2>/dev/null; then
    wait "$APP_PID" 2>/dev/null || true
    APP_PID=""

    if grep -Eqi "Schema is NOT compatible|IncompatibleSchemaException|not compatible|compatibility.*false" scenario-v3.log; then
      echo "PASS: v3 breaking evolution rejected"
      exit 0
    fi

    echo "Application failed, but not for the expected contract incompatibility"
    cat scenario-v3.log
    exit 1
  fi

  if curl --fail --silent "http://localhost:${APP_PORT}/api/orders/events" >/dev/null; then
    echo "Breaking v3 schema unexpectedly allowed the application to start"
    cat scenario-v3.log
    exit 1
  fi

  sleep 2
done

echo "Application did not fail fast for breaking v3 schema"
cat scenario-v3.log
exit 1
