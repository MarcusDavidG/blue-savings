import React from 'react';

/**
 * Properties for the Sidebar component.
 */
interface SidebarProps {
  /**
   * The content to be rendered inside the sidebar.
   */
  children?: React.ReactNode;
  /**
   * Optional inline styles for the sidebar.
   */
  style?: React.CSSProperties;
}

/**
 * A layout component that acts as a sidebar, typically for navigation or supplementary content.
 * @param {SidebarProps} props The properties for the component.
 * @returns {JSX.Element} The Sidebar component.
 */
export function Sidebar({ children, style }: SidebarProps) {
  return (
    <aside
      style={{
        width: '250px', // Example fixed width
        padding: '1rem',
        borderRight: '1px solid #e0e0e0',
        backgroundColor: '#f8f8f8',
        ...style,
      }}
    >
      {children}
    </aside>
  );
}
