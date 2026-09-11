// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {OrderManager}  from "../src/core/OrderManager.sol";
import {Treasury}      from "../src/core/Treasury.sol";
import {PriceConverter} from "../src/libraries/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title  SeedOrders
 * @notice Places and pays for 3 sample orders after wireContracts is done.
 *         Run this AFTER wireContracts.s.sol succeeds.
 *
 * Run:
 *   source .env && forge script script/SeedOrders.s.sol:SeedOrders \
 *     --rpc-url "$Sepolia_rpc_url" \
 *     --private-key "$Sepolia_private_key" \
 *     --broadcast -vvvv
 */
contract SeedOrders is Script {
    using PriceConverter for uint256;

    function run() external {
        OrderManager om  = OrderManager(vm.envAddress("orderManagerContractAddress"));
        Treasury     tre = Treasury(payable(vm.envAddress("treasuryContractAddress")));
        uint256 buyerKey = vm.envUint("Buyer_key");

        // ── Phase 1: Place orders ─────────────────────────────
        // Crop IDs from SeedData: 1=Rice, 4=Mangoes, 6=Red Onions
        vm.startBroadcast(buyerKey);
        console.log("Placing 3 orders...");
        om.addOrder(1, 100);  // 100 KG Basmati Rice   @ $8   = $800
        om.addOrder(4, 20);   // 20  KG Chaunsa Mangoes @ $120 = $2400
        om.addOrder(6, 150);  // 150 KG Red Onions      @ $12  = $1800
        vm.stopBroadcast();

        // ── Phase 2: Pay orders ───────────────────────────────
        AggregatorV3Interface feed = tre.getPriceFeed();
        uint256 counter = om.getOrderCounter();
        uint256 id1 = counter - 3;
        uint256 id2 = counter - 2;
        uint256 id3 = counter - 1;

        console.log("Order IDs to pay:", id1, id2, id3);

        uint256 eth1 = om.getOrderAmount(id1).getUSDtoEth(feed) * 105 / 100;
        uint256 eth2 = om.getOrderAmount(id2).getUSDtoEth(feed) * 105 / 100;
        uint256 eth3 = om.getOrderAmount(id3).getUSDtoEth(feed) * 105 / 100;

        vm.startBroadcast(buyerKey);
        console.log("Paying orders...");
        tre.payForOrder{value: eth1}(id1);
        tre.payForOrder{value: eth2}(id2);
        tre.payForOrder{value: eth3}(id3);
        vm.stopBroadcast();

        console.log("Done. 3 orders placed and paid.");
    }
}
