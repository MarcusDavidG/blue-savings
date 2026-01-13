'use client'

import { useAccount } from 'wagmi'
import { useState } from 'react'

interface Props {
  address?: string
  showCopy?: boolean
}

export function AddressDisplay({ address: propAddress, showCopy = true }: Props) {
  const { address: accountAddress } = useAccount()
  const address = propAddress || accountAddress
  const [copied, setCopied] = useState(false)

  if (!address) return null

  const shortAddress = `${address.slice(0, 6)}...${address.slice(-4)}`

  const handleCopy = async () => {
    await navigator.clipboard.writeText(address)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="address-display">
      <span className="address">{shortAddress}</span>
      {showCopy && (
        <button onClick={handleCopy} className="copy-button">
          {copied ? 'Copied!' : 'Copy'}
        </button>
      )}
    </div>
  )
}
