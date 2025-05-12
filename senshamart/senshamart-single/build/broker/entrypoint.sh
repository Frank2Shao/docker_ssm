#!/bin/sh
set -e  # Exit on error

echo "=== Loaded settings.json ==="
cat /usr/src/app/settings.json
echo "============================"

# Ensure output directory exists
mkdir -p /usr/src/app/build/broker/data

# Change to the broker directory so the blockchain.db is created there
cd /usr/src/app/build/broker/data

# Run the broker application and redirect output to broker.out
echo "Starting broker application..."
node /usr/src/app/build/broker/broker-app.js > /usr/src/app/build/broker/data/broker.out 2>&1

# Optionally, you can output the result to stdout as well
echo "Broker app has finished. Check broker.out for details."
