# 🔒 Reentrancy Attack Examples & Mitigation in Solidity

This repository contains **beginner‑friendly Solidity examples** demonstrating **reentrancy vulnerabilities**, exploits, and safe patterns to prevent them.  
It includes:

- Vulnerable `EtherStore` contract  
- Exploit `Attack` contract  
- Safe `FixedEtherStore` contract with reentrancy guard  
- **Foundry** test suite to demonstrate the attack and the mitigation  

---

## 📚 Overview

Reentrancy is a classic smart contract vulnerability where an attacker can repeatedly call a vulnerable function **before** the first invocation finishes, often draining funds.

This repo contains:
1. **Vulnerable Example** — shows how *not* to write withdrawal logic.
2. **Attack Example** — demonstrates how an attacker exploits the bug.
3. **Fixed Example** — demonstrates secure coding patterns using:
   - State update before external interaction
   - Reentrancy guard modifier
4. **Automated Tests** — to prove both the exploit and the fix using Foundry.

---

## 📂 Folder Structure

.
├── src
│ ├── EtherStore.sol # Vulnerable contract + Attack contract
│ ├── FixedEtherStore.sol # Secure version with reentrancy mitigation
│ ├── AttackCrossFunction.sol # Attack contract demonstrating cross-function reentrancy
│ ├── SimpleRentrancy.sol
│ ├── VulnerableBank.sol
├── test
│ └── ReentrancyTest.t.sol # Foundry test suite
│ └── EtherStoreTest.t.sol # Foundry test suite
├── foundry.toml
└── README.md


---

## ⚡ Getting Started

### 1️⃣ Install Foundry

curl -L https://foundry.paradigm.xyz | bash

```bash
foundryup
```


### 2️⃣ Clone this Repo

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```


### 3️⃣ Install Dependencies

```bash
forge install
```


### 4️⃣ Run Tests

```bash
forge test
```


---

## 🛡 Mitigation Highlights

We cover:
- ✅ **Checks-Effects-Interactions** pattern
- ✅ **State update before external calls**
- ✅ **Reentrancy Guards** (mutex or OpenZeppelin's `ReentrancyGuard`)
- ✅ **Pull over Push** payment model

---

## 📝 Blog Post

📖 **Read the full beginner‑friendly guide to reentrancy attacks here:**  
[Beginner's Guide to Preventing Reentrancy Attacks](https://medium.com/@vishhxyz/breaking-the-loop-%EF%B8%8F-the-ultimate-guide-to-reentrancy-in-ethereum-f6142fff128e)

---

## 💻 Author

Created by **[@Vishhxyz]**  
💬 Connect on X/Twitter: [@Vishhxyz](https://x.com/vishhxyz)  

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

💡 **Tip:** Fork this repo and modify the contracts/tests to experiment with different attack vectors and mitigations!
