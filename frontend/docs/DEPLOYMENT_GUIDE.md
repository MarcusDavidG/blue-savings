# Deployment Guide

## Prerequisites
- Node.js 18+
- npm or yarn
- Vercel account (optional)

## Environment Variables

### Production
```bash
NEXT_PUBLIC_CHAIN_ID=8453
NEXT_PUBLIC_CONTRACT_ADDRESS=0xf185cec4B72385CeaDE58507896E81F05E8b6c6a
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id
```

### Test
```bash
NEXT_PUBLIC_CHAIN_ID=84532
NEXT_PUBLIC_CONTRACT_ADDRESS=0x290912Be0a52414DD8a9F3Aa7a8c35ee65A4F402
```

## Build

```bash
npm run build
```

## Deploy to Vercel

```bash
vercel --prod
```

## Docker Deployment

```bash
docker build -t bluesavings-frontend .
docker run -p 3000:3000 bluesavings-frontend
```
