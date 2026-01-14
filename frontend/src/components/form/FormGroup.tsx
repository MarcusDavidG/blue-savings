import React from 'react';

/**
 * Properties for the FormGroup component.
 */
interface FormGroupProps {
  /**
   * The content of the form group, typically FormFields.
   */
  children: React.ReactNode;
}

/**
 * A container component for grouping related form elements, providing consistent spacing.
 * @param {FormGroupProps} props The properties for the component.
 * @returns {JSX.Element} The FormGroup component.
 */
export function FormGroup({ children }: FormGroupProps) {
  return (
    <div style={{ marginBottom: '1.5rem', padding: '1rem', border: '1px solid #e0e0e0', borderRadius: '0.25rem' }}>
      {children}
    </div>
  );
}
