#!/bin/bash
# Create emergency fund vault (6 month lock, 5 ETH goal)

export METADATA="Emergency Fund - 6 Months"
export GOAL_AMOUNT=5000000000000000000
export UNLOCK_TIMESTAMP=$(($(date +%s) + 15768000))

echo "Creating Emergency Fund vault..."
echo "Unlock date: $(date -d @$UNLOCK_TIMESTAMP)"

./scripts/create-vault-mainnet.sh
