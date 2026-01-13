import { calculateProgress } from '@/utils/calculate-progress'

describe('calculateProgress', () => {
  it('should calculate progress correctly', () => {
    expect(calculateProgress(50n, 100n)).toBe(50)
  })

  it('should handle zero goal', () => {
    expect(calculateProgress(50n, 0n)).toBe(0)
  })

  it('should cap at 100%', () => {
    expect(calculateProgress(150n, 100n)).toBe(100)
  })
})
