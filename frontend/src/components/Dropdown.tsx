interface DropdownProps {
  children?: React.ReactNode;
}

export function Dropdown({ children }: DropdownProps) {
  return <div className="dropdown">{children}</div>
}
