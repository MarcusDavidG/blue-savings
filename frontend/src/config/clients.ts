import { createPublicClient, http } from 'viem'
import { base, baseSepolia } from 'viem/chains'

export const basePublicClient = createPublicClient({
  chain: base,
  transport: http('https://mainnet.base.org'),
})

export const baseSepoliaPublicClient = createPublicClient({
  chain: baseSepolia,
  transport: http('https://sepolia.base.org'),
})

export const getPublicClient = (chainId: number) => {
  switch (chainId) {
    case base.id:
      return basePublicClient
    case baseSepolia.id:
      return baseSepoliaPublicClient
    default:
      return basePublicClient
  }
}
