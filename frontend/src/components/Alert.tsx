/**
 * Properties for the Alert component.
 */
interface AlertProps {
  /**
   * The content of the alert.
   */
  children?: React.ReactNode;
}

/**
 * A component to display an alert message.
 * @param {AlertProps} props The properties for the component.
 * @returns {JSX.Element} The Alert component.
 */
export function Alert({ children }: AlertProps) {
  return (
    <div
      style={{
        padding: '1rem',
        border: '1px solid #ccc',
        borderRadius: '0.25rem',
        backgroundColor: '#f8f8f8',
      }}
    >
      {children}
    </div>
  );
}
