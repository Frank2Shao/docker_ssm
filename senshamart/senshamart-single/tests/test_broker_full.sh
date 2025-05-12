#!/bin/bash
set -e

COMPOSE_FILE="compose.dev.yaml"

echo "=== Broker Image Test (Full Integration) ==="

# 1. Identify the broker container
BROKER_CONTAINER=$(docker-compose -f "${COMPOSE_FILE}" ps -q broker)
if [ -z "$BROKER_CONTAINER" ]; then
  echo "ERROR: Broker container not running."
  exit 1
fi
echo "Broker container: $BROKER_CONTAINER"

# 2. Show settings.json
echo; echo "-- settings.json --"
docker exec "$BROKER_CONTAINER" cat /usr/src/app/settings.json \
  || { echo "ERROR: settings.json missing"; }

# 3. Fuseki HTTP Connectivity
echo; echo "-- Fuseki Connectivity (HTTP) --"
set +e
if docker exec "$BROKER_CONTAINER" sh -c "which curl" >/dev/null 2>&1; then
  HTTP_STATUS=$(docker exec "$BROKER_CONTAINER" \
    sh -c "curl -s -o /dev/null -w '%{http_code}' http://fuseki:3030/ds")
  RET=$?
elif docker exec "$BROKER_CONTAINER" sh -c "which wget" >/dev/null 2>&1; then
  docker exec "$BROKER_CONTAINER" sh -c "wget --spider -q http://fuseki:3030/ds"
  RET=$?
  HTTP_STATUS=$([ $RET -eq 0 ] && echo 200 || echo "000")
else
  echo "✘ No HTTP client available"
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
for peer in miner wallet; do
  set +e
  docker exec "$BROKER_CONTAINER" ping -c 1 "$peer" >/dev/null 2>&1
  RET=$?
  set -e
  if [ $RET -eq 0 ]; then
    echo "✔ Can ping $peer"
  else
    echo "✘ Cannot ping $peer"
  fi
done

# 5. Tail logs
echo; echo "-- Recent broker log --"
docker logs "$BROKER_CONTAINER" --tail 20 || true

echo; echo "=== Broker Image Test Completed ==="
