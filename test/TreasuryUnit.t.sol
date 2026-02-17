// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/core/Treasury.sol";

contract TreasuryUnitTest is Test {

    Treasury treasury;

    address admin = address(1);
    address farmer = address(2);
    address orderManager = address(3);
    address seller = address(4);

    function setUp() public {
        vm.startPrank(admin);
        treasury = new Treasury(admin);
        treasury.setOrderManager(orderManager);
        vm.stopPrank();

        vm.deal(farmer, 10 ether);
    }

    function testPayForOrderStoresFunds() public {
        vm.prank(farmer);
        treasury.payForOrder{value: 1 ether}(1);

        assertEq(address(treasury).balance, 1 ether);
    }

    function testReleaseTransfersFunds() public {
        vm.prank(farmer);
        treasury.payForOrder{value: 2 ether}(1);

        vm.prank(orderManager);
        treasury.release(1, payable(seller));

        assertEq(seller.balance, 2 ether);
    }

    function testFailReleaseNotOrderManager() public {
        vm.prank(farmer);
        treasury.payForOrder{value: 1 ether}(1);

        vm.prank(farmer);
        treasury.release(1, payable(seller)); // should fail
    }
}
