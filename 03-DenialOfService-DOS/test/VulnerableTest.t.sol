// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vulnerable.sol";

contract DoSTest is Test {
    Vulnerable public vuln;
    MaliciousReceiver public attacker;

    function setUp() public {
        vuln = new Vulnerable();
        attacker = new MaliciousReceiver();
        vuln.addRecipient(address(attacker));
    }

    function test_DoS_Payment() public {
        vm.expectRevert(bytes("Blocking funds"));
        vuln.payAll{value: 1 ether}();
    }
}
