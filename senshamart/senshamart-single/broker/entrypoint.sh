#!/bin/sh
set -e  # Exit on error

# Provide safe defaults for all variables if unset
: "${BROKER_PEERS:=[]}"
: "${WALLET_PEERS:=[]}"
: "${MINER_PEERS:=[]}"
: "${BROKER_NAME:=""}"
: "${BROKER_KEYPAIR:=""}"
: "${MINER_PUBLIC_KEY:=""}"
: "${FUSEKI_URL:=""}"
: "${MINER_KEYPAIR:=""}"
: "${WALLET_KEYPAIR:=""}"

# Ensure peer variables are valid JSON arrays
wallet_peers_list=$(echo "$WALLET_PEERS" | jq -c .)
broker_peers_list=$(echo "$BROKER_PEERS" | jq -c .)
miner_peers_list=$(echo "$MINER_PEERS" | jq -c .)

# Export corrected values
export WALLET_PEERS=$wallet_peers_list
export BROKER_PEERS=$broker_peers_list
export MINER_PEERS=$miner_peers_list

# Generate settings.json using envsubst
envsubst < /usr/src/app/settings.template.json > /usr/src/app/settings.json

# Optional: Show final config for debugging
cat /usr/src/app/settings.json

# Log the command
echo "Starting: $@" >> /usr/src/app/data/broker.out

# Execute or keep container alive
if [ -z "$1" ]; then
    echo "No command provided, keeping container alive..." >> /usr/src/app/data/broker.out
    tail -f /dev/null
else
    echo "Executing: $@" >> /usr/src/app/data/broker.out
    exec "$@" 2>&1 | tee -a /usr/src/app/data/broker.out
fi
