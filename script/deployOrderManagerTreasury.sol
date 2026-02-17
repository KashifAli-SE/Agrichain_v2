//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {OrderManager} from "../src/core/OrderManager.sol";
import {TransactionManager} from "../src/core/TransactionManager.sol";
import {Treasury} from "../src/core/Treasury.sol";

contract deployTransectionOrderManager is Script{

        function setUp() external{

        }

        function run() external{
            address _usermanager = vm.envAddress("usermanagement_contract_address");
            //address _treasury=vm.envAddress("treasury_Contract_Address");
            //address _productMarketPlace=vm.envAddress("productMarketPlace_contract_address");
            vm.startBroadcast();
            OrderManager om = new OrderManager(_usermanager);
            //Treasury tre=new Treasury(_usermanager);
           vm.stopBroadcast();
           // TransactionManager tm= new TransactionManager(_usermanager,_);
           
        }

}