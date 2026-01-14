import React, { useState } from 'react';

/**
 * Properties for the Modal component.
 */
interface ModalProps {
  /**
   * Whether the modal is open or not.
   */
  isOpen: boolean;
  /**
   * Function to call when the modal is closed.
   */
  onClose: () => void;
  /**
   * The title of the modal.
   */
  title?: string;
  /**
   * The content of the modal.
   */
  children?: React.ReactNode;
}

/**
 * A component to display a modal dialog.
 * @param {ModalProps} props The properties for the component.
 * @returns {JSX.Element | null} The Modal component, or null if not open.
 */
export function Modal({ isOpen, onClose, title, children }: ModalProps) {
  if (!isOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        zIndex: 1000,
      }}
    >
      <div
        style={{
          backgroundColor: 'white',
          padding: '2rem',
          borderRadius: '0.5rem',
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          minWidth: '300px',
          maxWidth: '500px',
          position: 'relative',
        }}
      >
        <button
          onClick={onClose}
          style={{
            position: 'absolute',
            top: '1rem',
            right: '1rem',
            background: 'none',
            border: 'none',
            fontSize: '1.5rem',
            cursor: 'pointer',
          }}
        >
          &times;
        </button>
        {title && <h2 style={{ marginBottom: '1rem' }}>{title}</h2>}
        <div>{children}</div>
      </div>
    </div>
  );
}
