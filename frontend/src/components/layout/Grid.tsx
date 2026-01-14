import React from 'react';

/**
 * Properties for the Grid component.
 */
interface GridProps {
  /**
   * The content to be rendered inside the grid container.
   */
  children?: React.ReactNode;
  /**
   * Defines the grid-template-columns CSS property.
   * Example: 'repeat(3, 1fr)' for 3 equal columns.
   */
  columns?: string;
  /**
   * Defines the gap CSS property between grid items.
   */
  gap?: string;
  /**
   * Optional inline styles for the grid container.
   */
  style?: React.CSSProperties;
}

/**
 * A layout component that uses CSS Grid to arrange its children.
 * Provides props for common grid properties like columns and gap.
 * @param {GridProps} props The properties for the component.
 * @returns {JSX.Element} The Grid component.
 */
export function Grid({ children, columns, gap, style }: GridProps) {
  return (
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: columns,
        gap: gap,
        ...style,
      }}
    >
      {children}
    </div>
  );
}
