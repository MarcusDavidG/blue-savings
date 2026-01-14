import React from 'react';

/**
 * Properties for the Container component.
 */
interface ContainerProps {
  /**
   * The content to be rendered inside the container.
   */
  children?: React.ReactNode;
  /**
   * Optional inline styles for the container.
   */
  style?: React.CSSProperties;
}

/**
 * A layout component that centers and limits the width of its children,
 * providing consistent horizontal spacing.
 * @param {ContainerProps} props The properties for the component.
 * @returns {JSX.Element} The Container component.
 */
export function Container({ children, style }: ContainerProps) {
  return (
    <div
      style={{
        maxWidth: '1200px', // Example max-width, adjust as needed
        margin: '0 auto', // Center the container
        padding: '0 1rem', // Add some horizontal padding
        ...style,
      }}
    >
      {children}
    </div>
  );
}
