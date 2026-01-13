import type { Metadata } from 'next'
import './globals.css'

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
        <main>{children}</main>
      </body>
    </html>
  )
}
