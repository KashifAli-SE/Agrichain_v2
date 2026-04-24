//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {OrderManager} from "../src/core/OrderManager.sol";
import {TransactionManager} from "../src/core/TransactionManager.sol";
import {Treasury} from "../src/core/Treasury.sol";

contract deployOrderManager is Script{

        function setUp() external{

        }

        function run() external{
            address _usermanager = vm.envAddress("userManagementContractAddress");
            vm.startBroadcast();
            OrderManager om = new OrderManager(_usermanager);
            vm.stopBroadcast();           
        }

}