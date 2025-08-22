// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// Interface for DEX with unsafe price calc/Oracle
interface IBadDex {
    function swap(address tokenIn, address tokenOut, uint amountIn) external;
    function getTokenPrice(address token) external view returns (uint);
}
interface IERC20 {
    function transfer(address to, uint amount) external returns (bool);
    function balanceOf(address who) external view returns (uint);
    function approve(address to, uint amount) external returns (bool);
}

contract VulnerableVault {
    IBadDex public dex;
    IERC20 public stablecoin;
    IERC20 public targetToken;
    mapping(address => uint) public balances;

    constructor(address _dex, address _stablecoin, address _targetToken) {
        dex = IBadDex(_dex);
        stablecoin = IERC20(_stablecoin);
        targetToken = IERC20(_targetToken);
    }

    // User deposits target token, gets stablecoin value based on DEX price
    function deposit(uint amount) external {
        targetToken.transfer(address(dex), amount); // Send tokens to DEX (simplified)
        uint price = dex.getTokenPrice(address(targetToken));
        uint payout = amount * price; // Vulnerability: uses manipulatable price
        stablecoin.transfer(msg.sender, payout); // Overpay possible!
        balances[msg.sender] += payout;
    }
}
