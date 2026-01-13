import type { Metadata } from 'next'
import './globals.css'
import { Web3Provider } from '@/providers/Web3Provider'

export const metadata: Metadata = {
  title: 'BlueSavings - Decentralized Savings Vaults',
  description: 'Create time-locked and goal-based savings vaults on Base blockchain',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body style={{ minHeight: '100vh', background: '#f9fafb' }}>
        <Web3Provider>
          <main>{children}</main>
        </Web3Provider>
      </body>
    </html>
  )
}
