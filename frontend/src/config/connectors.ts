import { injected, walletConnect, coinbaseWallet } from 'wagmi/connectors'

export const connectors = [
  injected({
    target: 'metaMask',
  }),
  walletConnect({
    projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || '',
    showQrModal: true,
  }),
  coinbaseWallet({
    appName: 'BlueSavings',
    appLogoUrl: 'https://bluesavings.app/logo.png',
  }),
]

export const walletConfig = {
  metaMask: {
    name: 'MetaMask',
    icon: '/icons/metamask.svg',
  },
  walletConnect: {
    name: 'WalletConnect',
    icon: '/icons/walletconnect.svg',
  },
  coinbase: {
    name: 'Coinbase Wallet',
    icon: '/icons/coinbase.svg',
  },
}
