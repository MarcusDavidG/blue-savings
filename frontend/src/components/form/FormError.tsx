import React from 'react';

/**
 * Properties for the FormError component.
 */
interface FormErrorProps {
  /**
   * The error message to display.
   */
  message?: string;
}

/**
 * A component to display form validation errors.
 * @param {FormErrorProps} props The properties for the component.
 * @returns {JSX.Element | null} The FormError component, or null if no message.
 */
export function FormError({ message }: FormErrorProps) {
  if (!message) return null;

  return (
    <p style={{ color: 'red', fontSize: '0.875rem', marginTop: '0.25rem' }}>
      {message}
    </p>
  );
}
