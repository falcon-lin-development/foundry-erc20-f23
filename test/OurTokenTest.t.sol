// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OutTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        // transferFrom
        uint256 initialAllowance = 1000;

        // bob approves alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferExceedingBalance() public {
        address recipient = address(0x456);
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;

        vm.expectRevert();
        ourToken.transfer(recipient, amount);
    }

    function testTransferFromExceedingAllowance() public {
        address sender = address(this);
        address recipient = address(0x789);
        address spender = address(0x123);
        uint256 amount = 100;
        uint256 allowanceAmount = 50;

        ourToken.approve(spender, allowanceAmount);
        vm.prank(spender);
        vm.expectRevert();
        ourToken.transferFrom(sender, recipient, amount);
    }
}
