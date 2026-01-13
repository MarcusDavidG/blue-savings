import { validateAmount, validateUnlockTime, validateMetadata } from '@/helpers/validation'

describe('validation utilities', () => {
  describe('validateAmount', () => {
    it('should validate positive amounts', () => {
      expect(validateAmount('1.5')).toBe(true)
      expect(validateAmount('0')).toBe(false)
      expect(validateAmount('-1')).toBe(false)
    })
  })

  describe('validateUnlockTime', () => {
    it('should validate future timestamps', () => {
      const future = Math.floor(Date.now() / 1000) + 86400
      const past = Math.floor(Date.now() / 1000) - 86400
      expect(validateUnlockTime(future)).toBe(true)
      expect(validateUnlockTime(past)).toBe(false)
    })
  })

  describe('validateMetadata', () => {
    it('should validate JSON metadata', () => {
      expect(validateMetadata('{"name":"Test"}')).toBe(true)
      expect(validateMetadata('invalid')).toBe(false)
    })
  })
})
