//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {TransactionManager} from "../src/core/TransactionManager.sol";

contract deployTransectionOrderManager is Script{

        function setUp() external{

        }

        function run() external{
            address _usermanager = vm.envAddress("usermanagement_contract_address");
            vm.startBroadcast();
            TransactionManager tm = new TransactionManager(_usermanager);
            vm.stopBroadcast();
           
        }

}