export const STATUS_COLORS = {
  active: 'bg-green-100 text-green-800',
  pending: 'bg-yellow-100 text-yellow-800',
  locked: 'bg-blue-100 text-blue-800',
  completed: 'bg-gray-100 text-gray-800',
  failed: 'bg-red-100 text-red-800',
} as const

export type StatusType = keyof typeof STATUS_COLORS
