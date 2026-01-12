interface BadgeProps {
  children?: React.ReactNode;
}

export function Badge({ children }: BadgeProps) {
  return <div className="badge">{children}</div>
}
