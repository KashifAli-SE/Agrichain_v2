// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/core/ProductMarketplace.sol";

contract ProductMarketplaceTest is Test {

    ProductMarketplace marketplace;

    address admin = address(1);
    address shop = address(2);
    address orderManager = address(3);

    function setUp() public {
        vm.startPrank(admin);

        // deploy marketplace
        marketplace = new ProductMarketplace(admin);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                            LIST PRODUCT
    //////////////////////////////////////////////////////////////*/

    function testListProduct() public {

        vm.prank(shop);

        bool success = marketplace.listProduct(
            "Wheat",
            IProductMarketplace.PRODUCTTYPE.CROP,
            100,
            1 ether
        );

        assertTrue(success);
        assertEq(marketplace.productCounter(), 1);
        assertEq(marketplace.getProductPrice(0), 1 ether);
        assertEq(marketplace.getAvailableUnits(0), 100);
    }

    /*//////////////////////////////////////////////////////////////
                            UPDATE PRODUCT
    //////////////////////////////////////////////////////////////*/

    function testUpdateProduct() public {

        vm.startPrank(shop);

        marketplace.listProduct(
            "Rice",
            IProductMarketplace.PRODUCTTYPE.CROP,
            50,
            2 ether
        );

        marketplace.updateProduct(0, 3 ether, 40);

        vm.stopPrank();

        assertEq(marketplace.getProductPrice(0), 3 ether);
        assertEq(marketplace.getAvailableUnits(0), 40);
    }

    /*//////////////////////////////////////////////////////////////
                            REMOVE PRODUCT
    //////////////////////////////////////////////////////////////*/

    function testRemoveProduct() public {

        vm.startPrank(shop);

        marketplace.listProduct(
            "Corn",
            IProductMarketplace.PRODUCTTYPE.CROP,
            200,
            5 ether
        );

        marketplace.removeProduct(0);

        vm.stopPrank();

        uint256 units = marketplace.getAvailableUnits(0);
        assertEq(units, 0);
    }

    /*//////////////////////////////////////////////////////////////
                            REDUCE STOCK
    //////////////////////////////////////////////////////////////*/

    function testReduceStock() public {

        vm.startPrank(shop);

        marketplace.listProduct(
            "Barley",
            IProductMarketplace.PRODUCTTYPE.CROP,
            100,
            1 ether
        );

        vm.stopPrank();

        // set order manager
        vm.prank(admin);
        marketplace.setOrderManager(orderManager);

        vm.prank(orderManager);
        marketplace.reduce(0, 20);

        assertEq(marketplace.getAvailableUnits(0), 80);
    }

    /*//////////////////////////////////////////////////////////////
                            FAIL TESTS
    //////////////////////////////////////////////////////////////*/

    function testFailReduceByNonOrderManager() public {

        vm.startPrank(shop);

        marketplace.listProduct(
            "Sugar",
            IProductMarketplace.PRODUCTTYPE.CROP,
            100,
            1 ether
        );

        vm.stopPrank();

        vm.prank(shop);
        marketplace.reduce(0, 10); // should fail
    }

    function testFailRemoveNonExistingProduct() public {

        vm.prank(shop);
        marketplace.removeProduct(99); // should revert
    }

    
}
