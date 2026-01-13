import { isAddress } from 'viem'

export function isValidAddress(address: string): boolean {
  return isAddress(address)
}
