export type Theme = 'light' | 'dark' | 'system'

export function getSystemTheme(): 'light' | 'dark' {
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}

export function applyTheme(theme: Theme): void {
  const resolvedTheme = theme === 'system' ? getSystemTheme() : theme
  document.documentElement.setAttribute('data-theme', resolvedTheme)
}

export function getStoredTheme(): Theme {
  return (localStorage.getItem('theme') as Theme) || 'system'
}

export function saveTheme(theme: Theme): void {
  localStorage.setItem('theme', theme)
  applyTheme(theme)
}
