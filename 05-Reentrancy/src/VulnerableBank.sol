// SPDX-License-Identifier: MIT
// Vulnerable contract with cross-function reentrancy vulnerability
pragma solidity ^0.8.0;

contract VulnerableBank {
    mapping(address => uint256) public balances;

    // Deposit funds into the bank
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // Function to withdraw partial funds
    function withdrawPartial(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] -= amount;
    }

    // Function to withdraw full balance
    function withdrawFull() external {
        uint256 bal = balances[msg.sender];
        require(bal > 0, "No balance to withdraw");
        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = 0;
    }
}
