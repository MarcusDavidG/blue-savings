# Vault Templates

Pre-configured vault templates for common use cases.

## Template 1: Emergency Fund

**Purpose:** 6-month emergency fund with time lock

**Configuration:**
```bash
export METADATA="Emergency Fund - 6 Months"
export GOAL_AMOUNT=5000000000000000000  # 5 ETH
export UNLOCK_TIMESTAMP=$(($(date +%s) + 15768000))  # 6 months from now
```

**Use Case:** Cannot access funds for 6 months, encouraging discipline

---

## Template 2: Vacation Savings

**Purpose:** Save for summer vacation 2027

**Configuration:**
```bash
export METADATA="Summer Vacation 2027"
export GOAL_AMOUNT=2000000000000000000  # 2 ETH
export UNLOCK_TIMESTAMP=$(($(date +%s) + 31536000))  # 1 year
```

**Use Case:** Goal-based savings with 1-year lock

---

## Template 3: Flexible Savings

**Purpose:** General savings with no restrictions

**Configuration:**
```bash
export METADATA="General Savings"
export GOAL_AMOUNT=0  # No goal
export UNLOCK_TIMESTAMP=0  # No lock
```

**Use Case:** Maximum flexibility, withdraw anytime

---

## Template 4: House Down Payment

**Purpose:** Long-term savings for house purchase

**Configuration:**
```bash
export METADATA="House Down Payment Fund"
export GOAL_AMOUNT=50000000000000000000  # 50 ETH
export UNLOCK_TIMESTAMP=0  # No time lock, just goal
```

**Use Case:** High goal amount, no time pressure

---

## Template 5: Retirement Savings

**Purpose:** Very long-term locked savings

**Configuration:**
```bash
export METADATA="Retirement Fund"
export GOAL_AMOUNT=100000000000000000000  # 100 ETH
export UNLOCK_TIMESTAMP=$(($(date +%s) + 315360000))  # 10 years
```

**Use Case:** Maximum discipline, 10-year lock

---

## Creating from Templates

1. Copy the configuration you want
2. Run: `./scripts/create-vault-mainnet.sh`
3. Start making deposits
4. Track progress with `./scripts/check-vault-mainnet.sh`

## Customization

Modify any parameter:
- `METADATA`: Any descriptive text
- `GOAL_AMOUNT`: In wei (1 ETH = 1000000000000000000 wei)
- `UNLOCK_TIMESTAMP`: Unix timestamp or 0 for no lock
