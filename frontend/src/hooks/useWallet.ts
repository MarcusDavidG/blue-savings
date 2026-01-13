import { useAccount, useConnect, useDisconnect, useNetwork } from 'wagmi'

export function useWallet() {
  const { address, isConnected, isConnecting } = useAccount()
  const { connect, connectors } = useConnect()
  const { disconnect } = useDisconnect()
  const { chain } = useNetwork()

  return {
    address,
    isConnected,
    isConnecting,
    chain,
    connect,
    disconnect,
    connectors,
  }
}
