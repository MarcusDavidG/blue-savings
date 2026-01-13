export const autoConnectConfig = {
  enabled: true,
  retryOnMount: true,
  pollingInterval: 5000,
}

export const connectionConfig = {
  shimDisconnect: true,
  reconnect: {
    enabled: true,
    maxRetries: 3,
    retryDelay: 1000,
  },
}

export const cacheConfig = {
  enabled: true,
  cacheTime: 1000 * 60 * 60 * 24, // 24 hours
  storage: typeof window !== 'undefined' ? window.localStorage : undefined,
}
