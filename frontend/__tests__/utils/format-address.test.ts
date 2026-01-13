import { formatAddress } from '@/utils/format-address'

describe('formatAddress', () => {
  it('should format address correctly', () => {
    const address = '0x1234567890123456789012345678901234567890'
    expect(formatAddress(address)).toBe('0x1234...7890')
  })

  it('should return empty string for invalid address', () => {
    expect(formatAddress('')).toBe('')
  })
})
