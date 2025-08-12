// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
This contract allows users to deposit and withdraw Ether.
The withdraw function is vulnerable to reentrancy because
it sends Ether before updating the user’s balance.
*/

contract VulnerableWallet {
    mapping(address => uint256) public balances;

    // Deposit Ether into your account
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /*
    Withdraw function vulnerable to reentrancy:

    1. Checks that sender has enough balance.
    2. Sends Ether to sender using call.
    3. Updates balance AFTER sending Ether.

    Problem: The external call (step 2) can trigger
    attacker’s fallback function, which calls withdraw()
    again before the balance is updated (step 3).
    */
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Step 2: Send Ether before balance update
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");

        // Step 3: Update balance after sending Ether — vulnerable!
        balances[msg.sender] -= amount;
    }
}
