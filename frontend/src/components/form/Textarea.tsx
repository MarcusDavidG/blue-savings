import React, { TextareaHTMLAttributes } from 'react';

/**
 * Properties for the Textarea component.
 * Extends standard HTML textarea attributes.
 */
interface TextareaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  /**
   * The label for the textarea.
   */
  label?: string;
}

/**
 * A reusable Textarea component with an optional label.
 * @param {TextareaProps} props The properties for the component.
 * @returns {JSX.Element} The Textarea component.
 */
export function Textarea({ label, id, ...rest }: TextareaProps) {
  const uniqueId = id || `textarea-${Math.random().toString(36).substr(2, 9)}`;
  return (
    <div>
      {label && <label htmlFor={uniqueId} style={{ display: 'block', marginBottom: '0.5rem', fontWeight: 'bold' }}>{label}</label>}
      <textarea
        id={uniqueId}
        style={{
          width: '100%',
          padding: '0.75rem 1rem',
          border: '1px solid #ccc',
          borderRadius: '0.25rem',
          boxSizing: 'border-box',
          minHeight: '80px',
        }}
        {...rest}
      />
    </div>
  );
}
