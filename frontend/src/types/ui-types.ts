export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger'
export type ButtonSize = 'small' | 'medium' | 'large'

export interface ToastOptions {
  type: 'success' | 'error' | 'info' | 'warning'
  message: string
  duration?: number
}
