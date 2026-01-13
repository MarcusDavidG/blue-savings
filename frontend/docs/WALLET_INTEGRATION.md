# Wallet Integration Guide

## Overview

BlueSavings uses wagmi and RainbowKit for wallet connectivity.

## Supported Wallets

- MetaMask
- WalletConnect
- Coinbase Wallet

## Usage

```tsx
import { WalletButton } from '@/components/wallet/WalletButton'

function App() {
  return <WalletButton />
}
```

## Hooks

- `useWallet()` - Access wallet state
- `useBalance()` - Get wallet balance
- `useNetwork()` - Get current network
