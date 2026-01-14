'use client'

import Head from 'next/head';

/**
 * This is the dashboard page.
 * It displays a summary of the user's vaults and savings.
 * @returns The dashboard page component.
 */
export default function DashboardPage() {
  return (
    <>
      <Head>
        <title>Dashboard - My Savings</title>
      </Head>
      <div style={{ padding: '2rem' }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 'bold', marginBottom: '2rem' }}>
          Dashboard
        </h1>
        
        {/* This is the summary section, displaying total vaults, total saved, and active goals. */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1.5rem' }}>
          <div style={{ background: 'white', padding: '1.5rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
            <p style={{ color: '#6B7280', marginBottom: '0.5rem' }}>Total Vaults</p>
            <p style={{ fontSize: '2rem', fontWeight: 'bold', color: '#0052FF' }}>0</p>
          </div>
          
          <div style={{ background: 'white', padding: '1.5rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
            <p style={{ color: '#6B7280', marginBottom: '0.5rem' }}>Total Saved</p>
            <p style={{ fontSize: '2rem', fontWeight: 'bold', color: '#0052FF' }}>0 ETH</p>
          </div>
          
          <div style={{ background: 'white', padding: '1.5rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
            <p style={{ color: '#6B7280', marginBottom: '0.5rem' }}>Active Goals</p>
            <p style={{ fontSize: '2rem', fontWeight: 'bold', color: '#0052FF' }}>0</p>
          </div>
        </div>
        
        {/* This is the recent vaults section. */}
        <div style={{ marginTop: '2rem', background: 'white', padding: '2rem', borderRadius: '0.5rem', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
          <h2 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '1rem' }}>Recent Vaults</h2>
          <p style={{ color: '#6B7280' }}>No vaults yet. Create your first vault to get started!</p>
        </div>
      </div>
    </>
  )
}
