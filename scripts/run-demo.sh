#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  if [ "${KEEP_STACK:-false}" != "true" ]; then
    docker compose down -v >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

echo "==> Starting Kafka and Schema Registry"
docker compose up -d

echo "==> Building the demo"
mvn -B clean package

echo "==> Running contract scenarios"
bash scripts/verify-contract-scenarios.sh

echo
printf '%s\n' "All contract scenarios passed."
if [ "${KEEP_STACK:-false}" = "true" ]; then
  printf '%s\n' "Kafka and Schema Registry are still running because KEEP_STACK=true."
else
  printf '%s\n' "Kafka and Schema Registry will now be stopped and removed."
fi
