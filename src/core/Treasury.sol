
// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions


//SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;


import {AccessControlled} from "./AccessControlled.sol";
import {OrderManager} from "./OrderManager.sol";
import {TransactionManager} from "./TransactionManager.sol";

import {PriceConverter} from "../libraries/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Treasury is AccessControlled{

    using PriceConverter for uint256;

    enum ORDERSTATUS{
        PLACED,
        PAID,
        CONFRIMED,
        COMPLETED
    }

    mapping(uint256=>uint256) orderIdtoFunds; //


    mapping(address=>uint256) addresstoCurrentFund;
    mapping(uint256=>address) orderIdtoSellerAddress;
    mapping(uint256=>address) orderIdtoBuyerAddress;
    mapping(uint256=>ORDERSTATUS) orderIdtoOrderStatus;

    AggregatorV3Interface priceFeed;

    address ordermanager_address;
    address transaction_manager_address;
    OrderManager ordermanager;
    TransactionManager transaction_manager;

    constructor(address um) AccessControlled(um) {
    }


    modifier onlyOrderManager() {
        require(msg.sender == ordermanager_address, "Not Order Manager");
        _;
    }

    receive() external payable {

    }

    fallback() external payable {

    }

    // payForOrder order from treasury will store the funds and make the order paid by 
    // calling makepaid from orderManager contract


    //farmer is the buyer of products from the shops that why onlyFarmer modifier used



    function payForOrder(uint256 _orderID) external onlyFarmerOrBuyer payable returns(bool) {
        require(_orderID <= ordermanager.getOrderCounter(), "Order does not exist");
        uint256 index = ordermanager.getOrderindex(_orderID);
        require(index < ordermanager.getOrdersLength(), "Invalid index");
        
        // FIX: Get the required amount to validate payment
        uint256 requiredAmount = ordermanager.getOrderAmount(_orderID);
        requiredAmount=requiredAmount.getUSDtoEth(priceFeed);
        // FIX: Verify farmer sent the correct amount of ETH
        require(msg.value >= requiredAmount, "Incorrect payment amount");
        
        // FIX: Store the actual ETH sent (msg.value), not a recalculated number
        orderIdtoFunds[_orderID] = requiredAmount;
        
        ordermanager.makepaid(_orderID);
        return true;
    }


    function release(uint256 _orderID, address payable _seller,address payable _buyer) external onlyOrderManager returns(bool) {
        uint256 amount = orderIdtoFunds[_orderID];
        require(amount > 0, "No Funds");
        
        // Verify contract actually has the funds
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        orderIdtoFunds[_orderID] = 0;  // Prevent reentrancy
        
        (bool success, ) = _seller.call{value: amount}("");
        require(success, "Payment Not Released");
        
        transaction_manager.addTransaction(_orderID, _seller,_buyer,amount);
        ordermanager.completeOrder(_orderID);
        return true;
    }


    ///////////////////////////////////////////////
    //////////-------SETTERS--------///////////////
    //////////////////////////////////////////////

    function setOrderManager(address _ordermanager) external onlyAdmin returns(bool){
        ordermanager_address=_ordermanager;
        ordermanager=OrderManager(ordermanager_address);
        return true;
    }



    function setTransactionManager(address tm) external onlyAdmin returns(bool){
        transaction_manager_address=tm;
        transaction_manager=TransactionManager(tm);

    }

    function setAggregatorv3InterfacePriceFeed(AggregatorV3Interface _priceFeed) external onlyAdmin returns(bool){
        priceFeed=_priceFeed;
    }

    ///////////////////////////////////////////////
    //////////-------GETTERS--------///////////////
    //////////////////////////////////////////////


    function getOrderManagementContractAddress() external view returns(address ){
        return ordermanager_address;
    }

    function getTransactionManagerContractAddress() external view returns(address) {
        return transaction_manager_address;
    }

    function getPriceFeed() external view returns(AggregatorV3Interface) {
        return priceFeed;
    }

}
