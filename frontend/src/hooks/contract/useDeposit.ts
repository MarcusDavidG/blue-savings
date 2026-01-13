import { useContractWrite, usePrepareContractWrite } from 'wagmi'
import { CONTRACT_ADDRESSES } from '@/constants/contract-addresses'
import SavingsVaultABI from '@/abi/SavingsVault.json'

export function useDeposit(vaultId: bigint, amount: bigint) {
  const { config } = usePrepareContractWrite({
    address: CONTRACT_ADDRESSES[8453],
    abi: SavingsVaultABI,
    functionName: 'deposit',
    args: [vaultId],
    value: amount,
  })

  const { write, data, isLoading, isSuccess } = useContractWrite(config)

  return {
    deposit: write,
    data,
    isLoading,
    isSuccess,
  }
}
