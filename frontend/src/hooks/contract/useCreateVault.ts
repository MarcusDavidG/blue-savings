import { useContractWrite, usePrepareContractWrite } from 'wagmi'
import { CONTRACT_ADDRESSES } from '@/constants/contract-addresses'
import SavingsVaultABI from '@/abi/SavingsVault.json'

export function useCreateVault() {
  const { config } = usePrepareContractWrite({
    address: CONTRACT_ADDRESSES[8453],
    abi: SavingsVaultABI,
    functionName: 'createVault',
  })

  const { write, data, isLoading, isSuccess } = useContractWrite(config)

  return {
    createVault: write,
    data,
    isLoading,
    isSuccess,
  }
}
