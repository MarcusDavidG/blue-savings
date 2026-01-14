import React, { InputHTMLAttributes } from 'react';

/**
 * Properties for the Switch component.
 * Extends standard HTML input attributes for checkboxes, used as a toggle switch.
 */
interface SwitchProps extends InputHTMLAttributes<HTMLInputElement> {
  /**
   * The label text displayed next to the switch.
   */
  label?: string;
}

/**
 * A reusable Switch (toggle) component with a label.
 * @param {SwitchProps} props The properties for the component.
 * @returns {JSX.Element} The Switch component.
 */
export function Switch({ label, id, ...rest }: SwitchProps) {
  const uniqueId = id || `switch-${Math.random().toString(36).substr(2, 9)}`;
  return (
    <div style={{ display: 'flex', alignItems: 'center' }}>
      {label && <label htmlFor={uniqueId} style={{ marginRight: '0.5rem' }}>{label}</label>}
      <label htmlFor={uniqueId} style={{ position: 'relative', display: 'inline-block', width: '38px', height: '20px' }}>
        <input
          type="checkbox"
          id={uniqueId}
          style={{ opacity: 0, width: 0, height: 0 }}
          {...rest}
        />
        <span
          style={{
            position: 'absolute',
            cursor: 'pointer',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: '#ccc',
            transition: '.4s',
            borderRadius: '20px',
          }}
        />
        <span
          style={{
            position: 'absolute',
            content: '""',
            height: '16px',
            width: '16px',
            left: '2px',
            bottom: '2px',
            backgroundColor: 'white',
            transition: '.4s',
            borderRadius: '50%',
            transform: rest.checked ? 'translateX(18px)' : 'translateX(0)',
          }}
        />
        <style jsx>{`
          input:checked + span {
            background-color: #2196F3;
          }
        `}</style>
      </label>
    </div>
  );
}
