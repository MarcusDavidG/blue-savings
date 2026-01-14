import React from 'react';

/**
 * Properties for the FormLabel component.
 */
interface FormLabelProps {
  /**
   * The content of the label.
   */
  children: React.ReactNode;
  /**
   * The 'for' attribute for the label, linking it to an input element.
   */
  htmlFor?: string;
}

/**
 * A component to display a label for form elements.
 * @param {FormLabelProps} props The properties for the component.
 * @returns {JSX.Element} The FormLabel component.
 */
export function FormLabel({ children, htmlFor }: FormLabelProps) {
  return (
    <label
      htmlFor={htmlFor}
      style={{
        display: 'block',
        marginBottom: '0.5rem',
        fontWeight: 'bold',
        color: '#333',
      }}
    >
      {children}
    </label>
  );
}
