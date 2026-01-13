import { base, baseSepolia } from 'viem/chains'

export const chainIcons = {
  [base.id]: {
    url: '/icons/base.svg',
    width: 24,
    height: 24,
    alt: 'Base',
  },
  [baseSepolia.id]: {
    url: '/icons/base-sepolia.svg',
    width: 24,
    height: 24,
    alt: 'Base Sepolia',
  },
}

export const getChainIcon = (chainId: number) => {
  return chainIcons[chainId as keyof typeof chainIcons] || chainIcons[base.id]
}

export const chainColors = {
  [base.id]: '#0052FF',
  [baseSepolia.id]: '#FF4444',
}

export const getChainColor = (chainId: number) => {
  return chainColors[chainId as keyof typeof chainColors] || '#0052FF'
}
