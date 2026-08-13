//SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {UserManagement} from "../src/core/UserManagement.sol";
import {AccessControlled} from "../src/core/AccessControlled.sol";
import {CropMarketPlace} from "../src/core/CropMarketplace.sol";
import {ProductMarketplace} from "../src/core/ProductMarketplace.sol";
import {OrderManager} from "../src/core/OrderManager.sol";
import {TransactionManager} from "../src/core/TransactionManager.sol";
import {Treasury} from "../src/core/Treasury.sol";
import {ComplaintRegistry} from "../src/core/ComplaintRegistry.sol";

contract  deployOtherContracts is Script{

    function setup() public {

    }

    function run() public {
        vm.startBroadcast();

        address _userManagement=vm.envAddress("userManagementContractAddress");  // already deployed
        ProductMarketplace pm=new ProductMarketplace(_userManagement );         // Products from shops
        CropMarketPlace cp=new CropMarketPlace(_userManagement);
        OrderManager om=new OrderManager(_userManagement);                      
        Treasury treasury=new Treasury(_userManagement);
        TransactionManager tm = new TransactionManager(_userManagement);
        ComplaintRegistry cr= new ComplaintRegistry(_userManagement);
        vm.stopBroadcast();
    }
}