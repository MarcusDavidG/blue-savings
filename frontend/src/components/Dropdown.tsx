import React, { useState } from 'react';

/**
 * Properties for the Dropdown component.
 */
interface DropdownProps {
  /**
   * The content of the dropdown button.
   */
  buttonContent: React.ReactNode;
  /**
   * The content of the dropdown menu.
   */
  children?: React.ReactNode;
}

/**
 * A component to display a dropdown menu.
 * @param {DropdownProps} props The properties for the component.
 * @returns {JSX.Element} The Dropdown component.
 */
export function Dropdown({ buttonContent, children }: DropdownProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div style={{ position: 'relative', display: 'inline-block' }}>
      <button onClick={() => setIsOpen(!isOpen)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>
        {buttonContent}
      </button>
      {isOpen && (
        <div
          style={{
            position: 'absolute',
            top: '100%',
            left: 0,
            border: '1px solid #ccc',
            borderRadius: '0.25rem',
            backgroundColor: '#fff',
            boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
            minWidth: '150px',
            zIndex: 1,
          }}
        >
          {children}
        </div>
      )}
    </div>
  );
}
