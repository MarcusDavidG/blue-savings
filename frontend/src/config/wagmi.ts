import { http, createConfig } from 'wagmi'
import { supportedChains } from './chains'
import { connectors } from './connectors'

export const config = createConfig({
  chains: supportedChains,
  connectors,
  transports: {
    [supportedChains[0].id]: http(),
    [supportedChains[1].id]: http(),
  },
})

export { supportedChains, connectors }
