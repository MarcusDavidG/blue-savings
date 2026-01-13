'use client'

import { useBalance, useAccount } from 'wagmi'
import { formatEther } from 'viem'

interface Props {
  showSymbol?: boolean
  decimals?: number
}

export function BalanceDisplay({ showSymbol = true, decimals = 4 }: Props) {
  const { address } = useAccount()
  const { data: balance, isLoading } = useBalance({ address })

  if (isLoading) return <span>Loading...</span>
  if (!balance) return <span>-</span>

  const formatted = parseFloat(formatEther(balance.value)).toFixed(decimals)

  return (
    <span className="balance-display">
      {formatted} {showSymbol && balance.symbol}
    </span>
  )
}
