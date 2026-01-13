import { webSocket } from 'viem'
import { base, baseSepolia } from 'viem/chains'

export const wsTransports = {
  [base.id]: webSocket('wss://mainnet.base.org'),
  [baseSepolia.id]: webSocket('wss://sepolia.base.org'),
}

export const getWebSocketTransport = (chainId: number) => {
  return wsTransports[chainId as keyof typeof wsTransports]
}

export const wsConfig = {
  reconnect: true,
  retryCount: 5,
  retryDelay: 1000,
}
