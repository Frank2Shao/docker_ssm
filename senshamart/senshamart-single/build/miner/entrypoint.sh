#!/bin/sh
set -e  # Stop on error

# Ensure all expected vars are initialized with safe defaults if unset
: "${WALLET_PEERS:=[]}"
: "${BROKER_PEERS:=[]}"
: "${MINER_PEERS:=[]}"
: "${MINER_KEYPAIR:=""}"
: "${MINER_PUBLIC_KEY:=""}"
: "${FUSEKI_URL:=""}"
: "${BROKER_NAME:=""}"
: "${BROKER_KEYPAIR:=""}"

# Ensure the peers are valid JSON arrays
# These will error if not valid JSON, which is good during debugging
wallet_peers_list=$(echo "$WALLET_PEERS" | jq -c .)
broker_peers_list=$(echo "$BROKER_PEERS" | jq -c .)
miner_peers_list=$(echo "$MINER_PEERS" | jq -c .)

# Export corrected values for envsubst
export WALLET_PEERS=$wallet_peers_list
export BROKER_PEERS=$broker_peers_list
export MINER_PEERS=$miner_peers_list

# Substitute variables into settings.json
envsubst < /usr/src/app/settings.template.json > /usr/src/app/settings.json

# Optional: Display the resulting settings.json for debugging
cat /usr/src/app/settings.json

# Log the command that's about to be executed
echo "Starting: $@" >> /usr/src/app/data/miner.out

# Execute the main command passed to the script and redirect output to miner.out
if [ -z "$1" ]; then
    echo "No command provided, keeping container alive..." >> /usr/src/app/data/miner.out
    tail -f /dev/null
else
    echo "Executing: $@" >> /usr/src/app/data/miner.out
    # Execute the command and pipe its output both to the console and to miner.out
    exec "$@" 2>&1 | tee -a /usr/src/app/data/miner.out
fi
