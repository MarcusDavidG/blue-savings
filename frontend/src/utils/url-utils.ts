export function buildQueryString(params: Record<string, string | number>): string {
  const query = new URLSearchParams()
  Object.entries(params).forEach(([key, value]) => {
    query.append(key, String(value))
  })
  return query.toString()
}

export function parseQueryString(search: string): Record<string, string> {
  const params = new URLSearchParams(search)
  const result: Record<string, string> = {}
  params.forEach((value, key) => {
    result[key] = value
  })
  return result
}
