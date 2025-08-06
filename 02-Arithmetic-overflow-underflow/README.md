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


# 🧮 2. What Are Integer Overflow and Underflow?

## 📘 Conceptual Overview

In Solidity, integers have fixed sizes, such as `uint8`, `uint16`, up to `uint256`. These types represent **unsigned integers**, meaning they can only hold non-negative values — and each has a specific range.

For example:
- `uint8` can store values from 0 to 255.
- `uint256` can store values from 0 up to 2²⁵⁶ - 1 (a 78-digit number).

When an arithmetic operation causes the value to go **outside this range**, the number **wraps around** due to how binary math works in the EVM. This behavior is known as:

- **Overflow**: When the value exceeds the maximum (e.g., 255 + 1 = 0 in `uint8`).
- **Underflow**: When the value goes below the minimum (e.g., 0 - 1 = 255 in `uint8`).

---

## 🔁 Overflow Example

```solidity
pragma solidity ^0.7.6;

contract OverflowExample {
    uint8 public count = 255;

    function overflow() public {
        count += 1; // Wraps around to 0 (overflow)
    }
}
```

**Binary Explanation:**
- `255` is `11111111`
- Adding `1` results in `1_00000000` → overflows and becomes `00000000` (0)

---

## 🔁 Underflow Example

```solidity
pragma solidity ^0.7.6;

contract UnderflowExample {
    uint8 public count = 0;

    function underflow() public {
        count -= 1; // Wraps around to 255 (underflow)
    }
}
```

**Binary Explanation:**
- `0` is `00000000`
- Subtracting `1` results in `11111111`, or `255`

---

## 📉 Why It Matters

Prior to Solidity `0.8.0`, arithmetic in Solidity **did not include overflow or underflow checks** by default. This meant contracts could silently wrap values and introduce critical bugs or vulnerabilities without any error being thrown.

However, since Solidity version **0.8.0**, the compiler **automatically includes overflow and underflow checks**. Any operation that would overflow or underflow will now **revert** the transaction unless explicitly placed inside an `unchecked { ... }` block.

---

## 🧮 Visual Comparison

| Type     | Min Value | Max Value                             | Bit Size |
|----------|-----------|----------------------------------------|----------|
| `uint8`  | 0         | 255                                    | 8 bits   |
| `uint256`| 0         | 2^256 - 1 (very large)                 | 256 bits |

Even `uint256` — with its massive range — can overflow or underflow if operations are not properly checked.

---

## 🧪 Try It Yourself

To observe these behaviors:
- Use **Solidity < 0.8.0** in Remix or Foundry to see silent overflow/underflow in action.
- Use **Solidity >= 0.8.0** to see how the same operations revert the transaction by default.

We'll explore both behaviors hands-on using PoCs and Foundry in the next sections.

# 🔄 3. The Evolution: Pre-0.8.0 vs Post-0.8.0

Solidity has come a long way in how it handles arithmetic. Prior to version 0.8.0, developers had to manually guard against integer overflows and underflows. But with the release of Solidity 0.8.0, the language introduced **built-in overflow/underflow checks**, shifting the responsibility from the developer to the compiler.

---

## 🕰️ Pre-0.8.0: No Safety by Default

In versions prior to Solidity 0.8.0, **arithmetic was unchecked**. The compiler would translate operations like `+`, `-`, `*` directly into EVM opcodes (`ADD`, `SUB`, `MUL`) without checking if the result was valid in the context of the data type.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

contract LegacyMath {
    uint8 public value = 255;

    function overflow() public {
        value += 1; // wraps around to 0 (no error)
    }
}
```

---

## 🛡️ The Role of SafeMath (Before 0.8.0)

To mitigate this, libraries like **OpenZeppelin’s SafeMath** became essential.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract SafeAddition {
    using SafeMath for uint256;
    uint256 public total;

    function add(uint256 x) public {
        total = total.add(x); // reverts on overflow
    }
}
```

SafeMath’s implementation:
```solidity
function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
}
```

---

## 🚧 Post-0.8.0: Built-in Arithmetic Checks

Solidity 0.8.0 introduced **automatic checked arithmetic**.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeByDefault {
    uint8 public value = 255;

    function overflow() public {
        value += 1; // reverts automatically on overflow
    }
}
```

Unchecked behavior is opt-in:

```solidity
function unsafe() public {
    unchecked {
        value += 1; // wraps silently
    }
}
```

---

## 🧬 Bytecode Difference: Pre vs Post

### Pre-0.8.0:
- `+` → `ADD`
- Lightweight, unsafe

### Post-0.8.0:
- `+` → `ADD` + overflow check (e.g., `GT`, `ISZERO`, `REVERT`)

### Disassembly Tools:
```bash
solc LegacyMath.sol --bin
solc SafeByDefault.sol --bin
evm disasm bytecode.hex
```

Pre-0.8.0: `PUSH`, `ADD`, `SSTORE`

Post-0.8.0: `PUSH`, `ADD`, `GT`, `ISZERO`, `JUMPI`, `REVERT`, `SSTORE`

---

## 🔍 Summary

| Feature                         | Pre-0.8.0         | Post-0.8.0                |
|---------------------------------|-------------------|----------------------------|
| Arithmetic safety               | ❌ No             | ✅ Yes (by default)        |
| Overflow/underflow reverts      | ❌ No             | ✅ Yes                     |
| Need for SafeMath               | ✅ Required       | ❌ Not needed              |
| Unchecked arithmetic            | Always            | Only inside `unchecked {}`|
| Bytecode injected checks        | ❌ None           | ✅ Present                 |
