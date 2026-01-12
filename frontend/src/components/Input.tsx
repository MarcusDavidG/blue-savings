interface InputProps {
  children?: React.ReactNode;
}

export function Input({ children }: InputProps) {
  return <div className="input">{children}</div>
}
