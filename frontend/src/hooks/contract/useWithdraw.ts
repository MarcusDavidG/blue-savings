import { useContractWrite, usePrepareContractWrite } from 'wagmi'
import { CONTRACT_ADDRESSES } from '@/constants/contract-addresses'
import SavingsVaultABI from '@/abi/SavingsVault.json'

export function useWithdraw(vaultId: bigint) {
  const { config } = usePrepareContractWrite({
    address: CONTRACT_ADDRESSES[8453],
    abi: SavingsVaultABI,
    functionName: 'withdraw',
    args: [vaultId],
  })

  const { write, data, isLoading, isSuccess } = useContractWrite(config)

  return {
    withdraw: write,
    data,
    isLoading,
    isSuccess,
  }
}
