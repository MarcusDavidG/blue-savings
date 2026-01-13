'use client'

export default function VaultsPage() {
  return (
    <div style={{ padding: '2rem' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 'bold' }}>My Vaults</h1>
        <button style={{
          padding: '0.75rem 1.5rem',
          background: '#0052FF',
          color: 'white',
          borderRadius: '0.5rem',
          fontWeight: '600'
        }}>
          Create New Vault
        </button>
      </div>
      
      <div style={{ background: 'white', padding: '3rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', textAlign: 'center' }}>
        <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>🏦</div>
        <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '0.5rem' }}>No Vaults Yet</h2>
        <p style={{ color: '#6B7280', marginBottom: '1.5rem' }}>
          Create your first savings vault to start saving!
        </p>
        <button style={{
          padding: '0.75rem 2rem',
          background: '#0052FF',
          color: 'white',
          borderRadius: '0.5rem',
          fontWeight: '600'
        }}>
          Get Started
        </button>
      </div>
    </div>
  )
}
