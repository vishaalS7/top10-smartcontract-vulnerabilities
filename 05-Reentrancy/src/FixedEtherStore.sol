// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract FixedEtherStore {
    mapping(address => uint256) public balances;
    bool private locked;

    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public noReentrancy {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        balances[msg.sender] = 0; // Update before sending

        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}