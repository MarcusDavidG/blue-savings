'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'
import { modalText } from '@/config/modal'

export function ConnectModal() {
  return (
    <ConnectButton.Custom>
      {({
        account,
        chain,
        openAccountModal,
        openChainModal,
        openConnectModal,
        mounted,
      }) => {
        const ready = mounted
        const connected = ready && account && chain

        return (
          <div
            {...(!ready && {
              'aria-hidden': true,
              style: {
                opacity: 0,
                pointerEvents: 'none',
                userSelect: 'none',
              },
            })}
          >
            {(() => {
              if (!connected) {
                return (
                  <button
                    onClick={openConnectModal}
                    type="button"
                    className="connect-button"
                  >
                    {modalText.title}
                  </button>
                )
              }

              if (chain.unsupported) {
                return (
                  <button onClick={openChainModal} type="button" className="error-button">
                    {modalText.wrongNetwork}
                  </button>
                )
              }

              return (
                <div className="connected-container">
                  <button
                    onClick={openChainModal}
                    type="button"
                    className="chain-button"
                  >
                    {chain.hasIcon && chain.iconUrl && (
                      <img
                        alt={chain.name ?? 'Chain icon'}
                        src={chain.iconUrl}
                        style={{ width: 24, height: 24 }}
                      />
                    )}
                    {chain.name}
                  </button>

                  <button onClick={openAccountModal} type="button" className="account-button">
                    {account.displayName}
                    {account.displayBalance ? ` (${account.displayBalance})` : ''}
                  </button>
                </div>
              )
            })()}
          </div>
        )
      }}
    </ConnectButton.Custom>
  )
}
