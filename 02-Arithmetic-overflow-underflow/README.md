
# 🔐 Overflow Ops: The Complete Hands-On Guide to Integer Exploits in Ethereum

Welcome to the ultimate deep-dive into **Integer Overflow and Underflow in Solidity and the EVM**. This blog is designed for security researchers, auditors, and smart contract developers who want to **understand, exploit, and defend** against these fundamental vulnerabilities.

---

## 📚 Table of Contents

1. 🧩 Introduction  
2. 🔢 What Are Integer Overflow and Underflow?  
3. 🧠 EVM Internals: How Arithmetic Works  
4. 🏗️ The Evolution: Pre-0.8.0 vs Post-0.8.0  
5. 🧪 Vulnerable Code Examples (Real-World)  
6. 💣 Exploitation Scenarios  
7. 💀 Writing Attack Contracts (PoCs)  
8. 🛠️ Foundry Test Environment Setup  
9. 🧬 Hands-On: Foundry-Based PoC & Fix  
10. 🛡️ Defenses and Best Practices  
11. 🧠 Final Thoughts  
12. 🔗 Resources & Further Reading

---

## 🚀 What You'll Learn

- Why overflows/underflows still matter post-0.8.0  
- How EVM handles arithmetic at the opcode level  
- Real-world vulnerable examples and exploits  
- How to write PoCs and simulate attacks using Foundry  
- Mitigations and best practices using modern Solidity and tools

---

## 🧪 Hands-On with Foundry

This repo contains:
- Vulnerable contracts in Solidity
- Attack contracts (PoC)
- Foundry-based tests with cheatcodes
- Walkthrough of setup, fuzzing, and fixes

```bash
git clone https://github.com/vishaalS7/top10-smartcontract-vulnerabilities.git
cd 02-Arithmetic-overflow-underflow
forge install
forge test
```

---

## 🛡️ Brief Mitigation Guide

| Mitigation                          | Purpose                              |
|------------------------------------|--------------------------------------|
| Use Solidity ≥0.8.0                | Built-in overflow/underflow checks   |
| Avoid `unchecked` unless needed    | Prevents silent wrapping             |
| Validate inputs and logic flows    | Stop bugs before they reach storage  |
| Use Slither, MythX, Foundry Fuzz   | Automated security analysis          |

---

## 📚 References

- [solidity by example](https://solidity-by-example.org/hacks/overflow/)

---

## 🙌 Credits

Written by: vishhxyz  
Blog focus: One-stop security deep-dive on integer vulnerabilities in Ethereum.  
Contributions and feedback welcome!

---
