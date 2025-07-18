// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;
    address user1 = address(0xBEEF);

    function setUp() public {
        token = new MyToken("MyToken", "MTK", 18, 1000);
    }

    function testMintOnlyOwner() public {
        vm.expectRevert("Not the owner");
        vm.prank(user1); // pretend to be user1
        token.mint(user1, 100);
    }

    function testMintByOwner() public {
        token.mint(user1, 500);
        assertEq(token.balance(user1), 500);
    }

    function testBurn() public {
        token.burn(100); // burns from msg.sender (owner)
        assertEq(token.balance(address(this)), 900);
    }

    function testBurnFrom() public {
        token.mint(user1, 1000);
        vm.prank(user1);
        token.Approve(address(this), 500);

        token.burnFrom(user1, 500);
        assertEq(token.balance(user1), 500);
    }
}
