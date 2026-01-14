import React, { InputHTMLAttributes } from 'react';

/**
 * Properties for the Checkbox component.
 * Extends standard HTML input attributes for checkboxes.
 */
interface CheckboxProps extends InputHTMLAttributes<HTMLInputElement> {
  /**
   * The label text displayed next to the checkbox.
   */
  label?: string;
}

/**
 * A reusable Checkbox component with a label.
 * @param {CheckboxProps} props The properties for the component.
 * @returns {JSX.Element} The Checkbox component.
 */
export function Checkbox({ label, id, ...rest }: CheckboxProps) {
  const uniqueId = id || `checkbox-${Math.random().toString(36).substr(2, 9)}`;
  return (
    <div style={{ display: 'flex', alignItems: 'center' }}>
      <input
        type="checkbox"
        id={uniqueId}
        style={{ marginRight: '0.5rem' }}
        {...rest}
      />
      {label && <label htmlFor={uniqueId}>{label}</label>}
    </div>
  );
}
