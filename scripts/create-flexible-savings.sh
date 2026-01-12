#!/bin/bash
# Create flexible savings vault (no locks or goals)

export METADATA="Flexible Savings"
export GOAL_AMOUNT=0
export UNLOCK_TIMESTAMP=0

echo "Creating Flexible Savings vault..."
echo "No restrictions - withdraw anytime"

./scripts/create-vault-mainnet.sh
