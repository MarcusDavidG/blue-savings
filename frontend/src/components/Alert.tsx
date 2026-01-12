interface AlertProps {
  children?: React.ReactNode;
}

export function Alert({ children }: AlertProps) {
  return <div className="alert">{children}</div>
}
