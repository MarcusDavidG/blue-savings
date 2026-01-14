import React from 'react';

/**
 * Properties for the Stack component.
 */
interface StackProps {
  /**
   * The content to be rendered inside the stack.
   */
  children?: React.ReactNode;
  /**
   * Defines the spacing between stacked items.
   */
  spacing?: string;
  /**
   * Defines the direction of the stack.
   */
  direction?: 'row' | 'column';
  /**
   * Optional inline styles for the stack.
   */
  style?: React.CSSProperties;
}

/**
 * A layout component that arranges its children in a one-dimensional stack (row or column).
 * Provides consistent spacing between items.
 * @param {StackProps} props The properties for the component.
 * @returns {JSX.Element} The Stack component.
 */
export function Stack({ children, spacing = '1rem', direction = 'column', style }: StackProps) {
  return (
    <div
      style={{
        display: 'flex',
        flexDirection: direction,
        gap: spacing,
        ...style,
      }}
    >
      {children}
    </div>
  );
}
