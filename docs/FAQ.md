# Frequently Asked Questions

## General

### What is BlueSavings?
BlueSavings is a decentralized savings vault protocol on Base that helps users save ETH with optional time locks and goals.

### Is it safe?
Yes, the contract is verified on BaseScan and follows security best practices. Always verify the contract address.

### What are the fees?
0.5% protocol fee on deposits. No fees on withdrawals.

## Using BlueSavings

### How do I create a vault?
Use the `createVault` function with your desired parameters (goal amount, unlock time, metadata).

### Can I withdraw early?
Yes, if you use `emergencyWithdraw`, but note the purpose is disciplined saving.

### What happens if I don't reach my goal?
You can still withdraw after the unlock time, regardless of goal progress.

## Technical

### Which networks are supported?
Currently Base mainnet and Base Sepolia testnet.

### Can I save ERC-20 tokens?
Not yet, but ERC-20 support is planned for v2.0.

### Is the contract upgradeable?
No, it's immutable for security. New versions will be separate deployments.

## Troubleshooting

### Transaction failed
Check that you have enough ETH for gas and that vault conditions are met.

### Can't withdraw
Verify the unlock time has passed and goal is reached (if set).

### Contract not found
Ensure you're on the correct network (Base mainnet or Sepolia).
