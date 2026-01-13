export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

export async function waitFor(condition: () => boolean, timeout = 5000, interval = 100): Promise<boolean> {
  const startTime = Date.now()
  
  while (Date.now() - startTime < timeout) {
    if (condition()) return true
    await sleep(interval)
  }
  
  return false
}
