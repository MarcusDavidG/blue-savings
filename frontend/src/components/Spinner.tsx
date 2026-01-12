interface SpinnerProps {
  children?: React.ReactNode;
}

export function Spinner({ children }: SpinnerProps) {
  return <div className="spinner">{children}</div>
}
