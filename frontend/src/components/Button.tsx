/**
 * Properties for the Button component.
 */
interface ButtonProps {
  /**
   * The content of the button.
   */
  children?: React.ReactNode;
  /**
   * The function to call when the button is clicked.
   */
  onClick?: () => void;
}

/**
 * A component to display a button.
 * @param {ButtonProps} props The properties for the component.
 * @returns {JSX.Element} The Button component.
 */
export function Button({ children, onClick }: ButtonProps) {
  return (
    <button
      onClick={onClick}
      style={{
        padding: '0.5rem 1rem',
        border: '1px solid #ccc',
        borderRadius: '0.25rem',
        backgroundColor: '#eee',
        cursor: 'pointer',
      }}
    >
      {children}
    </button>
  );
}
