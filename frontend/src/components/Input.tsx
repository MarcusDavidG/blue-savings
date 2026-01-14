/**
 * Properties for the Input component.
 */
interface InputProps {
  /**
   * The type of the input (e.g., "text", "number", "password").
   */
  type?: string;
  /**
   * The placeholder text for the input.
   */
  placeholder?: string;
  /**
   * The current value of the input.
   */
  value?: string;
  /**
   * The function to call when the input value changes.
   */
  onChange?: (event: React.ChangeEvent<HTMLInputElement>) => void;
  /**
   * Optional children to render inside the input container (e.g., an icon).
   */
  children?: React.ReactNode;
}

/**
 * A component to display an input field.
 * @param {InputProps} props The properties for the component.
 * @returns {JSX.Element} The Input component.
 */
export function Input({ type = "text", placeholder, value, onChange, children }: InputProps) {
  return (
    <div style={{ position: 'relative' }}>
      <input
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        style={{
          width: '100%',
          padding: '0.75rem 1rem',
          border: '1px solid #ccc',
          borderRadius: '0.25rem',
          boxSizing: 'border-box',
        }}
      />
      {children}
    </div>
  );
}
