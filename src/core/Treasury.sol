
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


//SPDX-License-Identifier: MIT

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

    bool private _releasing; // reentrancy guard for release()

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

    event PaymentReceived(uint256 indexed orderID, address indexed payer, uint256 amount, uint256 indexed time);
    event PaymentReleased(uint256 indexed orderID, address indexed seller, uint256 amount, uint256 indexed time);

    function payForOrder(uint256 _orderID) external onlyFarmerOrBuyer onlyVerified payable returns(bool) {
        require(_orderID <= ordermanager.getOrderCounter(), "Order does not exist");
        uint256 index = ordermanager.getOrderindex(_orderID);
        require(index < ordermanager.getOrdersLength(), "Invalid index");
        
        uint256 requiredAmount = ordermanager.getOrderAmount(_orderID);
        requiredAmount = requiredAmount.getUSDtoEth(priceFeed);
        require(msg.value >= requiredAmount, "Incorrect payment amount");
        
        // Store the exact required amount; refund any excess back to sender
        orderIdtoFunds[_orderID] = requiredAmount;
        
        uint256 excess = msg.value - requiredAmount;
        if (excess > 0) {
            (bool refunded, ) = payable(msg.sender).call{value: excess}("");
            require(refunded, "Excess refund failed");
        }
        
        ordermanager.makepaid(_orderID);
        emit PaymentReceived(_orderID, msg.sender, requiredAmount, block.timestamp);
        return true;
    }


    function release(uint256 _orderID, address payable _seller,address payable _buyer) external onlyOrderManager returns(bool) {
        require(!_releasing, "Reentrant call");
        _releasing = true;

        uint256 amount = orderIdtoFunds[_orderID];
        require(amount > 0, "No Funds");
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        // Clear funds and update state before external calls (checks-effects-interactions)
        orderIdtoFunds[_orderID] = 0;
        transaction_manager.addTransaction(_orderID, _seller, _buyer, amount);
        ordermanager.completeOrder(_orderID);

        (bool success, ) = _seller.call{value: amount}("");
        require(success, "Payment Not Released");
        emit PaymentReleased(_orderID, _seller, amount, block.timestamp);

        _releasing = false;
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
        return true;
    }

    function setAggregatorv3InterfacePriceFeed(AggregatorV3Interface _priceFeed) external onlyAdmin returns(bool){
        priceFeed=_priceFeed;
        return true;
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
