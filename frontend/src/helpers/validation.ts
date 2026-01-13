export function validateAmount(amount: string): boolean {
  const num = parseFloat(amount)
  return !isNaN(num) && num > 0
}

export function validateUnlockTime(timestamp: number): boolean {
  const now = Math.floor(Date.now() / 1000)
  return timestamp > now
}

export function validateMetadata(metadata: string): boolean {
  try {
    JSON.parse(metadata)
    return true
  } catch {
    return false
  }
}
