/**
 * Properties for the Badge component.
 */
interface BadgeProps {
  /**
   * The content of the badge.
   */
  children?: React.ReactNode;
}

/**
 * A component to display a badge.
 * @param {BadgeProps} props The properties for the component.
 * @returns {JSX.Element} The Badge component.
 */
export function Badge({ children }: BadgeProps) {
  return (
    <div
      style={{
        display: 'inline-block',
        padding: '0.25rem 0.5rem',
        borderRadius: '0.25rem',
        backgroundColor: '#eee',
        fontWeight: 'bold',
      }}
    >
      {children}
    </div>
  );
}
