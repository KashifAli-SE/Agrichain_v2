// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {UserManagement}     from "../src/core/UserManagement.sol";
import {Treasury}           from "../src/core/Treasury.sol";
import {OrderManager}       from "../src/core/OrderManager.sol";
import {CropMarketPlace}    from "../src/core/CropMarketplace.sol";
import {ProductMarketplace} from "../src/core/ProductMarketplace.sol";
import {TransactionManager} from "../src/core/TransactionManager.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract wireContracts is Script {
    function run() external {
        address umAddr  = vm.envAddress("userManagementContractAddress");
        address drAddr  = vm.envAddress("documentRegistryContractAddress");
        address pmAddr  = vm.envAddress("productMarketplaceContractAddress");
        address cmAddr  = vm.envAddress("cropMarketplaceContractAddress");
        address omAddr  = vm.envAddress("orderManagerContractAddress");
        address treAddr = vm.envAddress("treasuryContractAddress");
        address tmAddr  = vm.envAddress("transectionContractAddress");
        address pfAddr  = vm.envAddress("pricefeed");

        console.log("Deployer:", msg.sender);

        UserManagement     um  = UserManagement(umAddr);
        Treasury           tre = Treasury(payable(treAddr));
        OrderManager       om  = OrderManager(omAddr);
        CropMarketPlace    cm  = CropMarketPlace(cmAddr);
        ProductMarketplace pm  = ProductMarketplace(pmAddr);
        TransactionManager tm  = TransactionManager(tmAddr);

        vm.startBroadcast();

        console.log("[1]  UM            -> setDocumentRegistry");
        um.setDocumentRegistry(drAddr);

        console.log("[2]  Treasury      -> setOrderManager");
        tre.setOrderManager(omAddr);

        console.log("[3]  Treasury      -> setTransactionManager");
        tre.setTransactionManager(tmAddr);

        console.log("[4]  Treasury      -> setPriceFeed");
        tre.setAggregatorv3InterfacePriceFeed(AggregatorV3Interface(pfAddr));

        console.log("[5]  OrderManager  -> setTreasury");
        om.setTreasury(treAddr);

        console.log("[6]  OrderManager  -> setProductMarketPlace");
        om.setProductMarketPlace(pmAddr);

        console.log("[7]  OrderManager  -> setCropMarketPlace");
        om.setCropMarketPlace(cmAddr);

        console.log("[8]  CropMarket    -> setOrderManager");
        cm.setOrderManager(omAddr);

        console.log("[9]  CropMarket    -> setTransactionManager");
        cm.setTransactionManager(tmAddr);

        console.log("[10] ProductMarket -> setOrderManager");
        pm.setOrderManager(omAddr);

        console.log("[11] TxManager     -> setTreasury");
        tm.setTreasury(treAddr);

        vm.stopBroadcast();

        console.log("");
        console.log("=== Verification ===");
        console.log("UM -> DocRegistry    :", um.getDocumentRegistry());
        console.log("Treasury -> OrderMgr :", tre.getOrderManagementContractAddress());
        console.log("Treasury -> TxMgr    :", tre.getTransactionManagerContractAddress());
        console.log("OrderMgr -> Treasury :", om.getTreasuryContractAddress());
        console.log("OrderMgr -> ProdMkt  :", om.getProductMarketPlaceAddress());
        console.log("CropMkt  -> OrderMgr :", cm.getOrderManagerAddress());
        console.log("ProdMkt  -> OrderMgr :", pm.getOrderManagementContractAddress());
        console.log("Done.");
    }
}
