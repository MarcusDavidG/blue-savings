'use client'

import Link from 'next/link'

/**
 * A component to display the header of the application.
 * It includes the application logo/name and navigation links.
 * @returns {JSX.Element} The Header component.
 */
export function Header() {
  return (
    <header style={{
      background: 'white',
      borderBottom: '1px solid #E5E7EB',
      padding: '1rem 2rem'
    }}>
      <div style={{
        maxWidth: '1200px',
        margin: '0 auto',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center'
      }}>
        {/* Application Logo/Name */}
        <Link href="/" style={{ textDecoration: 'none' }}>
          <h1 style={{ color: '#0052FF', fontSize: '1.5rem', fontWeight: 'bold' }}>
            BlueSavings
          </h1>
        </Link>
        
        {/* Navigation Links */}
        <nav style={{ display: 'flex', gap: '2rem', alignItems: 'center' }}>
          <Link href="/dashboard" style={{ color: '#4B5563', textDecoration: 'none' }}>
            Dashboard
          </Link>
          <Link href="/vaults" style={{ color: '#4B5563', textDecoration: 'none' }}>
            Vaults
          </Link>
          <Link href="/create" style={{ color: '#4B5563', textDecoration: 'none' }}>
            Create
          </Link>
        </nav>
      </div>
    </header>
  )
}
