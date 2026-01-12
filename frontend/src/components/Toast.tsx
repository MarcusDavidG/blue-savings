interface ToastProps {
  children?: React.ReactNode;
}

export function Toast({ children }: ToastProps) {
  return <div className="toast">{children}</div>
}
