export const ROUTE_PATHS = {
  HOME: '/',
  DASHBOARD: '/dashboard',
  VAULTS: '/vaults',
  VAULT_DETAILS: (id: string) => `/vault/${id}`,
  CREATE_VAULT: '/create',
  ANALYTICS: '/analytics',
  SETTINGS: '/settings',
  PROFILE: '/profile',
} as const
