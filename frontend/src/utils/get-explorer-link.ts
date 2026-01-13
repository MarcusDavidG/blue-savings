export function getExplorerLink(chainId: number, data: string, type: 'tx' | 'address' | 'token'): string {
  const baseUrl = chainId === 8453 
    ? 'https://basescan.org'
    : 'https://sepolia.basescan.org'
  
  return `${baseUrl}/${type}/${data}`
}
