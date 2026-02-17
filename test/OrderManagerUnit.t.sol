// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/core/OrderManager.sol";

contract MockProductMarketplace {
    uint256 public price = 1 ether;
    uint256 public units = 100;

    function getProductPrice(uint256) external view returns(uint256) {
        return price;
    }

    function getAvailableUnits(uint256) external view returns(uint256) {
        return units;
    }

    function reduce(uint256, uint256 quantity) external {
        units -= quantity;
    }
}

contract MockTreasury {
    function release(uint256, address payable seller) external {
        seller.transfer(1 ether);
    }
}

contract OrderManagerUnitTest is Test {

    OrderManager orderManager;
    MockProductMarketplace mockPM;
    MockTreasury mockTreasury;

    address admin = address(1);
    address farmer = address(2);
    address shop = address(3);
    address treasuryAddr = address(4);

    function setUp() public {
        vm.startPrank(admin);
        orderManager = new OrderManager(admin);
        mockPM = new MockProductMarketplace();
        mockTreasury = new MockTreasury();

        orderManager.setProductMarketPlace(address(mockPM));
        orderManager.setTreasury(address(mockTreasury));
        vm.stopPrank();
    }

    function testAddOrder() public {
        vm.prank(farmer);

        bool success = orderManager.addOrder(
            farmer,
            shop,
            1,
            5
        );

        assertTrue(success);
        assertEq(orderManager.getOrderNumber(), 1);
    }

    function testMakePaid() public {
        vm.prank(farmer);
        orderManager.addOrder(farmer, shop, 1, 5);

        vm.prank(address(mockTreasury));
        orderManager.makepaid(0);

        // no revert = success
    }
}
