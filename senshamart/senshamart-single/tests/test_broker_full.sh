#!/bin/bash
set -e

echo "=== Broker Image Test (Full Integration) ==="

# Specify the compose file (adjust if needed)
COMPOSE_FILE="compose..yaml"

# Assume all services are manually started.
# Retrieve the broker container ID using docker-compose.
BROKER_CONTAINER=$(docker-compose -f "${COMPOSE_FILE}" ps -q broker)
if [ -z "$BROKER_CONTAINER" ]; then
    echo "ERROR: Broker container is not running. Please start all services manually."
    exit 1
fi
echo "Broker container ID: $BROKER_CONTAINER"

# 1. Retrieve and print the generated settings.json from the broker container.
echo "Retrieving settings.json from the Broker container:"
docker exec "$BROKER_CONTAINER" cat /usr/src/app/settings.json || {
    echo "ERROR: settings.json not found in broker container"
    exit 1
}

# 2. Verify environment substitution and check the broker logs.
echo "Verifying broker's environment substitution and logging..."
docker logs "$BROKER_CONTAINER" --tail 20

# 3. Test connectivity from the Broker to Fuseki.
echo "Testing connectivity from Broker to Fuseki..."
HTTP_STATUS=$(docker exec "$BROKER_CONTAINER" curl -s -o /dev/null -w "%{http_code}" http://fuseki:3030/ds)
echo "HTTP status from Fuseki endpoint (broker): $HTTP_STATUS"
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "Broker connectivity test: PASS"
else
    echo "Broker connectivity test: FAIL"
fi

echo "=== Broker Image Test Completed ==="
