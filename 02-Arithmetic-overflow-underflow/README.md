## 🧩 1. Introduction

Smart contract security has come a long way, but some of the oldest bugs in computing history still haunt modern decentralized applications — and integer overflow and underflow top that list. These seemingly simple arithmetic flaws have been responsible for millions of dollars in stolen funds, failed DeFi protocols, and broken game mechanics on Ethereum and other EVM-based chains.

This guide is your **complete, hands-on deep dive** into how integer overflows and underflows work at the **EVM level**, how they can be **exploited**, and how you can use tools like **Foundry** to recreate, understand, and defend against them.

### What This Guide Covers:
- A foundational understanding of overflow and underflow in Solidity  
- How arithmetic is handled internally by the EVM  
- The crucial differences between Solidity versions **pre-0.8.0** and **post-0.8.0**  
- Real-world vulnerable code snippets and how attackers exploit them  
- Writing PoCs (Proof of Concepts) with custom **attack contracts**  
- Hands-on walkthroughs using **Foundry-based testing**  
- Remediation techniques and **best practices** to stay secure

### Why It Still Matters Today:
While modern Solidity versions introduce safe arithmetic by default, many legacy contracts still run on earlier versions. Even today, developers sometimes disable safety checks using `unchecked` blocks or rely on low-level arithmetic for gas efficiency — creating new vulnerabilities in otherwise secure codebases.

### Why PoC-Based Learning?
Reading about vulnerabilities is one thing. Exploiting them yourself in a controlled environment is where the real understanding begins. This guide isn’t just theory — it's a **battle-tested lab** that will help you **think like an attacker**, understand real exploit paths, and **build better defenses**.

---

### 📌 TL;DR

Integer overflow and underflow are fundamental bugs that still impact smart contract security today — despite newer Solidity versions offering built-in protections.

This guide includes:
- 📘 Clear explanations of overflow/underflow  
- ⚙️ Deep dive into EVM arithmetic  
- 🧪 Real-world vulnerable examples  
- 🔓 Exploitation scenarios and attack contracts  
- 🧰 Foundry-based PoC development  
- 🛡️ Practical defense strategies  

Learn by doing. Break things. Fix them.  
**Understand security at the bytecode level.**
