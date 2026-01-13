'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'

export default function HomePage() {
  const handleLearnMore = () => {
    window.open('https://github.com/MarcusDavidG/blue-savings', '_blank')
  }

  return (
    <div style={{ padding: '4rem 1rem', textAlign: 'center' }}>
      <h1 style={{ fontSize: '4rem', fontWeight: 'bold', marginBottom: '1.5rem', color: '#0052FF' }}>
        BlueSavings
      </h1>
      <p style={{ fontSize: '1.5rem', color: '#4B5563', marginBottom: '2rem' }}>
        Decentralized Savings Vaults on Base
      </p>
      <p style={{ fontSize: '1.125rem', color: '#6B7280', maxWidth: '48rem', margin: '0 auto 3rem' }}>
        Create time-locked or goal-based savings vaults with transparent on-chain guarantees. 
        Built natively on Base for low fees and fast transactions.
      </p>
      
      <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center', marginBottom: '4rem' }}>
        <ConnectButton />
        <button 
          onClick={handleLearnMore}
          style={{
            padding: '1rem 2rem',
            background: '#E5E7EB',
            color: '#1F2937',
            borderRadius: '0.5rem',
            fontSize: '1.125rem',
            fontWeight: '600'
          }}>
          Learn More
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '2rem', maxWidth: '64rem', margin: '0 auto' }}>
        <div style={{ padding: '2rem', background: 'white', borderRadius: '0.5rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
          <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🔒</div>
          <h3 style={{ fontSize: '1.25rem', fontWeight: '600', marginBottom: '0.5rem' }}>Time-Locked Vaults</h3>
          <p style={{ color: '#6B7280' }}>Set unlock timestamps to enforce savings discipline</p>
        </div>
        
        <div style={{ padding: '2rem', background: 'white', borderRadius: '0.5rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
          <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🎯</div>
          <h3 style={{ fontSize: '1.25rem', fontWeight: '600', marginBottom: '0.5rem' }}>Goal-Based Savings</h3>
          <p style={{ color: '#6B7280' }}>Define savings goals that must be reached</p>
        </div>
        
        <div style={{ padding: '2rem', background: 'white', borderRadius: '0.5rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
          <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⚡</div>
          <h3 style={{ fontSize: '1.25rem', fontWeight: '600', marginBottom: '0.5rem' }}>Built on Base</h3>
          <p style={{ color: '#6B7280' }}>Low fees and fast transactions on Layer 2</p>
        </div>
      </div>

      <div style={{ marginTop: '3rem', fontSize: '0.875rem', color: '#9CA3AF' }}>
        <p>Contract: 0xf185...6c6a • Base Mainnet • Verified on BaseScan</p>
      </div>
    </div>
  )
}
