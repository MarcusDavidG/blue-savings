import React from 'react';

/**
 * Properties for the Box component.
 */
interface BoxProps {
  /**
   * The content to be rendered inside the box.
   */
  children?: React.ReactNode;
  /**
   * Optional inline styles for the box.
   */
  style?: React.CSSProperties;
}

/**
 * A basic layout component that renders its children within a div,
 * acting as a flexible container.
 * @param {BoxProps} props The properties for the component.
 * @returns {JSX.Element} The Box component.
 */
export function Box({ children, style }: BoxProps) {
  return (
    <div
      style={{
        padding: '1rem',
        border: '1px solid #eee',
        borderRadius: '0.25rem',
        ...style,
      }}
    >
      {children}
    </div>
  );
}
