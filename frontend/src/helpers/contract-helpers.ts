import { CONTRACT_ADDRESSES } from '@/constants/contract-addresses'

export function getContractAddress(chainId: number): string {
  return CONTRACT_ADDRESSES[chainId as keyof typeof CONTRACT_ADDRESSES] || CONTRACT_ADDRESSES[8453]
}

export function isContractDeployed(chainId: number): boolean {
  return chainId in CONTRACT_ADDRESSES
}
