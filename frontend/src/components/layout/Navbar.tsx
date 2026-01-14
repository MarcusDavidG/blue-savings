import React from 'react';

/**
 * Properties for the Navbar component.
 */
interface NavbarProps {
  /**
   * The content to be rendered inside the navigation bar.
   */
  children?: React.ReactNode;
  /**
   * Optional inline styles for the navbar.
   */
  style?: React.CSSProperties;
}

/**
 * A layout component that acts as a navigation bar, typically placed at the top of a page.
 * @param {NavbarProps} props The properties for the component.
 * @returns {JSX.Element} The Navbar component.
 */
export function Navbar({ children, style }: NavbarProps) {
  return (
    <nav
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: '1rem 2rem',
        backgroundColor: '#f8f8f8',
        borderBottom: '1px solid #e0e0e0',
        ...style,
      }}
    >
      {children}
    </nav>
  );
}
