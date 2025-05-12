#!/bin/bash
set -e

COMPOSE_FILE="compose.dev.yaml"

echo "=== Miner Connection Test (Full Integration) ==="

# 1. Identify the miner container
MINER_CONTAINER=$(docker-compose -f "${COMPOSE_FILE}" ps -q miner)
if [ -z "$MINER_CONTAINER" ]; then
  echo "ERROR: Miner container not running."
  exit 1
fi
echo "Miner container: $MINER_CONTAINER"

# 2. Show settings.json
echo; echo "-- settings.json --"
docker exec "$MINER_CONTAINER" cat /usr/src/app/settings.json \
  || { echo "ERROR: settings.json missing"; }

# 3. Fuseki HTTP Connectivity
echo; echo "-- Fuseki Connectivity (HTTP) --"
set +e
# Try curl first
docker exec "$MINER_CONTAINER" sh -c "which curl" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  HTTP_STATUS=$(docker exec "$MINER_CONTAINER" \
    sh -c "curl -s -o /dev/null -w '%{http_code}' http://fuseki:3030/ds")
  RET=$?
elif docker exec "$MINER_CONTAINER" sh -c "which wget" >/dev/null 2>&1; then
  # fallback to wget spider
  docker exec "$MINER_CONTAINER" sh -c "wget --spider -q http://fuseki:3030/ds"
  RET=$?
  HTTP_STATUS=$([ $RET -eq 0 ] && echo 200 || echo "000")
else
  echo "✘ Neither curl nor wget available for HTTP test"
  RET=1
fi
set -e

if [ $RET -ne 0 ]; then
  echo "✘ HTTP test failed (exit code $RET)"
else
  echo "HTTP status: $HTTP_STATUS"
  if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✔ Fuseki connectivity: PASS"
  else
    echo "✘ Fuseki connectivity: FAIL"
  fi
fi

# 4. Peer Discovery via ping
echo; echo "-- Peer Discovery (ping) --"
for peer in broker wallet; do
  set +e
  docker exec "$MINER_CONTAINER" ping -c 1 "$peer" >/dev/null 2>&1
  RET=$?
  set -e
  if [ $RET -eq 0 ]; then
    echo "✔ Can ping $peer"
  else
    echo "✘ Cannot ping $peer"
  fi
done

# 5. Tail logs
echo; echo "-- Recent miner log --"
docker logs "$MINER_CONTAINER" --tail 20 || true

echo; echo "=== Miner Connection Test Completed ==="

