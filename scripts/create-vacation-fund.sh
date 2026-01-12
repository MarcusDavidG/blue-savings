#!/bin/bash
# Create vacation savings vault (1 year lock, 2 ETH goal)

export METADATA="Summer Vacation 2027"
export GOAL_AMOUNT=2000000000000000000
export UNLOCK_TIMESTAMP=$(($(date +%s) + 31536000))

echo "Creating Vacation Fund vault..."
echo "Unlock date: $(date -d @$UNLOCK_TIMESTAMP)"

./scripts/create-vault-mainnet.sh
