export const FEE_CONFIG = {
  PROTOCOL_FEE_BPS: 50, // 0.5%
  MAX_FEE_BPS: 200, // 2%
  BASIS_POINTS: 10000,
} as const

export function calculateFee(amount: bigint): bigint {
  return (amount * BigInt(FEE_CONFIG.PROTOCOL_FEE_BPS)) / BigInt(FEE_CONFIG.BASIS_POINTS)
}
