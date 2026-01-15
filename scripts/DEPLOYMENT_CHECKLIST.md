# Deployment Checklist

## Pre-Deployment

- [ ] All tests pass (`forge test`)
- [ ] No compiler warnings (`forge build`)
- [ ] Code formatted (`forge fmt --check`)
- [ ] Gas report reviewed (`forge test --gas-report`)
- [ ] Constructor arguments documented
- [ ] Environment variables set in `.env`
- [ ] Deployer wallet has sufficient ETH for gas

## Environment Setup

```bash
# Required environment variables
export PRIVATE_KEY=<deployer_private_key>
export BASESCAN_API_KEY=<api_key>
```

## Testnet Deployment (Base Sepolia)

- [ ] Deploy to testnet first
- [ ] Verify contract on testnet explorer
- [ ] Test all functions manually
- [ ] Verify events emit correctly
- [ ] Test edge cases

## Mainnet Deployment

- [ ] Double-check constructor arguments
- [ ] Confirm fee parameters
- [ ] Verify owner address is correct
- [ ] Run deployment script with `--broadcast`
- [ ] Save transaction hash
- [ ] Wait for confirmations (12+ blocks)

## Post-Deployment

- [ ] Verify contract on BaseScan
- [ ] Test read functions on explorer
- [ ] Test write function with small amount
- [ ] Update README with contract address
- [ ] Update `.env` with deployed addresses
- [ ] Announce deployment

## Verification Command

```bash
forge verify-contract <ADDRESS> <CONTRACT> \
  --chain base \
  --constructor-args $(cast abi-encode "constructor(args)")
```

## Emergency Procedures

- [ ] Document emergency pause procedure
- [ ] Verify owner can call emergency functions
- [ ] Document upgrade procedure (if applicable)
