import { parseEther, formatEther } from 'viem'

export function toBigInt(value: string): bigint {
  return parseEther(value)
}

export function fromBigInt(value: bigint): string {
  return formatEther(value)
}

export function addBigInts(a: bigint, b: bigint): bigint {
  return a + b
}

export function subtractBigInts(a: bigint, b: bigint): bigint {
  return a - b
}
