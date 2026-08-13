// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "../lib/forge-std/src/Script.sol";

import {UserManagement}     from "../src/core/UserManagement.sol";
import {DocumentRegistry}   from "../src/core/DocumentRegistry.sol";
import {Treasury}           from "../src/core/Treasury.sol";
import {OrderManager}       from "../src/core/OrderManager.sol";
import {CropMarketPlace}    from "../src/core/CropMarketplace.sol";
import {ProductMarketplace} from "../src/core/ProductMarketplace.sol";
import {TransactionManager} from "../src/core/TransactionManager.sol";
import {ComplaintRegistry}  from "../src/core/ComplaintRegistry.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title  DeployAndWire
 * @notice Single script that:
 *   1. Deploys all 8 AgriChain contracts fresh from the deployer wallet
 *   2. Registers the deployer as the first admin
 *   3. Wires every contract to every other contract via setter functions
 *   4. Logs and verifies all connections
 *
 * Run:
 *   source .env && forge script script/DeployAndWire.s.sol:DeployAndWire \
 *     --rpc-url "$Sepolia_rpc_url" \
 *     --private-key "$Sepolia_private_key" \
 *     --broadcast \
 *     -vvvv
 *
 * After success, copy the printed addresses into your .env and frontend config.
 */
contract DeployAndWire is Script {

    // Deployed instances — stored so wiring phase can reference them
    UserManagement     um;
    DocumentRegistry   dr;
    Treasury           tre;
    OrderManager       om;
    CropMarketPlace    cm;
    ProductMarketplace pm;
    TransactionManager tm;
    ComplaintRegistry  cr;

    function run() external {

        address deployer  = msg.sender;
        address priceFeed = vm.envAddress("pricefeed");  // Chainlink ETH/USD Sepolia

        console.log("============================================");
        console.log("   AgriChain -- Deploy + Wire Script");
        console.log("============================================");
        console.log("Deployer  :", deployer);
        console.log("PriceFeed :", priceFeed);
        console.log("");

        // ════════════════════════════════════════════════════════
        // PHASE 1 — Deploy all contracts
        // UserManagement is deployed first (no dependencies).
        // All other contracts receive the UM address in constructor.
        // ════════════════════════════════════════════════════════
        console.log("--- Phase 1: Deploying contracts ---");
        vm.startBroadcast();

        // 1. UserManagement — constructor sets deployer as firstAdmin
        um = new UserManagement();
        console.log("UserManagement     :", address(um));

        // 2. DocumentRegistry — depends on UserManagement
        dr = new DocumentRegistry(address(um));
        console.log("DocumentRegistry   :", address(dr));

        // 3. CropMarketplace — depends on UserManagement
        cm = new CropMarketPlace(address(um));
        console.log("CropMarketplace    :", address(cm));

        // 4. ProductMarketplace — depends on UserManagement
        pm = new ProductMarketplace(address(um));
        console.log("ProductMarketplace :", address(pm));

        // 5. OrderManager — depends on UserManagement
        om = new OrderManager(address(um));
        console.log("OrderManager       :", address(om));

        // 6. Treasury — depends on UserManagement
        tre = new Treasury(address(um));
        console.log("Treasury           :", address(tre));

        // 7. TransactionManager — depends on UserManagement
        tm = new TransactionManager(address(um));
        console.log("TransactionManager :", address(tm));

        // 8. ComplaintRegistry — depends on UserManagement
        cr = new ComplaintRegistry(address(um));
        console.log("ComplaintRegistry  :", address(cr));

        vm.stopBroadcast();

        // ════════════════════════════════════════════════════════
        // PHASE 2 — Register deployer as admin
        // UserManagement constructor sets deployer as firstAdmin
        // but does NOT add them to the users[] array.
        // signUpAsAdmin() is gated by onlyFirstAdmin (not onlyAdmin)
        // so it works without being in the array yet.
        // After this tx, deployer is in users[] with ROLE.ADMIN
        // and all onlyAdmin modifiers will pass.
        // ════════════════════════════════════════════════════════
        console.log("");
        console.log("--- Phase 2: Registering deployer as admin ---");
        vm.startBroadcast();

        um.signUpAsAdmin(
            "Deployer Admin",   // name
            "0300-0000000",     // contactNumber
            "00000-0000000-0",  // CNIC
            "Lahore",           // city
            "Pakistan",         // country
            deployer            // wallet address to register
        );
        console.log("Admin registered:", deployer);

        vm.stopBroadcast();

        // ════════════════════════════════════════════════════════
        // PHASE 3 — Wire all contracts together
        // Now deployer is admin so all onlyAdmin setters will pass.
        // ════════════════════════════════════════════════════════
        console.log("");
        console.log("--- Phase 3: Wiring contracts ---");
        vm.startBroadcast();

        // UserManagement → DocumentRegistry
        // Allows DocumentRegistry to call verifyRole / rejectRole
        console.log("[1]  UserManagement    -> setDocumentRegistry");
        um.setDocumentRegistry(address(dr));

        // Treasury → OrderManager
        // Treasury calls makepaid() and completeOrder() on OrderManager
        console.log("[2]  Treasury          -> setOrderManager");
        tre.setOrderManager(address(om));

        // Treasury → TransactionManager
        // Treasury calls addTransaction() after releasing payment
        console.log("[3]  Treasury          -> setTransactionManager");
        tre.setTransactionManager(address(tm));

        // Treasury → Chainlink PriceFeed
        // Used for USD -> ETH conversion in payForOrder()
        console.log("[4]  Treasury          -> setPriceFeed");
        tre.setAggregatorv3InterfacePriceFeed(AggregatorV3Interface(priceFeed));

        // OrderManager → Treasury
        // OrderManager calls release() on Treasury from confirmOrder()
        console.log("[5]  OrderManager      -> setTreasury");
        om.setTreasury(address(tre));

        // OrderManager → ProductMarketplace
        // Reads product price/stock and calls reduce()
        console.log("[6]  OrderManager      -> setProductMarketPlace");
        om.setProductMarketPlace(address(pm));

        // OrderManager → CropMarketplace
        // Reads crop price/stock and calls reduce()
        console.log("[7]  OrderManager      -> setCropMarketPlace");
        om.setCropMarketPlace(address(cm));

        // CropMarketplace → OrderManager
        // reduce() can only be called by OrderManager
        console.log("[8]  CropMarketplace   -> setOrderManager");
        cm.setOrderManager(address(om));

        // CropMarketplace → TransactionManager (future use)
        console.log("[9]  CropMarketplace   -> setTransactionManager");
        cm.setTransactionManager(address(tm));

        // ProductMarketplace → OrderManager
        // reduce() can only be called by OrderManager
        console.log("[10] ProductMarketplace -> setOrderManager");
        pm.setOrderManager(address(om));

        // TransactionManager → Treasury
        // addTransaction() can only be called by Treasury
        console.log("[11] TransactionManager -> setTreasury");
        tm.setTreasury(address(tre));

        vm.stopBroadcast();

        // ════════════════════════════════════════════════════════
        // PHASE 4 — Verify all connections (read-only, no tx)
        // ════════════════════════════════════════════════════════
        console.log("");
        console.log("--- Phase 4: Verification ---");
        console.log("UM    -> DocRegistry    :", um.getDocumentRegistry());
        console.log("TRE   -> OrderMgr       :", tre.getOrderManagementContractAddress());
        console.log("TRE   -> TxMgr          :", tre.getTransactionManagerContractAddress());
        console.log("OM    -> Treasury       :", om.getTreasuryContractAddress());
        console.log("OM    -> ProductMkt     :", om.getProductMarketPlaceAddress());
        console.log("CM    -> OrderMgr       :", cm.getOrderManagerAddress());
        console.log("PM    -> OrderMgr       :", pm.getOrderManagementContractAddress());

        // ════════════════════════════════════════════════════════
        // SUMMARY — Print all addresses to copy into .env
        // ════════════════════════════════════════════════════════
        console.log("");
        console.log("============================================");
        console.log("   Copy these into your .env file:");
        console.log("============================================");
        console.log("userManagementContractAddress=", address(um));
        console.log("documentRegistryContractAddress=", address(dr));
        console.log("cropMarketplaceContractAddress=", address(cm));
        console.log("productMarketplaceContractAddress=", address(pm));
        console.log("orderManagerContractAddress=", address(om));
        console.log("treasuryContractAddress=", address(tre));
        console.log("transectionContractAddress=", address(tm));
        console.log("complaintRegistryAddress=", address(cr));
        console.log("============================================");
        console.log("All done. Contracts deployed and wired.");
    }
}
