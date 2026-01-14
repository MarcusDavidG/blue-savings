/**
 * Properties for the Card component.
 */
interface CardProps {
  /**
   * The content of the card.
   */
  children?: React.ReactNode;
}

/**
 * A component to display a card.
 * @param {CardProps} props The properties for the component.
 * @returns {JSX.Element} The Card component.
 */
export function Card({ children }: CardProps) {
  return (
    <div
      style={{
        padding: '1rem',
        border: '1px solid #ccc',
        borderRadius: '0.25rem',
        backgroundColor: '#fff',
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
      }}
    >
      {children}
    </div>
  );
}
