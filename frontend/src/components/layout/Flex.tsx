import React from 'react';

/**
 * Properties for the Flex component.
 */
interface FlexProps {
  /**
   * The content to be rendered inside the flex container.
   */
  children?: React.ReactNode;
  /**
   * Defines the flex-direction CSS property.
   */
  direction?: 'row' | 'column';
  /**
   * Defines the justify-content CSS property.
   */
  justify?: 'start' | 'end' | 'center' | 'between' | 'around';
  /**
   * Defines the align-items CSS property.
   */
  align?: 'start' | 'end' | 'center' | 'stretch';
  /**
   * Defines the gap CSS property between flex items.
   */
  gap?: string;
  /**
   * Optional inline styles for the flex container.
   */
  style?: React.CSSProperties;
}

/**
 * A layout component that uses CSS Flexbox to arrange its children.
 * Provides props for common flexbox properties like direction, justify, align, and gap.
 * @param {FlexProps} props The properties for the component.
 * @returns {JSX.Element} The Flex component.
 */
export function Flex({ children, direction = 'row', justify, align, gap, style }: FlexProps) {
  const justifyContentMap = {
    start: 'flex-start',
    end: 'flex-end',
    center: 'center',
    between: 'space-between',
    around: 'space-around',
  };

  const alignItemsMap = {
    start: 'flex-start',
    end: 'flex-end',
    center: 'center',
    stretch: 'stretch',
  };

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: direction,
        justifyContent: justify ? justifyContentMap[justify] : undefined,
        alignItems: align ? alignItemsMap[align] : undefined,
        gap: gap,
        ...style,
      }}
    >
      {children}
    </div>
  );
}
