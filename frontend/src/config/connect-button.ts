export const connectButtonConfig = {
  accountStatus: {
    smallScreen: 'avatar',
    largeScreen: 'full',
  },
  showBalance: {
    smallScreen: false,
    largeScreen: true,
  },
  chainStatus: {
    smallScreen: 'icon',
    largeScreen: 'full',
  },
  label: 'Connect Wallet',
}

export const buttonStyles = {
  default: {
    background: '#0052FF',
    color: '#ffffff',
    borderRadius: '12px',
    padding: '12px 24px',
    fontSize: '16px',
    fontWeight: '600',
  },
  hover: {
    background: '#0046DD',
  },
  active: {
    background: '#003DBB',
  },
}

export const avatarConfig = {
  size: 40,
  showEns: true,
  showAddress: true,
  truncateAddress: true,
  addressFormat: 'short', // '0x1234...5678'
}
