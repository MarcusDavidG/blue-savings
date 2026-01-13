export function getTimeRemaining(unlockTime: bigint): number {
  const now = Math.floor(Date.now() / 1000)
  const remaining = Number(unlockTime) - now
  return Math.max(remaining, 0)
}

export function formatTimeRemaining(seconds: number): string {
  if (seconds === 0) return 'Unlocked'
  
  const days = Math.floor(seconds / 86400)
  const hours = Math.floor((seconds % 86400) / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  
  if (days > 0) return `${days}d ${hours}h`
  if (hours > 0) return `${hours}h ${minutes}m`
  return `${minutes}m`
}
