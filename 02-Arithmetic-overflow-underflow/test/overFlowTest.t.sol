// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "forge-std/Test.sol";

import "../src/vulnerableContract.sol";
import "../src/overflowAttacker.sol";

contract OverflowTest is Test {
    VulnerableToken token;
    OverflowAttacker attacker;

    function setUp() public {
        token = new VulnerableToken();
        attacker = new OverflowAttacker(address(token));
    }

    function testUnderflowAttack() public {
        // Initially attacker has 0 balance
        uint256 balanceBefore = token.balances(address(attacker));
        console.log("Before attack: %s", balanceBefore);

        attacker.attack();

        uint256 balanceAfter = token.balances(address(attacker));
        console.log("After attack: %s", balanceAfter);

        assertEq(balanceAfter, balanceBefore);
    }
}
