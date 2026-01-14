import React from 'react';

/**
 * Properties for the EmptyState component.
 */
interface EmptyStateProps {
  /**
   * The message to display when there is no content.
   */
  message?: string;
  /**
   * Optional children to render below the message.
   */
  children?: React.ReactNode;
}

/**
 * A component to display when a list or section has no content to show.
 * It provides a clear message to the user and can optionally include calls to action.
 * @param {EmptyStateProps} props The properties for the component.
 * @returns {JSX.Element} The EmptyState component.
 */
export function EmptyState({ message = "No data available.", children }: EmptyStateProps) {
  return (
    <div
      style={{
        textAlign: 'center',
        padding: '2rem',
        border: '1px dashed #e0e0e0',
        borderRadius: '0.5rem',
        color: '#757575',
        backgroundColor: '#fdfdfd',
      }}
    >
      <p style={{ fontSize: '1.1rem', marginBottom: '0.5rem' }}>{message}</p>
      {children}
    </div>
  );
}
