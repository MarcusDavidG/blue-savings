export function Footer() {
  return (
    <footer style={{
      background: 'white',
      borderTop: '1px solid #E5E7EB',
      padding: '2rem',
      marginTop: '4rem'
    }}>
      <div style={{
        maxWidth: '1200px',
        margin: '0 auto',
        textAlign: 'center',
        color: '#6B7280'
      }}>
        <p style={{ marginBottom: '1rem' }}>
          BlueSavings - Decentralized Savings Vaults on Base
        </p>
        <p style={{ fontSize: '0.875rem' }}>
          Contract: 0xf185cec4B72385CeaDE58507896E81F05E8b6c6a
        </p>
        <p style={{ fontSize: '0.875rem', marginTop: '0.5rem' }}>
          <a 
            href="https://basescan.org/address/0xf185cec4B72385CeaDE58507896E81F05E8b6c6a" 
            target="_blank" 
            rel="noopener noreferrer"
            style={{ color: '#0052FF' }}
          >
            View on BaseScan
          </a>
        </p>
      </div>
    </footer>
  )
}
