#!/bin/bash
# Script to check vault details on Base mainnet

set -e

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

echo "Checking vault $VAULT_ID on $VAULT_ADDRESS..."

forge script script/Interact.s.sol:GetVaultDetailsScript \
  --rpc-url base \
  -vv
