# Performance Guide

## Benchmarks

- Contract deployment: ~1.2M gas
- Create vault: ~170k gas
- Deposit: ~67k gas
- Withdraw: ~32k gas

## Optimization Tips

1. Cache storage variables
2. Use unchecked for safe math
3. Minimize SLOAD operations
4. Batch operations when possible

## Gas Costs Comparison

| Function | Before | After | Savings |
|----------|--------|-------|---------|
| deposit | 67.3k | 66.9k | 400 gas |
| withdraw | 32.7k | 32.6k | 100 gas |
