# AgriChain Frontend

Next.js 14 · TypeScript · Tailwind CSS · ethers.js v6

## Setup

### 1. Install Node.js (if not installed)
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 2. Install dependencies
```bash
cd frontend
npm install
```

### 3. Configure contract addresses
Open `src/config/contracts.ts` and paste your deployed contract addresses.

### 4. Start the dev server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## Pages

| Route | Description |
|---|---|
| `/` | Landing page |
| `/register` | Sign up with wallet |
| `/profile` | View & edit profile |
| `/documents` | Upload KYC documents |
| `/marketplace/crops` | Browse & list crops |
| `/marketplace/products` | Browse & list shop products |
| `/orders` | Manage orders (pay, confirm) |
| `/transactions` | Payment history |
| `/complaints` | File & track disputes |
| `/admin` | Admin panel (verify users, resolve complaints) |

## Wallet Support
- MetaMask
- Any injected EIP-1193 wallet (Rabby, Brave Wallet, etc.)
- The app auto-prompts to switch to Sepolia

## Order Flow
1. Buyer/Farmer places order on `/marketplace`
2. Pays on `/orders` → funds held in Treasury contract
3. Buyer confirms receipt → Treasury releases ETH to seller
4. Transaction recorded in TransactionManager
