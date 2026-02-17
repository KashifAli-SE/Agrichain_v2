// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/core/OrderManager.sol";
import "../src/core/Treasury.sol";

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

contract IntegrationTest is Test {

    OrderManager orderManager;
    Treasury treasury;
    MockProductMarketplace mockPM;

    address admin = address(1);
    address farmer = address(2);
    address seller = address(3);

    function setUp() public {
        vm.startPrank(admin);

        orderManager = new OrderManager(admin);
        treasury = new Treasury(admin);
        mockPM = new MockProductMarketplace();

        orderManager.setProductMarketPlace(address(mockPM));
        orderManager.setTreasury(address(treasury));

        treasury.setOrderManager(address(orderManager));

        vm.stopPrank();

        vm.deal(farmer, 10 ether);
    }

    function testFullFlow() public {

        // Step 1: Create Order
        vm.prank(farmer);
        orderManager.addOrder(farmer, seller, 1, 2);

        // Step 2: Pay
        vm.prank(farmer);
        treasury.payForOrder{value: 2 ether}(0);

        // Step 3: Confirm
        vm.prank(farmer);
        orderManager.confirmOrder(0);

        // Seller should receive funds
        assertEq(seller.balance, 2 ether);
    }
}
