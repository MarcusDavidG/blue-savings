import { useState, useCallback } from 'react'
import { ToastOptions } from '@/types/ui-types'

export function useToast() {
  const [toasts, setToasts] = useState<ToastOptions[]>([])

  const showToast = useCallback((options: ToastOptions) => {
    const id = Date.now()
    setToasts(prev => [...prev, { ...options, id } as any])
    
    setTimeout(() => {
      setToasts(prev => prev.filter((t: any) => t.id !== id))
    }, options.duration || 3000)
  }, [])

  return {
    toasts,
    showToast,
    success: (message: string) => showToast({ type: 'success', message }),
    error: (message: string) => showToast({ type: 'error', message }),
    info: (message: string) => showToast({ type: 'info', message }),
    warning: (message: string) => showToast({ type: 'warning', message }),
  }
}
