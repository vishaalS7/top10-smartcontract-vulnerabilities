// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {EtherStore, Attack} from "../src/EtherStore.sol";
import {FixedEtherStore} from "../src/FixedEtherStore.sol";

contract ReentrancyTest is Test {
    EtherStore public etherStore;
    FixedEtherStore public fixedEtherStore;
    Attack public attack;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);
        etherStore = new EtherStore();
        fixedEtherStore = new FixedEtherStore();
        vm.stopPrank();

        vm.deal(attacker, 5 ether);
        vm.startPrank(attacker);
        attack = new Attack(address(etherStore));
        vm.stopPrank();
    }

    function testReentrancyAttack() public {
        vm.startPrank(owner);
        etherStore.deposit{value: 5 ether}();
        vm.stopPrank();

        vm.startPrank(attacker);
        attack.attack{value: 1 ether}();
        vm.stopPrank();

        // After attack, EtherStore balance should be less than or equal to 5 ether
        assertLe(etherStore.getBalance(), 5 ether);
        // Attack contract balance should have increased beyond initial deposit
        assertGt(attack.getBalance(), 1 ether);
    }

    function test_AttackOnFixedVersion_NonReentrant() public {
        vm.deal(attacker, 5 ether);

        vm.startPrank(attacker);
        Attack fixedAttack = new Attack(address(fixedEtherStore));

        // Attack on fixed contract does not revert but does not drain funds either
        fixedAttack.attack{value: 1 ether}();
        vm.stopPrank();

        // Fixed contract should hold the 1 ether safely
        assertEq(fixedEtherStore.getBalance(), 1 ether);
        // Attack contract balance remains 0 since no funds drained
        assertEq(fixedAttack.getBalance(), 0);
    }
}
