import React from 'react';

/**
 * Properties for the Section component.
 */
interface SectionProps {
  /**
   * The content to be rendered inside the section.
   */
  children?: React.ReactNode;
  /**
   * Optional inline styles for the section.
   */
  style?: React.CSSProperties;
  /**
   * Optional title for the section.
   */
  title?: string;
}

/**
 * A layout component that acts as a thematic grouping of content within a page.
 * It can optionally include a title and applies basic padding.
 * @param {SectionProps} props The properties for the component.
 * @returns {JSX.Element} The Section component.
 */
export function Section({ children, style, title }: SectionProps) {
  return (
    <section
      style={{
        padding: '2rem 0',
        borderBottom: '1px solid #f0f0f0',
        marginBottom: '2rem',
        ...style,
      }}
    >
      {title && <h2 style={{ fontSize: '1.8rem', marginBottom: '1rem' }}>{title}</h2>}
      {children}
    </section>
  );
}
