// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {EtherStore, Attack} from "../src/EtherStore.sol";

contract EtherStoreTest is Test {
    EtherStore public etherStore;
    Attack public attack;

    // Setup before each test
    function setUp() public {
        etherStore = new EtherStore();
        // Send 5 ether to EtherStore so it has funds to steal
        vm.deal(address(this), 10 ether);
        etherStore.deposit{value: 5 ether}();

        // Deploy attack contract
        attack = new Attack(address(etherStore));
    }

    function testAttack() public {
        // Make sure attack contract starts with no balance
        assertEq(address(attack).balance, 0);

        // Run the attack: send 1 ether to Attack
        attack.attack{value: 1 ether}();

        // After attack, attack contract should have drained EtherStore
        emit log_named_uint("EtherStore balance", etherStore.getBalance());
        emit log_named_uint("Attack contract balance", attack.getBalance());

        // EtherStore should be (almost) empty
        assertEq(etherStore.getBalance(), 0);
        // Attacker should have received all ether (~6 ether)
        assertGt(attack.getBalance(), 5 ether);
    }

    // Let test contract receive ETH
    receive() external payable {}
}
