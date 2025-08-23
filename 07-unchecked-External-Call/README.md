# 🚨 SC06:2025 Unchecked External Calls  

## 🧠 1. What is an "Unchecked External Call"?  

In Solidity, smart contracts frequently interact with other contracts or externally owned accounts (EOAs). This interaction often happens through **low-level calls** such as:  

```solidity
(bool success, bytes memory data) = someAddress.call(payload);
```  

Here’s the catch:  

- If the external call **fails** (because the callee runs out of gas, reverts, or even doesn’t exist),  
- Solidity’s low-level call **does not automatically revert**.  
- Instead, it simply returns `false` in the `success` variable.  

If developers **forget to check the return value**, the calling contract **continues execution as if everything succeeded** — even when it didn’t.  

---

## 💥 2. Why is This Dangerous?  

Unchecked external calls may look harmless, but they introduce **critical risks** to your smart contract. Here’s why:  

- **💸 Possible Fund Loss**  
  - The contract might record that funds were transferred even though the transaction failed.  

- **📝 Corrupted State**  
  - If the contract updates storage (e.g., marking a loan as repaid, or an NFT as transferred) without verifying success, the on-chain state becomes inconsistent.  

- **🕵️ Silent Failures Exploitable by Attackers**  
  - Malicious contracts can deliberately make calls fail (always reverting, consuming gas, or returning unexpected results) to manipulate logic.  

### 🔍 Real-World Analogy  

Imagine a bakery:  
- A customer pays for bread, and the cashier marks “Payment received ✅”.  
- But the payment machine actually failed silently — no money was transferred.  
- At the end of the day, the bakery believes it earned money it never received.  

That’s exactly what happens in smart contracts when external calls go unchecked.  

---

## 🧪 4. Vulnerable Code Example (Old Solidity)  

```solidity
pragma solidity ^0.4.24;

contract PaymentProcessor {
    function pay(address _recipient) public payable {
        // Low-level call to transfer Ether
        _recipient.call.value(msg.value)("");
        
        // ❌ No check for success/failure
        // The contract assumes payment always worked
    }
}
```

### ❌ What’s Wrong Here?  

- The contract uses **`.call.value()`** (old syntax).  
- If the call fails, it just returns `false`.  
- Since the return value isn’t checked, the function **keeps running as if the payment succeeded**.  

This can cause **silent failures** and **corrupted state**.  

---

## 💥 5. What Could Go Wrong (Impact Table)  

| ⚠️ Problem         | 💣 Risk                                                                 |
|--------------------|-------------------------------------------------------------------------|
| Silent failure     | Contract keeps running even though the external call failed             |
| Loss of funds      | ETH or tokens are *marked as sent* but never actually received          |
| Inconsistent state | Storage updates create false records (e.g., “loan repaid” when it isn’t)|
| Exploitable        | Attackers can deliberately trigger failures to manipulate contract logic|  

---

## ✅ 6. Secure Code Example (Modern Solidity)  

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SafePaymentProcessor {
    function pay(address payable _recipient) public payable {
        // Low-level call to transfer Ether
        (bool success, ) = _recipient.call{value: msg.value}("");

        // ✅ Always check the return value
        require(success, "Payment failed");
    }
}
```

### ✅ Why This is Secure  

- `call` returns a **boolean success flag**.  
- The contract explicitly checks it with `require`.  
- If the transfer fails, the transaction reverts, preventing:  
  - Silent failures  
  - Inconsistent state  
  - False assumptions  

---

## 👨‍💻 7. Real-World Example: King of the Ether Throne  

- **What failed:** The game used `send()` for payments but did **not check** if transfers succeeded.  
- **What went wrong:** Players were entitled to payments that silently failed, yet the contract logic still treated them as paid.  

**Lesson:** Unchecked external calls can silently break contract logic and cause financial loss.  

---

## 📌 9. Key Takeaways (TL;DR for Beginners)  

- **Unchecked external calls = silent failures = danger.**  
- Always **check `success`** before continuing execution.  
- A single missing `require(success)` can cause:  
  - Loss of funds 💸  
  - Corrupted state 📝  
  - Exploitable vulnerabilities 🕵️  

✅ **Golden Rule:** Never trust an external call without verifying its result.  
