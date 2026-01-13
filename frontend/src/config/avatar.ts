export const avatarConfig = {
  size: {
    small: 24,
    medium: 40,
    large: 64,
  },
  borderRadius: '50%',
  border: '2px solid #ffffff',
  boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)',
}

export const defaultAvatar = {
  background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  color: '#ffffff',
  fontSize: '16px',
  fontWeight: '600',
}

export const ensAvatarConfig = {
  enabled: true,
  fallback: 'identicon',
  cache: true,
  cacheTime: 1000 * 60 * 60 * 24, // 24 hours
}

export const addressDisplayConfig = {
  format: 'short', // '0x1234...5678'
  length: {
    prefix: 6,
    suffix: 4,
  },
  showCopyButton: true,
  copyText: 'Copy address',
  copiedText: 'Copied!',
}
