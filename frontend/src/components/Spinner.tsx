/**
 * Properties for the Spinner component.
 */
interface SpinnerProps {
  /**
   * The size of the spinner.
   */
  size?: 'small' | 'medium' | 'large';
  /**
   * The color of the spinner.
   */
  color?: string;
  /**
   * Optional children to render inside the spinner (e.g., text).
   */
  children?: React.ReactNode;
}

/**
 * A component to display a loading spinner.
 * @param {SpinnerProps} props The properties for the component.
 * @returns {JSX.Element} The Spinner component.
 */
export function Spinner({ size = 'medium', color = '#0052FF', children }: SpinnerProps) {
  const spinnerSize = {
    small: '1rem',
    medium: '2rem',
    large: '3rem',
  }[size];

  const borderWidth = {
    small: '2px',
    medium: '3px',
    large: '4px',
  }[size];

  return (
    <div
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        margin: '0.5rem',
      }}
    >
      <div
        style={{
          width: spinnerSize,
          height: spinnerSize,
          border: `${borderWidth} solid #f3f3f3`,
          borderTop: `${borderWidth} solid ${color}`,
          borderRadius: '50%',
          animation: 'spin 1s linear infinite',
        }}
      />
      {children && <span style={{ marginLeft: '0.5rem', color: color }}>{children}</span>}

      <style jsx global>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}
