'use client'

import { useNetwork, useSwitchNetwork } from 'wagmi'
import { base, baseSepolia } from 'wagmi/chains'

export function NetworkSwitch() {
  const { chain } = useNetwork()
  const { switchNetwork } = useSwitchNetwork()

  return (
    <div className="network-switch">
      <div className="current-network">
        Current: {chain?.name || 'Unknown'}
      </div>
      <div className="network-buttons">
        <button
          onClick={() => switchNetwork?.(base.id)}
          disabled={chain?.id === base.id}
          className="network-button"
        >
          Base Mainnet
        </button>
        <button
          onClick={() => switchNetwork?.(baseSepolia.id)}
          disabled={chain?.id === baseSepolia.id}
          className="network-button"
        >
          Base Sepolia
        </button>
      </div>
    </div>
  )
}
