# Denial of Service (DoS) in Solidity — Examples & Tests

This repository contains **vulnerable smart contracts**, **exploits**, and **tests** demonstrating common Denial of Service (DoS) patterns in Solidity.  
It complements the in-depth blog post: [Read the full article here](https://medium.com/@vishhxyz/stopping-the-stop-outsmarting-dos-attacks-in-ethereum-smart-contracts-4945a1dfa73c)

---

## 📂 Repository Structure
```
/remix-examples   → Contracts to try directly in Remix  
/foundry-tests    → Foundry test cases for each DoS scenario  
```

---

## 🚀 Getting Started

### 1️⃣ Foundry Setup
Make sure you have [Foundry](https://book.getfoundry.sh/getting-started/installation) installed.

```bash
# Install dependencies
forge install
# Clone the repository
git clone https://github.com/vishaalS7/top10-smartcontract-vulnerabilities.git
cd top10-smartcontract-vulnerabilities/03-DenialOfService-DOS
# Initialize Foundry
forge init
# Compile contracts
forge build
# Run all tests
forge test

# Run specific test file
forge test --match-path foundry-tests/VulnerableTest.t.sol
```

---

### 2️⃣ Try in Remix
You can directly load the contracts in the `/remix-examples` folder into [Remix IDE](https://remix.ethereum.org/).

Example workflow:
1. Open Remix
2. Create a new file `KingOfEther.sol`
3. Paste the code from `remix-examples/KingOfEther.sol`
4. Deploy and follow the comments in the file to reproduce the DoS scenario

---

## 💡 Included Vulnerabilities

- **Unbounded Loops**
- **Push Payment DoS** (King of the Ether Throne)
- **Gas Limit Exhaustion**
- **Revert on Receive**
- **Auction Finalization Blocking**

---

## 🛡️ Mitigations
- Use **pull payments** instead of pushing Ether in loops
- Avoid **unbounded loops** in critical paths
- Use `.call` with proper error handling
- Design fallback mechanisms for stalled state

For details on these mitigations, see the [full blog post](https://medium.com/@vishhxyz/stopping-the-stop-outsmarting-dos-attacks-in-ethereum-smart-contracts-4945a1dfa73c).

---

## 📜 License
MIT
