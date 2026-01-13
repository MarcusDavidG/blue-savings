'use client'

import { useAccount, useBalance, useDisconnect } from 'wagmi'
import { formatEther } from 'viem'

export function AccountMenu() {
  const { address, isConnected } = useAccount()
  const { disconnect } = useDisconnect()
  const { data: balance } = useBalance({
    address,
  })

  if (!isConnected || !address) {
    return null
  }

  return (
    <div className="account-menu">
      <div className="account-info">
        <span className="address">
          {address.slice(0, 6)}...{address.slice(-4)}
        </span>
        {balance && (
          <span className="balance">
            {parseFloat(formatEther(balance.value)).toFixed(4)} {balance.symbol}
          </span>
        )}
      </div>
      <button onClick={() => disconnect()} className="disconnect-button">
        Disconnect
      </button>
    </div>
  )
}
