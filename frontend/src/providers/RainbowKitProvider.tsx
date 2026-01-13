'use client'

import '@rainbow-me/rainbowkit/styles.css'
import { RainbowKitProvider as RainbowProvider } from '@rainbow-me/rainbowkit'
import { WagmiProvider } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { config } from '@/config'
import { ReactNode } from 'react'

const queryClient = new QueryClient()

interface Props {
  children: ReactNode
}

export function RainbowKitProvider({ children }: Props) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowProvider>
          {children}
        </RainbowProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}
