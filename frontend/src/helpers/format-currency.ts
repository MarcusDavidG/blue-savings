export function formatCurrency(value: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(value)
}

export function formatETH(value: number, decimals = 4): string {
  return `${value.toFixed(decimals)} ETH`
}
