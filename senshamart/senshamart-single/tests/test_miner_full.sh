#!/bin/bash
set -e

echo "=== Miner Connection Test (Full Integration) ==="

# Specify the compose file (adjust if needed)
COMPOSE_FILE="compose.prod.yaml"

# Assume all services are manually started.
# Retrieve the miner container ID using docker-compose.
MINER_CONTAINER=$(docker-compose -f "${COMPOSE_FILE}" ps -q miner)
if [ -z "$MINER_CONTAINER" ]; then
    echo "ERROR: Miner container is not running. Please start all services manually."
    exit 1
fi
echo "Miner container ID: $MINER_CONTAINER"

# 1. Retrieve and print the generated settings.json from the miner container.
echo "Retrieving settings.json from the Miner container:"
docker exec "$MINER_CONTAINER" cat /usr/src/app/settings.json || {
    echo "ERROR: settings.json not found in miner container"
    exit 1
}

# 2. Test connectivity from the Miner to Fuseki.
echo "Testing connectivity from Miner to Fuseki..."
HTTP_STATUS=$(docker exec "$MINER_CONTAINER" curl --max-time 10 -s -o /dev/null -w "%{http_code}" http://fuseki:3030/ds)

echo "HTTP status from Fuseki endpoint: $HTTP_STATUS"
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Connectivity test: PASS"
else
    echo "Connectivity test: FAIL"
fi

# 3. Output the last 20 lines of the miner's logs for verification.
echo "Displaying last 20 lines from miner log:"
docker logs "$MINER_CONTAINER" --tail 20

echo "=== Miner Connection Test Completed ==="
