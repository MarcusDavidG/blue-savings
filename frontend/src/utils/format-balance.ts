import { formatEther, formatUnits } from 'viem'

export function formatBalance(value: bigint, decimals = 18, displayDecimals = 4): string {
  const formatted = decimals === 18 
    ? formatEther(value)
    : formatUnits(value, decimals)
  return parseFloat(formatted).toFixed(displayDecimals)
}
