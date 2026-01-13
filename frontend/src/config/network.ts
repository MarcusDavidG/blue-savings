import { base, baseSepolia } from 'viem/chains'

export const isMainnet = (chainId: number) => chainId === base.id
export const isTestnet = (chainId: number) => chainId === baseSepolia.id

export const isSupportedChain = (chainId: number) => {
  return chainId === base.id || chainId === baseSepolia.id
}

export const getChainName = (chainId: number) => {
  switch (chainId) {
    case base.id:
      return 'Base Mainnet'
    case baseSepolia.id:
      return 'Base Sepolia'
    default:
      return 'Unknown Network'
  }
}

export const getExplorerUrl = (chainId: number) => {
  switch (chainId) {
    case base.id:
      return 'https://basescan.org'
    case baseSepolia.id:
      return 'https://sepolia.basescan.org'
    default:
      return 'https://basescan.org'
  }
}

export const getExplorerAddressUrl = (chainId: number, address: string) => {
  return `${getExplorerUrl(chainId)}/address/${address}`
}

export const getExplorerTxUrl = (chainId: number, txHash: string) => {
  return `${getExplorerUrl(chainId)}/tx/${txHash}`
}
