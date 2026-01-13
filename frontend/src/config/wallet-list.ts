export const walletList = {
  groupName: 'Recommended',
  wallets: [
    {
      id: 'metaMask',
      name: 'MetaMask',
      iconUrl: '/icons/metamask.svg',
      downloadUrls: {
        chrome: 'https://chrome.google.com/webstore/detail/metamask',
        firefox: 'https://addons.mozilla.org/firefox/addon/ether-metamask/',
        browserExtension: 'https://metamask.io/download/',
      },
    },
    {
      id: 'walletConnect',
      name: 'WalletConnect',
      iconUrl: '/icons/walletconnect.svg',
      downloadUrls: {
        android: 'https://play.google.com/store/apps/details?id=com.walletconnect',
        ios: 'https://apps.apple.com/app/walletconnect',
        mobile: 'https://walletconnect.com/',
      },
    },
    {
      id: 'coinbase',
      name: 'Coinbase Wallet',
      iconUrl: '/icons/coinbase.svg',
      downloadUrls: {
        chrome: 'https://chrome.google.com/webstore/detail/coinbase-wallet',
        android: 'https://play.google.com/store/apps/details?id=org.toshi',
        ios: 'https://apps.apple.com/app/coinbase-wallet/id1278383455',
        mobile: 'https://www.coinbase.com/wallet',
      },
    },
  ],
}

export const walletGroups = {
  recommended: ['metaMask', 'walletConnect', 'coinbase'],
  popular: ['metaMask', 'walletConnect'],
  mobile: ['walletConnect', 'coinbase'],
}
