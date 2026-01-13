'use client'

import Link from 'next/link'

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
        <Link href="/" style={{ textDecoration: 'none' }}>
          <h1 style={{ color: '#0052FF', fontSize: '1.5rem', fontWeight: 'bold' }}>
            BlueSavings
          </h1>
        </Link>
        
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
