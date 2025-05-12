#!/bin/sh
set -e  # Exit on error

echo "=== Loaded settings.json ==="
cat /usr/src/app/settings.json
echo "============================"

# Ensure output directory exists
mkdir -p /usr/src/app/build/wallet/data

# Change to the wallet directory so the blockchain.db is created there
cd /usr/src/app/build/wallet/data


# Run the wallet application and redirect output to wallet.out
echo "Starting wallet application..."
node /usr/src/app/build/wallet/wallet-app.js > /usr/src/app/build/wallet/data/wallet.out 2>&1

# Optionally, you can output the result to stdout as well
echo "Wallet app has finished. Check wallet.out for details."
