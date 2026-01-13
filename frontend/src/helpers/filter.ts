export function filterByStatus<T extends { status: string }>(array: T[], status: string): T[] {
  return array.filter(item => item.status === status)
}

export function filterBySearch<T>(array: T[], searchTerm: string, keys: (keyof T)[]): T[] {
  const term = searchTerm.toLowerCase()
  return array.filter(item =>
    keys.some(key => String(item[key]).toLowerCase().includes(term))
  )
}
