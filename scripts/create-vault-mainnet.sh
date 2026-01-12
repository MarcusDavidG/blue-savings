#!/bin/bash
# Script to create a vault on Base mainnet

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Creating vault on Base mainnet...${NC}"

# Check if .env exists
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Source environment variables
source .env

# Default values if not set
VAULT_ADDRESS=${VAULT_ADDRESS:-"0xf185cec4B72385CeaDE58507896E81F05E8b6c6a"}
GOAL_AMOUNT=${GOAL_AMOUNT:-0}
UNLOCK_TIMESTAMP=${UNLOCK_TIMESTAMP:-0}
METADATA=${METADATA:-"My Savings Vault"}

echo "Contract: $VAULT_ADDRESS"
echo "Goal Amount: $GOAL_AMOUNT"
echo "Unlock Time: $UNLOCK_TIMESTAMP"
echo "Metadata: $METADATA"

# Run the forge script
forge script script/Interact.s.sol:CreateVaultScript \
  --rpc-url base \
  --broadcast \
  --verify \
  -vvv

echo -e "${GREEN}Vault creation transaction submitted!${NC}"
echo "Check transaction on BaseScan: https://basescan.org/address/$VAULT_ADDRESS"
