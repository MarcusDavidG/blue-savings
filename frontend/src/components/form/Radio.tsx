import React, { InputHTMLAttributes } from 'react';

/**
 * Properties for the Radio component.
 * Extends standard HTML input attributes for radio buttons.
 */
interface RadioProps extends InputHTMLAttributes<HTMLInputElement> {
  /**
   * The label text displayed next to the radio button.
   */
  label?: string;
}

/**
 * A reusable Radio button component with a label.
 * @param {RadioProps} props The properties for the component.
 * @returns {JSX.Element} The Radio component.
 */
export function Radio({ label, id, name, ...rest }: RadioProps) {
  const uniqueId = id || `radio-${Math.random().toString(36).substr(2, 9)}`;
  return (
    <div style={{ display: 'flex', alignItems: 'center' }}>
      <input
        type="radio"
        id={uniqueId}
        name={name} // 'name' attribute is crucial for radio button groups
        style={{ marginRight: '0.5rem' }}
        {...rest}
      />
      {label && <label htmlFor={uniqueId}>{label}</label>}
    </div>
  );
}
