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
import {IUserManagement}    from "../src/interfaces/IUserManagement.sol";
import {ICropMarketplace}   from "../src/interfaces/ICropMarketplace.sol";
import {IProductMarketplace} from "../src/interfaces/IProductMarketplace.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "../src/libraries/PriceConverter.sol";

/**
 * @title  FullDeploy
 * @notice ONE script that does everything:
 *   1. Deploy all 8 contracts fresh
 *   2. Register deployer as admin
 *   3. Wire all contracts together
 *   4. Register farmer, shopkeeper, buyer with correct roles
 *   5. Verify all three actors
 *   6. Farmer lists 10 crops
 *   7. Shopkeeper lists 11 products
 *   8. Buyer places 3 orders and pays
 *
 * Run:
 *   forge script script/FullDeploy.s.sol:FullDeploy \
 *     --rpc-url "https://eth-sepolia.g.alchemy.com/v2/kyPmAKub4bjXT3m84Hzt-" \
 *     --private-key "0x898a..." \
 *     --broadcast -vvvv
 *
 * After success: update .env and frontend/src/config/contracts.ts
 * with the printed addresses.
 */
contract FullDeploy is Script {
    using PriceConverter for uint256;

    // Contract instances
    UserManagement     um;
    DocumentRegistry   dr;
    Treasury           tre;
    OrderManager       om;
    CropMarketPlace    cm;
    ProductMarketplace pm;
    TransactionManager tm;
    ComplaintRegistry  cr;

    function run() external {
        uint256 deployerKey = vm.envUint("Sepolia_private_key");
        uint256 farmerKey   = vm.envUint("Farmer_key");
        uint256 shopKey     = vm.envUint("Shopkeeper_key");
        uint256 buyerKey    = vm.envUint("Buyer_key");
        address priceFeed   = vm.envAddress("pricefeed");

        address deployer   = vm.addr(deployerKey);
        address farmerAddr = vm.addr(farmerKey);
        address shopAddr   = vm.addr(shopKey);
        address buyerAddr  = vm.addr(buyerKey);

        console.log("Deployer   :", deployer);
        console.log("Farmer     :", farmerAddr);
        console.log("Shopkeeper :", shopAddr);
        console.log("Buyer      :", buyerAddr);

        // ════════════════════════════════════════════════════
        // PHASE 1 — Deploy all contracts
        // ════════════════════════════════════════════════════
        console.log("\n--- Phase 1: Deploying contracts ---");
        vm.startBroadcast(deployerKey);

        um  = new UserManagement();
        dr  = new DocumentRegistry(address(um));
        cm  = new CropMarketPlace(address(um));
        pm  = new ProductMarketplace(address(um));
        om  = new OrderManager(address(um));
        tre = new Treasury(address(um));
        tm  = new TransactionManager(address(um));
        cr  = new ComplaintRegistry(address(um));

        vm.stopBroadcast();

        console.log("UserManagement    :", address(um));
        console.log("DocumentRegistry  :", address(dr));
        console.log("CropMarketplace   :", address(cm));
        console.log("ProductMarketplace:", address(pm));
        console.log("OrderManager      :", address(om));
        console.log("Treasury          :", address(tre));
        console.log("TransactionManager:", address(tm));
        console.log("ComplaintRegistry :", address(cr));

        // ════════════════════════════════════════════════════
        // PHASE 2 — Register deployer as admin
        // (constructor sets firstAdmin but NOT users array)
        // ════════════════════════════════════════════════════
        console.log("\n--- Phase 2: Registering deployer as admin ---");
        vm.startBroadcast(deployerKey);
        um.signUpAsAdmin("Platform Admin", "0300-0000000", "00000-0000000-0",
                         "Lahore", "Pakistan", deployer);
        vm.stopBroadcast();

        // ════════════════════════════════════════════════════
        // PHASE 3 — Wire all contracts
        // ════════════════════════════════════════════════════
        console.log("\n--- Phase 3: Wiring contracts ---");
        vm.startBroadcast(deployerKey);

        um.setDocumentRegistry(address(dr));
        tre.setOrderManager(address(om));
        tre.setTransactionManager(address(tm));
        tre.setAggregatorv3InterfacePriceFeed(AggregatorV3Interface(priceFeed));
        om.setTreasury(address(tre));
        om.setProductMarketPlace(address(pm));
        om.setCropMarketPlace(address(cm));
        cm.setOrderManager(address(om));
        cm.setTransactionManager(address(tm));
        pm.setOrderManager(address(om));
        tm.setTreasury(address(tre));

        vm.stopBroadcast();
        console.log("All contracts wired.");

        // ════════════════════════════════════════════════════
        // PHASE 4 — Register farmer, shopkeeper, buyer
        // Each must sign up with their own key + correct role
        // ════════════════════════════════════════════════════
        console.log("\n--- Phase 4: Registering actors ---");

        vm.startBroadcast(farmerKey);
        um.signUp("Ahmed Raza", IUserManagement.ROLE.FARMER,
                  "0301-2345678", "42101-1234567-3", "Faisalabad", "Pakistan");
        vm.stopBroadcast();

        vm.startBroadcast(shopKey);
        um.signUp("Tariq Agri Store", IUserManagement.ROLE.SHOPKEEPER,
                  "0321-9876543", "35202-9876543-1", "Lahore", "Pakistan");
        vm.stopBroadcast();

        vm.startBroadcast(buyerKey);
        um.signUp("Bilal Traders", IUserManagement.ROLE.BUYER,
                  "0311-5556677", "61101-5556677-9", "Karachi", "Pakistan");
        vm.stopBroadcast();

        // ════════════════════════════════════════════════════
        // PHASE 5 — Verify all three actors (deployer = firstAdmin)
        // ════════════════════════════════════════════════════
        console.log("\n--- Phase 5: Verifying actors ---");
        vm.startBroadcast(deployerKey);

        um.appliedForVerification(farmerAddr);
        um.verifyRole(farmerAddr);

        um.appliedForVerification(shopAddr);
        um.verifyRole(shopAddr);

        um.appliedForVerification(buyerAddr);
        um.verifyRole(buyerAddr);

        vm.stopBroadcast();
        console.log("Farmer, Shopkeeper, Buyer verified.");

        // ════════════════════════════════════════════════════
        // PHASE 6 — Farmer lists 10 crops
        // UNIT: 1=KG
        // ════════════════════════════════════════════════════
        console.log("\n--- Phase 6: Farmer lists crops ---");
        vm.startBroadcast(farmerKey);

        cm.addCrop("Basmati Rice (Extra Long Grain)",    "Kharif Cereal",    5000, ICropMarketplace.UNIT.KG, 8,   "Sheikhupura, Punjab",       "bafkreiaze7cpjxjlnuo27vrhd4wmhncur4cgkezont3flnnfw3c4puorpa");
        cm.addCrop("Sindhi Sugarcane (CPF-237 Variety)", "Cash Crop",        8000, ICropMarketplace.UNIT.KG, 3,   "Mirpur Khas, Sindh",        "bafkreif5puvylst6d57dui7o2nezzpv3v2s4yk3c47cypndmgqubfsp6wi");
        cm.addCrop("Desi White Corn (Maize)",            "Kharif Cereal",    3000, ICropMarketplace.UNIT.KG, 5,   "Sahiwal, Punjab",           "bafkreiehzqoxpx75zutcbay5s2mnkykqeicjlqyn66vxkqfbclvae5ztzi");
        cm.addCrop("Chaunsa Mangoes (Premium Grade A)",  "Summer Fruit",     1200, ICropMarketplace.UNIT.KG, 120, "Multan, Punjab",            "bafkreiefpojhyx2a5cwkwi4gpv3k6kzst5nbgqw4dd4pmgpe7gotkiuca");
        cm.addCrop("Aseel Dates (Grade A Dry)",          "Date Palm",        2000, ICropMarketplace.UNIT.KG, 95,  "Khairpur, Sindh",           "bafkreid4bg2uzpmxxdyu4yiy4cndbxm2sepm3klwbxf43bhei73yxa3evu");
        cm.addCrop("Red Onions (Medium Bulb)",           "Rabi Vegetable",   4500, ICropMarketplace.UNIT.KG, 12,  "Khushab, Punjab",           "bafkreig3avgqtulk4g4gna4nug3pgacza3r6cntaoanm6mc7v5kqgqp6h4");
        cm.addCrop("Kinnow Oranges (Grade A)",           "Citrus Fruit",     3500, ICropMarketplace.UNIT.KG, 45,  "Sargodha, Punjab",          "bafkreidjsd4byym3mtxfgaobs4majhob6vtrh4ob3aumiznhkihixipeki");
        cm.addCrop("Diamond Potatoes (Washed)",          "Rabi Vegetable",   6000, ICropMarketplace.UNIT.KG, 18,  "Okara, Punjab",             "bafkreifbbffv65t77qifsavodiuqqhdmpv23rk3bj3aqnubnuabcbq4esa");
        cm.addCrop("Roma Tomatoes (Vine Ripened)",       "Summer Vegetable", 2500, ICropMarketplace.UNIT.KG, 22,  "Tando Allahyar, Sindh",    "bafkreibqfc5lwt2fyilu3lmnr4lgcrxnxxhyq5qhofwon4igamqjqbcq");
        cm.addCrop("Sugar Baby Watermelon",              "Summer Fruit",     3000, ICropMarketplace.UNIT.KG, 15,  "Rahim Yar Khan, Punjab",   "bafkreig4ctjvam6qaukttdeozq6abx4dnd3x77ndhdhkutj37n6mgsona");

        vm.stopBroadcast();
        console.log("10 crops listed.");

        // ════════════════════════════════════════════════════
        // PHASE 7 — Shopkeeper lists 11 products
        // TYPE: 1=Fertilizer 2=Seed 3=Pesticides
        // ════════════════════════════════════════════════════
        console.log("\n--- Phase 7: Shopkeeper lists products ---");
        vm.startBroadcast(shopKey);

        pm.listProduct("Urea Fertilizer 46% N (50kg bag)",            IProductMarketplace.PRODUCTTYPE.Fertilizer, 500,  28,    "bafkreiev4yrocu6dmy4hh4tsyvdznnlhqtxcrqvhl6pog4zb7qxnhnzium");
        pm.listProduct("DAP Fertilizer (Diammonium Phosphate 50kg)",  IProductMarketplace.PRODUCTTYPE.Fertilizer, 400,  55,    "bafkreidlfryrvfpf7o2knjvlsl4mk6jxultrh56h2sf4vkwoz7i2x6ij6m");
        pm.listProduct("MAP Fertilizer (Monoammonium Phosphate 50kg)",IProductMarketplace.PRODUCTTYPE.Fertilizer, 300,  48,    "bafkreiea2w57nk44mk23b7rheadco5pzr5kqdegzi2rhnyyqmwt2maec3e");
        pm.listProduct("MOP - Muriate of Potash KCl (50kg bag)",      IProductMarketplace.PRODUCTTYPE.Fertilizer, 250,  42,    "bafkreifmkhvcnxgd43s4breytk7umzgn54xqfy3lytf6riinoywi6crapu");
        pm.listProduct("Hybrid Basmati Rice Seeds (Certified 10kg)",  IProductMarketplace.PRODUCTTYPE.Seed,       1000, 12,    "bafkreig6x2uixqw3mk3yfsn2d4mtgisugdklvzanezd4ug65aonecvy56y");
        pm.listProduct("Premium Wheat Seeds Pak-81 (10kg)",           IProductMarketplace.PRODUCTTYPE.Seed,       800,  9,     "bafkreic7gt37cdrurhghojhghynibawzuijz2cwm6coor15gkp3ghc7avm");
        pm.listProduct("Chlorpyrifos 40% EC Insecticide (1 Litre)",   IProductMarketplace.PRODUCTTYPE.Pesticides, 600,  18,    "bafkreigwhoegmkqqk7iw7v6cagejzcsvcee3tcjtfqavadnrawzia5t5qi");
        pm.listProduct("Glyphosate 41% SL Herbicide (1 Litre)",       IProductMarketplace.PRODUCTTYPE.Pesticides, 500,  15,    "bafkreidsbe2ts3kns4jr5q2ygwc2aazeijx5v4xhlx13asxpsj254iq7ua");
        pm.listProduct("Paraquat 20% SL Contact Herbicide (1 Litre)", IProductMarketplace.PRODUCTTYPE.Pesticides, 400,  20,    "bafkreicptaxndrwpwakzkdjkg7cvdz75bk3v5uxa45lih3tciqyudl6pzm");
        pm.listProduct("Drip Irrigation Kit (1 Acre Coverage)",       IProductMarketplace.PRODUCTTYPE.Seed,       50,   380,   "bafkreiagofvw3bakxvzqldm5thcc2cf4jzczrvgtvxc3jrqyb33gsjvara");
        pm.listProduct("Massey Ferguson MF-240 Tractor (75 HP)",      IProductMarketplace.PRODUCTTYPE.Fertilizer, 5,    18500, "bafkreidv4e5jrckyalohegeplcf7dkhwrqqwae7jsm2bqc6v5qmpphvcwu");

        vm.stopBroadcast();
        console.log("11 products listed.");

        // ════════════════════════════════════════════════════
        // PHASE 8 — Buyer places 3 orders
        // Crop IDs: 1=Rice, 4=Mangoes, 6=Onions
        // (cropCounter starts at 1 in fresh deployment)
        // ════════════════════════════════════════════════════
        console.log("\n--- Phase 8: Buyer places orders ---");
        vm.startBroadcast(buyerKey);
        om.addOrder(1, 100);  // 100 KG Basmati Rice   @ $8   = $800
        om.addOrder(4, 20);   // 20  KG Chaunsa Mangoes @ $120 = $2400
        om.addOrder(6, 150);  // 150 KG Red Onions      @ $12  = $1800
        vm.stopBroadcast();
        console.log("3 orders placed.");

    }
}
