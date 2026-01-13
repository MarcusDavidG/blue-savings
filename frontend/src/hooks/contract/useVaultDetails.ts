import { useContractRead } from 'wagmi'
import { CONTRACT_ADDRESSES } from '@/constants/contract-addresses'
import SavingsVaultABI from '@/abi/SavingsVault.json'

export function useVaultDetails(vaultId: bigint) {
  const { data, isError, isLoading } = useContractRead({
    address: CONTRACT_ADDRESSES[8453],
    abi: SavingsVaultABI,
    functionName: 'getVaultDetails',
    args: [vaultId],
  })

  return {
    vaultDetails: data,
    isError,
    isLoading,
  }
}
