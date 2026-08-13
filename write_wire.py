content = (
"// SPDX-License-Identifier: MIT\n"
"pragma solidity 0.8.20;\n"
"\n"
'import {Script, console} from "../lib/forge-std/src/Script.sol";\n'
'import {UserManagement}     from "../src/core/UserManagement.sol";\n'
'import {Treasury}           from "../src/core/Treasury.sol";\n'
'import {OrderManager}       from "../src/core/OrderManager.sol";\n'
'import {CropMarketPlace}    from "../src/core/CropMarketplace.sol";\n'
'import {ProductMarketplace} from "../src/core/ProductMarketplace.sol";\n'
'import {TransactionManager} from "../src/core/TransactionManager.sol";\n'
'import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";\n'
"\n"
"contract wireContracts is Script {\n"
"    function run() external {\n"
'        address umAddr  = vm.envAddress("userManagementContractAddress");\n'
'        address drAddr  = vm.envAddress("documentRegistryContractAddress");\n'
'        address pmAddr  = vm.envAddress("productMarketplaceContractAddress");\n'
'        address cmAddr  = vm.envAddress("cropMarketplaceContractAddress");\n'
'        address omAddr  = vm.envAddress("orderManagerContractAddress");\n'
'        address treAddr = vm.envAddress("treasuryContractAddress");\n'
'        address tmAddr  = vm.envAddress("transectionContractAddress");\n'
'        address pfAddr  = vm.envAddress("pricefeed");\n'
"\n"
'        console.log("Deployer:", msg.sender);\n'
"\n"
"        UserManagement     um  = UserManagement(umAddr);\n"
"        Treasury           tre = Treasury(payable(treAddr));\n"
"        OrderManager       om  = OrderManager(omAddr);\n"
"        CropMarketPlace    cm  = CropMarketPlace(cmAddr);\n"
"        ProductMarketplace pm  = ProductMarketplace(pmAddr);\n"
"        TransactionManager tm  = TransactionManager(tmAddr);\n"
"\n"
"        vm.startBroadcast();\n"
"\n"
'        console.log("[1]  UM            -> setDocumentRegistry");\n'
"        um.setDocumentRegistry(drAddr);\n"
"\n"
'        console.log("[2]  Treasury      -> setOrderManager");\n'
"        tre.setOrderManager(omAddr);\n"
"\n"
'        console.log("[3]  Treasury      -> setTransactionManager");\n'
"        tre.setTransactionManager(tmAddr);\n"
"\n"
'        console.log("[4]  Treasury      -> setPriceFeed");\n'
"        tre.setAggregatorv3InterfacePriceFeed(AggregatorV3Interface(pfAddr));\n"
"\n"
'        console.log("[5]  OrderManager  -> setTreasury");\n'
"        om.setTreasury(treAddr);\n"
"\n"
'        console.log("[6]  OrderManager  -> setProductMarketPlace");\n'
"        om.setProductMarketPlace(pmAddr);\n"
"\n"
'        console.log("[7]  OrderManager  -> setCropMarketPlace");\n'
"        om.setCropMarketPlace(cmAddr);\n"
"\n"
'        console.log("[8]  CropMarket    -> setOrderManager");\n'
"        cm.setOrderManager(omAddr);\n"
"\n"
'        console.log("[9]  CropMarket    -> setTransactionManager");\n'
"        cm.setTransactionManager(tmAddr);\n"
"\n"
'        console.log("[10] ProductMarket -> setOrderManager");\n'
"        pm.setOrderManager(omAddr);\n"
"\n"
'        console.log("[11] TxManager     -> setTreasury");\n'
"        tm.setTreasury(treAddr);\n"
"\n"
"        vm.stopBroadcast();\n"
"\n"
'        console.log("");\n'
'        console.log("=== Verification ===");\n'
'        console.log("UM -> DocRegistry    :", um.getDocumentRegistry());\n'
'        console.log("Treasury -> OrderMgr :", tre.getOrderManagementContractAddress());\n'
'        console.log("Treasury -> TxMgr    :", tre.getTransactionManagerContractAddress());\n'
'        console.log("OrderMgr -> Treasury :", om.getTreasuryContractAddress());\n'
'        console.log("OrderMgr -> ProdMkt  :", om.getProductMarketPlaceAddress());\n'
'        console.log("CropMkt  -> OrderMgr :", cm.getOrderManagerAddress());\n'
'        console.log("ProdMkt  -> OrderMgr :", pm.getOrderManagementContractAddress());\n'
'        console.log("Done.");\n'
"    }\n"
"}\n"
)

with open('/home/kashif/Agrichain_v2/script/wireContracts.s.sol', 'w') as f:
    f.write(content)
print('Written', len(content), 'bytes')
