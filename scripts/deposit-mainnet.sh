#!/bin/bash
# Script to deposit to a vault on Base mainnet

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Depositing to vault on Base mainnet...${NC}"

if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

source .env

VAULT_ADDRESS=${VAULT_ADDRESS:-"0xf185cec4B72385CeaDE58507896E81F05E8b6c6a"}

if [ -z "$VAULT_ID" ]; then
    echo "Error: VAULT_ID not set"
    exit 1
fi

if [ -z "$DEPOSIT_AMOUNT" ]; then
    echo "Error: DEPOSIT_AMOUNT not set"
    exit 1
fi

echo "Contract: $VAULT_ADDRESS"
echo "Vault ID: $VAULT_ID"
echo "Amount: $DEPOSIT_AMOUNT wei"

forge script script/Interact.s.sol:DepositScript \
  --rpc-url base \
  --broadcast \
  -vvv

echo -e "${GREEN}Deposit transaction submitted!${NC}"
