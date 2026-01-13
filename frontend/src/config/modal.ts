export const modalConfig = {
  appName: 'BlueSavings',
  appDescription: 'Decentralized Savings Vaults on Base',
  appUrl: 'https://bluesavings.app',
  appIcon: '/logo.png',
  disclaimer: {
    text: 'By connecting your wallet, you agree to the Terms of Service and Privacy Policy.',
    link: '/terms',
  },
}

export const modalStyles = {
  width: '400px',
  maxWidth: '90vw',
  borderRadius: '16px',
  padding: '24px',
  boxShadow: '0px 8px 32px rgba(0, 0, 0, 0.1)',
}

export const modalOptions = {
  closeButton: true,
  closeOnEscape: true,
  closeOnBackdropClick: true,
  showRecent: true,
  showBalance: true,
  disclaimer: true,
}

export const modalText = {
  title: 'Connect your wallet',
  subtitle: 'Choose your preferred wallet to connect',
  connecting: 'Connecting...',
  connected: 'Connected',
  error: 'Connection failed',
  retry: 'Try again',
  disconnect: 'Disconnect',
  switchNetwork: 'Switch Network',
  wrongNetwork: 'Wrong network. Please switch to Base.',
}
