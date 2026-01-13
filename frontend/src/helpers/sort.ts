export function sortByDate<T>(array: T[], key: keyof T, order: 'asc' | 'desc' = 'desc'): T[] {
  return [...array].sort((a, b) => {
    const aVal = Number(a[key])
    const bVal = Number(b[key])
    return order === 'asc' ? aVal - bVal : bVal - aVal
  })
}

export function sortByString<T>(array: T[], key: keyof T, order: 'asc' | 'desc' = 'asc'): T[] {
  return [...array].sort((a, b) => {
    const aVal = String(a[key])
    const bVal = String(b[key])
    return order === 'asc' ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal)
  })
}
