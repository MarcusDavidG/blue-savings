import React from 'react';

/**
 * Properties for the FormField component.
 */
interface FormFieldProps {
  /**
   * The content of the form field, typically an input element.
   */
  children: React.ReactNode;
}

/**
 * A container component for individual form fields, providing consistent spacing.
 * @param {FormFieldProps} props The properties for the component.
 * @returns {JSX.Element} The FormField component.
 */
export function FormField({ children }: FormFieldProps) {
  return (
    <div style={{ marginBottom: '1rem' }}>
      {children}
    </div>
  );
}
