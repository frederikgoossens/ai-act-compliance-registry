# AI Act Compliance Registry 🛡️

A blockchain-based registry for EU AI Act compliance, featuring secure smart contracts with overpayment protection and professional-grade security features.

## 🚀 Live Deployment

**Sepolia Testnet**: `0xFB8615e7f9B5F53D275f27b35C5d74933383dD1A`

[View on Etherscan](https://sepolia.etherscan.io/address/0xFB8615e7f9B5F53D275f27b35C5d74933383dD1A)

## ✨ Features

- **Smart Contract Registry**: On-chain registration of AI systems
- **EU AI Act Compliance**: Built for August 2025 enforcement deadline
- **Overpayment Protection**: Automatic refunds for excess payments
- **Security Features**: Maximum fee limits, input validation, access controls
- **Risk Classification**: 4-tier system (Minimal, Limited, High, Unacceptable)
- **IPFS Integration**: Decentralized document storage

## 🏗️ Technical Stack

- **Smart Contracts**: Solidity ^0.8.19
- **Development Framework**: Foundry
- **Blockchain**: Ethereum (Sepolia Testnet)
- **Security**: Professional audit completed with all fixes applied

## 🔧 Setup

1. Clone the repository:
```bash
git clone https://github.com/frederikgoossens/ai-act-compliance-registry.git
cd ai-act-compliance-registry
```

2. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

3. Create `.env` file:
```bash
cp .env.example .env
# Add your keys:
# - PRIVATE_KEY=your_wallet_private_key
# - ALCHEMY_API_KEY=your_alchemy_api_key
# - ETHERSCAN_API_KEY=your_etherscan_api_key
```

4. Build the contracts:
```bash
forge build
```

## 🧪 Testing

```bash
# Run tests
forge test

# Run with gas reporting
forge test --gas-report
```

## 🚀 Deployment

```bash
# Deploy to Sepolia
forge create src/AIActRegistry.sol:AIActRegistry \
  --rpc-url https://eth-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## 📄 Contract Functions

### For AI Providers
- `registerSystem()` - Register an AI system (0.01 ETH fee)
- `updateCompliance()` - Update compliance status
- `getProviderSystems()` - View your registered systems

### For Public
- `systems()` - View any AI system details
- `totalSystems()` - Get total registered systems
- `getContractInfo()` - Get registry statistics

## 🔒 Security Features

- ✅ Overpayment refund protection
- ✅ Maximum fee limits (1 ETH cap)
- ✅ System existence validation
- ✅ Enhanced input validation
- ✅ Secure withdrawal mechanisms

## 🎯 Roadmap

- [ ] Frontend interface (in progress)
- [ ] Content provenance detection (Pillar 2)
- [ ] Guidance system integration (Pillar 3)
- [ ] Mainnet deployment
- [ ] Multi-chain support

## 👤 Author

**Frederik Goossens**
- GitHub: [@frederikgoossens](https://github.com/frederikgoossens)
- LinkedIn: [Frederik Goossens](https://www.linkedin.com/in/frederikgoossens/)

## 📜 License

This project is licensed under the MIT License.
