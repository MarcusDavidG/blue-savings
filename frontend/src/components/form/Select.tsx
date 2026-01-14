import React, { SelectHTMLAttributes } from 'react';

/**
 * Properties for the Select component.
 * Extends standard HTML select attributes.
 */
interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  /**
   * The options to display in the select dropdown.
   * Each option should have a 'value' and 'label'.
   */
  options: { value: string; label: string }[];
  /**
   * The label for the select input.
   */
  label?: string;
}

/**
 * A reusable Select dropdown component.
 * @param {SelectProps} props The properties for the component.
 * @returns {JSX.Element} The Select component.
 */
export function Select({ options, label, id, ...rest }: SelectProps) {
  const uniqueId = id || `select-${Math.random().toString(36).substr(2, 9)}`;
  return (
    <div>
      {label && <label htmlFor={uniqueId} style={{ display: 'block', marginBottom: '0.5rem', fontWeight: 'bold' }}>{label}</label>}
      <select
        id={uniqueId}
        style={{
          width: '100%',
          padding: '0.75rem 1rem',
          border: '1px solid #ccc',
          borderRadius: '0.25rem',
          backgroundColor: 'white',
          appearance: 'none', // Remove default browser styling
          backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20' fill='currentColor'%3E%3Cpath fillRule='evenodd' d='M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z' clipRule='evenodd' /%3E%3C/svg%3E")`,
          backgroundRepeat: 'no-repeat',
          backgroundPosition: 'right 0.75rem center',
          backgroundSize: '1.5em 1.5em',
        }}
        {...rest}
      >
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </div>
  );
}
