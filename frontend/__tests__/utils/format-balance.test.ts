import { formatBalance } from '@/utils/format-balance'

describe('formatBalance', () => {
  it('should format balance correctly', () => {
    const balance = 1000000000000000000n // 1 ETH
    expect(formatBalance(balance)).toBe('1.0000')
  })

  it('should handle custom decimals', () => {
    const balance = 1000000000000000000n
    expect(formatBalance(balance, 18, 2)).toBe('1.00')
  })
})
