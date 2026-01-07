# Base Savings Vault - Deployment Guide

## 🚀 Pre-Deployment Checklist

### 1. Get Your Base Wallet Ready

- [ ] Have a wallet with Base ETH (for gas fees)
- [ ] Get Base Sepolia ETH for testing: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
- [ ] Save your private key securely

### 2. Get API Keys

- [ ] BaseScan API key: https://basescan.org/myapikey
- [ ] Optional: Infura/Alchemy for RPC (or use public Base RPC)

### 3. Set Up Environment

```bash
cd ~/base-savings-vault
cp .env.example .env
nano .env  # Or use your preferred editor
```

Add your keys:
```
PRIVATE_KEY=0x...your_private_key
BASESCAN_API_KEY=...your_basescan_key
```

## 🧪 Test Deployment (Base Sepolia)

### Step 1: Test Locally First

```bash
# Run all tests
forge test -vv

# Check gas usage
forge test --gas-report
```

### Step 2: Deploy to Base Sepolia

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base_sepolia \
  --broadcast \
  --verify

# Note the deployed address from output
```

### Step 3: Test Interactions on Sepolia

```bash
export VAULT_ADDRESS=0x...  # Your deployed address

# Create a test vault
export UNLOCK_TIMESTAMP=$(date -d "+1 hour" +%s)
forge script script/Interact.s.sol:CreateVaultScript \
  --rpc-url base_sepolia \
  --broadcast

# Make a test deposit
export VAULT_ID=0
export DEPOSIT_AMOUNT=10000000000000000  # 0.01 ETH
forge script script/Interact.s.sol:DepositScript \
  --rpc-url base_sepolia \
  --broadcast

# Check vault details
forge script script/Interact.s.sol:GetVaultDetailsScript \
  --rpc-url base_sepolia
```

## 🌐 Production Deployment (Base Mainnet)

### IMPORTANT: Double-check everything before mainnet deployment!

### Step 1: Final Security Check

```bash
# Run comprehensive tests
forge test -vvv

# Check for known vulnerabilities
forge clean && forge build
```

### Step 2: Deploy to Base Mainnet

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base \
  --broadcast \
  --verify \
  --slow  # Add for better reliability
```

**Expected output:**
```
Deploying SavingsVault...
SavingsVault deployed to: 0x...
Owner: 0x...
Fee BPS: 50
```

### Step 3: Verify on BaseScan

The `--verify` flag should auto-verify, but if needed:

```bash
forge verify-contract \
  0x...YOUR_CONTRACT_ADDRESS \
  src/SavingsVault.sol:SavingsVault \
  --chain base \
  --watch
```

### Step 4: Save Your Deployment Info

Create a file with your deployment details:

```bash
echo "VAULT_ADDRESS=0x..." >> .env
```

## 📢 Post-Deployment: Going Public

### 1. Update README

Add your deployed address to README.md:

```markdown
## Live Contracts

- Base Mainnet: [0x...](https://basescan.org/address/0x...)
```

### 2. Create Initial Vaults

Make yourself the first user:

```bash
# Create a showcase vault
export VAULT_ADDRESS=0x...
export GOAL_AMOUNT=1000000000000000000  # 1 ETH
export UNLOCK_TIMESTAMP=0

forge script script/Interact.s.sol:CreateVaultScript \
  --rpc-url base \
  --broadcast

# Make a deposit to show it works
export VAULT_ID=0
export DEPOSIT_AMOUNT=100000000000000000  # 0.1 ETH
forge script script/Interact.s.sol:DepositScript \
  --rpc-url base \
  --broadcast
```

### 3. Create BaseScan Read/Write UI

1. Go to your contract on BaseScan
2. Navigate to "Contract" tab
3. Click "Read Contract" / "Write Contract"
4. Users can interact directly via BaseScan

## 🎯 Promoting Your dApp

### Day 1: Initial Launch

1. **Push to GitHub**
   ```bash
   gh repo create base-savings-vault --public --source=. --remote=origin --push
   ```

2. **Share on X (Twitter)**
   ```
   🚀 Just launched Base Savings Vault on @base!
   
   ⏰ Time-locked savings
   🎯 Goal-based vaults
   💎 0.5% transparent fees
   
   Help yourself save with on-chain guarantees!
   
   Live: https://basescan.org/address/0x...
   GitHub: https://github.com/yourname/base-savings-vault
   
   #Base #DeFi #BuildOnBase
   ```

3. **Post in Base Discord**
   - Join: https://discord.gg/buildonbase
   - Share in #showcase channel

4. **Farcaster (if you have account)**
   Post similar update with contract link

### Week 1: Build Momentum

- [ ] Create example vaults with different timeframes
- [ ] Document user testimonials/early usage
- [ ] Create simple interaction guide/video
- [ ] Engage with Base builder community
- [ ] Add features (check roadmap)

### Week 2-4: Scale

- [ ] Add frontend UI (even simple HTML/JS)
- [ ] Run small campaign (save 0.01 ETH, win prize)
- [ ] Contribute to other Base repos
- [ ] Write blog post about building process
- [ ] Monitor and optimize based on usage

## 📊 Tracking Your Impact

### Daily Checks

```bash
# Check contract stats
cast call $VAULT_ADDRESS "vaultCounter()(uint256)" --rpc-url base
cast call $VAULT_ADDRESS "totalFeesCollected()(uint256)" --rpc-url base

# Check your leaderboard rank
# Visit: https://talent.app/~/earn/base-january
```

### Weekly Analysis

1. Transaction count on BaseScan
2. Unique users (distinct addresses)
3. Total volume (TVL)
4. GitHub stars/forks
5. Talent.app leaderboard position

## 🛠️ Quick Fixes & Tips

### If deployment fails

```bash
# Check your balance
cast balance $YOUR_ADDRESS --rpc-url base

# Check gas price
cast gas-price --rpc-url base

# Try with higher gas limit
forge script ... --gas-limit 3000000
```

### If verification fails

```bash
# Manual verification
forge verify-contract \
  $CONTRACT_ADDRESS \
  src/SavingsVault.sol:SavingsVault \
  --chain base \
  --compiler-version 0.8.24 \
  --watch
```

### Testing without spending real ETH

Always test on Base Sepolia first!

```bash
# Use Sepolia for all testing
--rpc-url base_sepolia
```

## 📝 Important Notes

1. **Never commit .env file** - It contains your private key!
2. **Test everything on Sepolia first** - Mainnet mistakes are expensive
3. **Keep private key secure** - Consider hardware wallet for production
4. **Monitor contract after launch** - Check for unusual activity
5. **Have emergency plan** - Know how to pause/respond to issues

## 🆘 Troubleshooting

### "Insufficient funds"
- Add more Base ETH to your deployer address

### "Nonce too low/high"
- Wait a moment and retry, or specify nonce manually

### "Contract verification failed"
- Check compiler version matches (0.8.24)
- Ensure contract is deployed successfully first
- Try manual verification command above

## ✅ Post-Launch Checklist

After successful deployment:

- [ ] Contract verified on BaseScan
- [ ] README updated with contract address
- [ ] Pushed to GitHub with clear documentation
- [ ] Created initial test vaults
- [ ] Shared in Base Discord
- [ ] Posted on X/Farcaster
- [ ] Monitoring daily activity
- [ ] Tracking talent.app leaderboard

## 🎉 You're Live!

Congratulations! Your Base dApp is now live. Focus on:
1. **Real usage** - Get actual users interacting
2. **GitHub activity** - Regular commits and improvements
3. **Community engagement** - Help others, share learnings
4. **Iteration** - Add features based on feedback

Good luck climbing the leaderboard! 🚀
