export interface WalletState {
  address?: string
  isConnected: boolean
  isConnecting: boolean
  chainId?: number
}

export interface ChainInfo {
  id: number
  name: string
  nativeCurrency: {
    name: string
    symbol: string
    decimals: number
  }
  rpcUrls: string[]
  blockExplorers: {
    name: string
    url: string
  }[]
}
