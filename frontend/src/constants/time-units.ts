export const TIME_UNITS = {
  SECOND: 1,
  MINUTE: 60,
  HOUR: 3600,
  DAY: 86400,
  WEEK: 604800,
  MONTH: 2592000,
  YEAR: 31536000,
} as const

export function secondsToDays(seconds: number): number {
  return Math.floor(seconds / TIME_UNITS.DAY)
}

export function daysToSeconds(days: number): number {
  return days * TIME_UNITS.DAY
}
