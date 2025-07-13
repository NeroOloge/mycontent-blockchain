# MyContent — Smart Contracts (Hardhat)

This repository contains the smart contracts powering the **MyContent** decentralised blogging platform.

Published content is uploaded to IPFS, and its CID is stored on-chain via these contracts. Interactions like likes, bookmarks, and comments are also recorded on-chain to enable full decentralised publishing.

---

## 📄 Contracts

- `DecentralisedBlog.sol` — Main contract handling:
  - Post creation/deletion
  - Comments and replies
  - Likes and unlikes
  - Bookmarks
  - Tags
  - Author profiles

---

## 🛠️ Stack

- **Solidity (v0.8.x)**
- **Hardhat** for development
- **Chai + Ethers.js** for testing
- **OpenZeppelin** for utilities
- **The Graph** for indexing

---

## 🔧 Setup

### 1. Clone the repo
```bash
git clone https://github.com/NeroOloge/mycontent-blockchain
cd mycontent-blockchain
```
### 2. Install dependencies
```bash
npm install
```
### 3. Run tests
```bash
npx hardhat test
```

## 🔌 Deployment

### Local Network
```bash
npx hardhat node
npx hardhat run scripts/deploy.ts --network localhost
```
### Testnet (e.g., Ethereum Sepolia)
Update hardhat.config.ts with your RPC and private key, then:
```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

## 🔎 Indexing with The Graph
Generate and deploy the subgraph from the [MyContent Subgraph](https://github.com/NeroOloge/mycontent-subgraph) repo.

Use the subgraph endpoint in your frontend.