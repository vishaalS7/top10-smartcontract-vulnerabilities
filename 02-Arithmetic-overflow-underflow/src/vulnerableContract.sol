pragma solidity ^0.7.0;

contract VulnerableToken {
    mapping(address => uint256) public balances;

    constructor() public {
        balances[msg.sender] = 100;
    }

    function transfer(address to, uint256 amount) public {
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
