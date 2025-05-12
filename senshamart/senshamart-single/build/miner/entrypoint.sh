#!/bin/sh
set -e  # Exit on error

echo "=== Loaded settings.json ==="
cat /usr/src/app/settings.json
echo "============================"

# Ensure output directory exists
mkdir -p /usr/src/app/build/miner/data

# Change to the miner directory so the blockchain.db is created there
cd /usr/src/app/build/miner/data

# Run the miner application and redirect output to miner.out
echo "Starting miner application..."
node /usr/src/app/build/miner/miner-app.js > /usr/src/app/build/miner/data/miner.out 2>&1

# Optionally, you can output the result to stdout as well
echo "Miner app has finished. Check miner.out for details."