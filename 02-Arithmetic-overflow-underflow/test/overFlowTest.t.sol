// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";

import "../src/vulnerableContract.sol";

contract TimeLockTest is Test {
    TimeLock public timeLock;
    Attack public attack;

    function setUp() public {
        timeLock = new TimeLock();
        attack = new Attack(timeLock);
        vm.deal(address(attack), 1 ether); // fund the attack contract
    }

    function testAttackSuccess() public {
        uint256 attackerBalanceBefore = address(attack).balance;

        vm.prank(address(attack));
        attack.attack{value: 1 ether}();

        uint256 attackerBalanceAfter = address(attack).balance;

        // Should have received back the 1 ether
        assertEq(attackerBalanceAfter, attackerBalanceBefore);
    }
}
