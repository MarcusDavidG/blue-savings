export function calculatePercentage(value: number, total: number): number {
  if (total === 0) return 0
  return (value / total) * 100
}

export function applyPercentage(value: number, percentage: number): number {
  return value * (percentage / 100)
}
