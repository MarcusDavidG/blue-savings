export const NETWORK_NAMES = {
  8453: 'Base Mainnet',
  84532: 'Base Sepolia',
  1: 'Ethereum Mainnet',
  11155111: 'Sepolia',
} as const

export function getNetworkName(chainId: number): string {
  return NETWORK_NAMES[chainId as keyof typeof NETWORK_NAMES] || 'Unknown Network'
}
