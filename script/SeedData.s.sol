// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "../lib/forge-std/src/Script.sol";

import {UserManagement}    from "../src/core/UserManagement.sol";
import {IUserManagement}   from "../src/interfaces/IUserManagement.sol";
import {CropMarketPlace}    from "../src/core/CropMarketplace.sol";
import {ProductMarketplace} from "../src/core/ProductMarketplace.sol";
import {OrderManager}       from "../src/core/OrderManager.sol";
import {Treasury}           from "../src/core/Treasury.sol";
import {ICropMarketplace}   from "../src/interfaces/ICropMarketplace.sol";
import {IProductMarketplace} from "../src/interfaces/IProductMarketplace.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "../src/libraries/PriceConverter.sol";

/**
 * @title  SeedData
 * @notice Populates AgriChain with demo crops, products and paid orders.
 *         Farmer, Shopkeeper and Buyer are already registered and verified.
 *
 * Run:
 *   source .env && forge script script/SeedData.s.sol:SeedData \
 *     --rpc-url "$Sepolia_rpc_url" \
 *     --private-key "$Sepolia_private_key" \
 *     --broadcast -vvvv
 */
contract SeedData is Script {
    using PriceConverter for uint256;

    function run() external {
        // ── Load contracts ────────────────────────────────────
        UserManagement     um  = UserManagement(vm.envAddress("userManagementContractAddress"));
        CropMarketPlace    cm  = CropMarketPlace(vm.envAddress("cropMarketplaceContractAddress"));
        ProductMarketplace pm  = ProductMarketplace(vm.envAddress("productMarketplaceContractAddress"));
        OrderManager       om  = OrderManager(vm.envAddress("orderManagerContractAddress"));
        Treasury           tre = Treasury(payable(vm.envAddress("treasuryContractAddress")));

        // ── Load keys ─────────────────────────────────────────
        uint256 deployerKey = vm.envUint("Sepolia_private_key");
        uint256 farmerKey   = vm.envUint("Farmer_key");
        uint256 shopKey     = vm.envUint("Shopkeeper_key");
        uint256 buyerKey    = vm.envUint("Buyer_key");

        address farmerAddr = vm.addr(farmerKey);
        address shopAddr   = vm.addr(shopKey);
        address buyerAddr  = vm.addr(buyerKey);

        console.log("Farmer     :", farmerAddr);
        console.log("Shopkeeper :", shopAddr);
        console.log("Buyer      :", buyerAddr);

        // ════════════════════════════════════════════
        // PHASE 0 — Register missing users on new UM
        // signUpAsAdmin gives ADMIN role — wrong.
        // Instead: each user calls signUp with their
        // own role, then deployer verifies them.
        // ════════════════════════════════════════════
        console.log("\n--- Phase 0: Registering missing users ---");

        // Register shopkeeper (must call signUp from their own key)
        if (!um.isActiveUser(shopAddr) || !um.isShop(shopAddr)) {
            // If registered with wrong role (ADMIN from prev run), need fresh account
            // Since deployer registered them as admin previously, delete and re-register
            if (um.isActiveUser(shopAddr)) {
                vm.startBroadcast(shopKey);
                um.deleteAccount();
                vm.stopBroadcast();
            }
            vm.startBroadcast(shopKey);
            um.signUp("Tariq Agri Store", IUserManagement.ROLE.SHOPKEEPER,
                "0321-9876543", "35202-9876543-1", "Lahore", "Pakistan");
            vm.stopBroadcast();
            console.log("  Shopkeeper registered.");
        } else {
            console.log("  Shopkeeper already registered.");
        }

        // Register buyer (must call signUp from their own key)
        if (!um.isActiveUser(buyerAddr) || !um.isBuyer(buyerAddr)) {
            if (um.isActiveUser(buyerAddr)) {
                vm.startBroadcast(buyerKey);
                um.deleteAccount();
                vm.stopBroadcast();
            }
            vm.startBroadcast(buyerKey);
            um.signUp("Bilal Traders", IUserManagement.ROLE.BUYER,
                "0311-5556677", "61101-5556677-9", "Karachi", "Pakistan");
            vm.stopBroadcast();
            console.log("  Buyer registered.");
        } else {
            console.log("  Buyer already registered.");
        }

        // Deployer verifies both (firstAdmin can call verifyRole directly)
        vm.startBroadcast(deployerKey);
        if (!um.isVerified(shopAddr)) {
            um.appliedForVerification(shopAddr);
            um.verifyRole(shopAddr);
            console.log("  Shopkeeper verified.");
        }
        if (!um.isVerified(buyerAddr)) {
            um.appliedForVerification(buyerAddr);
            um.verifyRole(buyerAddr);
            console.log("  Buyer verified.");
        }
        vm.stopBroadcast();

        // ════════════════════════════════════════════
        // PHASE 1 — Farmer lists 10 crops
        // UNIT enum: 1=KG  2=TONN  3=DOZEN
        // addCrop(name, type, stock, unit, pricePerUnit, location, ipfsHash)
        // ════════════════════════════════════════════
        vm.startBroadcast(farmerKey);
        console.log("\n--- Phase 1: Listing crops ---");

        cm.addCrop("Basmati Rice (Extra Long Grain)",      "Kharif Cereal",    5000, ICropMarketplace.UNIT.KG, 8,   "Sheikhupura, Punjab",         "bafkreiaze7cpjxjlnuo27vrhd4wmhncur4cgkezont3flnnfw3c4puorpa");
        cm.addCrop("Sindhi Sugarcane (CPF-237 Variety)",   "Cash Crop",        8000, ICropMarketplace.UNIT.KG, 3,   "Mirpur Khas, Sindh",          "bafkreif5puvylst6d57dui7o2nezzpv3v2s4yk3c47cypndmgqubfsp6wi");
        cm.addCrop("Desi White Corn (Maize)",              "Kharif Cereal",    3000, ICropMarketplace.UNIT.KG, 5,   "Sahiwal, Punjab",             "bafkreiehzqoxpx75zutcbay5s2mnkykqeicjlqyn66vxkqfbclvae5ztzi");
        cm.addCrop("Chaunsa Mangoes (Premium Grade A)",    "Summer Fruit",     1200, ICropMarketplace.UNIT.KG, 120, "Multan, Punjab",              "bafkreiefpojhyx2a5cwkwi4gpv3k6kzst5nbgqw4dd4pmgpe7gotkiuca");
        cm.addCrop("Aseel Dates (Grade A Dry)",            "Date Palm",        2000, ICropMarketplace.UNIT.KG, 95,  "Khairpur, Sindh",             "bafkreid4bg2uzpmxxdyu4yiy4cndbxm2sepm3klwbxf43bhei73yxa3evu");
        cm.addCrop("Red Onions (Medium Bulb)",             "Rabi Vegetable",   4500, ICropMarketplace.UNIT.KG, 12,  "Khushab, Punjab",             "bafkreig3avgqtulk4g4gna4nug3pgacza3r6cntaoanm6mc7v5kqgqp6h4");
        cm.addCrop("Kinnow Oranges (Grade A)",             "Citrus Fruit",     3500, ICropMarketplace.UNIT.KG, 45,  "Sargodha, Punjab",            "bafkreidjsd4byym3mtxfgaobs4majhob6vtrh4ob3aumiznhkihixipeki");
        cm.addCrop("Diamond Potatoes (Washed)",            "Rabi Vegetable",   6000, ICropMarketplace.UNIT.KG, 18,  "Okara, Punjab",               "bafkreifbbffv65t77qifsavodiuqqhdmpv23rk3bj3aqnubnuabcbq4esa");
        cm.addCrop("Roma Tomatoes (Vine Ripened)",         "Summer Vegetable", 2500, ICropMarketplace.UNIT.KG, 22,  "Tando Allahyar, Sindh",       "bafkreibqfc5lwt2fyilu3lmnr4lgcrxnxxhyq5qhofwon4igamqjqbcq");
        cm.addCrop("Sugar Baby Watermelon",                "Summer Fruit",     3000, ICropMarketplace.UNIT.KG, 15,  "Rahim Yar Khan, Punjab",      "bafkreig4ctjvam6qaukttdeozq6abx4dnd3x77ndhdhkutj37n6mgsona");

        vm.stopBroadcast();
        console.log("10 crops listed.");

        // ════════════════════════════════════════════
        // PHASE 2 — Shopkeeper lists 11 products
        // PRODUCTTYPE: 1=Fertilizer  2=Seed  3=Pesticides
        // listProduct(name, type, availableUnits, pricePerUnit, ipfsHash)
        // ════════════════════════════════════════════
        vm.startBroadcast(shopKey);
        console.log("\n--- Phase 2: Listing products ---");

        pm.listProduct("Urea Fertilizer 46% N (50kg bag)",            IProductMarketplace.PRODUCTTYPE.Fertilizer, 500,  28,    "bafkreiev4yrocu6dmy4hh4tsyvdznnlhqtxcrqvhl6pog4zb7qxnhnzium");
        pm.listProduct("DAP Fertilizer (Diammonium Phosphate, 50kg)", IProductMarketplace.PRODUCTTYPE.Fertilizer, 400,  55,    "bafkreidlfryrvfpf7o2knjvlsl4mk6jxultrh56h2sf4vkwoz7i2x6ij6m");
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

        // ════════════════════════════════════════════
        // PHASE 3 — Buyer places 3 orders on crops
        // Use current cropCounter to find last 3 crops
        // ════════════════════════════════════════════
        vm.startBroadcast(buyerKey);
        console.log("\n--- Phase 3: Buyer places orders ---");

        // cropCounter points to NEXT id, so last 3 listed = counter-3, counter-2, counter-1
        uint256 cropCount = cm.cropCounter();
        uint256 cid1 = cropCount - 10; // Basmati Rice (1st listed this run)
        uint256 cid2 = cropCount - 7;  // Chaunsa Mangoes (4th listed = rice,cane,corn,mangoes)
        uint256 cid3 = cropCount - 5;  // Red Onions (6th listed)

        console.log("Ordering crop IDs:", cid1, cid2, cid3);

        om.addOrder(cid1, 100);  // 100 KG Basmati Rice
        om.addOrder(cid2, 20);   // 20  KG Chaunsa Mangoes
        om.addOrder(cid3, 150);  // 150 KG Red Onions

        vm.stopBroadcast();
        console.log("3 orders placed.");

    }
}
