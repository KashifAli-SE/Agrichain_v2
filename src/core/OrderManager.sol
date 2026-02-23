// SPDX-Licence-Identifier: MIT

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


pragma solidity 0.8.20;

import {IOrderManager} from "../interfaces/IOrderManager.sol";
import {AccessControlled} from "./AccessControlled.sol";
import {UserManagement} from "./UserManagement.sol";

import {Treasury} from "./Treasury.sol";
import {ProductMarketplace} from "./ProductMarketplace.sol";

contract OrderManager is IOrderManager, AccessControlled{

    Order[] orders;
    uint256 public orderCounter=0;
    mapping(uint256=>uint256) orderIDtoOrderArrayIndex;
    mapping(uint256=>ORDERSTATUS) orderIDtoOrderStatus;

    ProductMarketplace public productMarketPlace;
    address productMarketPlace_contract_address;
    Treasury tre;

    address treasury;

    event OrderCreated(uint256 indexed orderID, address indexed buyer, address indexed seller, uint256 productId);
    event treasurySet(address indexed treasuryAddress, address indexed updatedBy,uint256 indexed time);


    constructor(address _usermanager) AccessControlled(_usermanager) {
            // productMarketPlace=ProductMarketplace(_pm);
    }
    
    modifier onlyTreasury() {
        require(msg.sender == treasury, "caller is not treasury");
        _;
    }


/*  ----just to check the variable sequence ---
    struct Order{
        uint256 orderID;
        address buyer;
        address seller;
        uint256 productId;
        uint256 quantity;
        uint256 pricePerUnit;
        ORDERSTATUS orderStatus;
    }

*/

    function addOrder(address _buyer, address _seller, uint256 _productId,uint256 _quantity) external onlyFarmerOrShop override returns(bool){
            uint256 price=productMarketPlace.getProductPrice(_productId);
            uint256 availableUnits=productMarketPlace.getAvailableUnits(_productId);
            require(availableUnits >= _quantity, "required quantity not available");
            uint256 amountToPay=price*_quantity;
            orders.push(Order(orderCounter,_buyer,_seller,_productId,_quantity,price,amountToPay,ORDERSTATUS.PLACED));
            orderIDtoOrderStatus[orderCounter]=ORDERSTATUS.PLACED;
            productMarketPlace.reduce(_productId,_quantity);
            orderIDtoOrderArrayIndex[orderCounter]=orders.length-1;
            emit OrderCreated(orderCounter, _buyer, _seller, _productId);
            orderCounter++;
            return true;
    }
    
    function makepaid(uint256 _orderID) external override onlyTreasury returns(bool) {
        require(orders[_orderID].orderStatus == ORDERSTATUS.PLACED, "Order Already Passed this phase");
        require(_orderID<=orderCounter, "order does not exist");
        uint256 index=orderIDtoOrderArrayIndex[_orderID];
        require(index<orders.length,"Invalid Order index");
        Order storage od=orders[index];
        od.orderStatus=ORDERSTATUS.PAID;
        orderIDtoOrderStatus[_orderID]=ORDERSTATUS.PAID;
        return true;
    }

    function confirmOrder(uint256 _orderID) external onlyFarmer returns(bool){
        require(orderIDtoOrderStatus[_orderID] == ORDERSTATUS.PAID, "Order Not paid");
        
        // FIX: Get the actual array index from the mapping
        uint256 index = orderIDtoOrderArrayIndex[_orderID];
        
        // FIX: Use the index, not the orderID
        Order storage od = orders[index];
        
        od.orderStatus = ORDERSTATUS.CONFRIMED;
        orderIDtoOrderStatus[_orderID] = ORDERSTATUS.CONFRIMED;
        require(od.seller != address(0), "seller address is Null");
        tre.release(_orderID, payable(od.seller));
        return true;
    }


    function completeOrder(uint256 _orderID) external override onlyTreasury returns(bool) {
        uint256 index=orderIDtoOrderArrayIndex[_orderID];
        Order memory order=orders[index];
        require(order.orderStatus == ORDERSTATUS.CONFRIMED,"order not confirmed from Customer");
        order.orderStatus=ORDERSTATUS.COMPLETED;
        orders[index]=order;
        return true;   
    }


    ///////////////////////////////////////////////
    //////////-------CONTRACT SETTERS--------/////
    /////////////////////////////////////////////

    
    function setProductMarketPlace(address _productMarketPlaceAddress) external returns(bool){
        productMarketPlace_contract_address=_productMarketPlaceAddress;
        productMarketPlace=ProductMarketplace(_productMarketPlaceAddress);
        return true;
    }

    function setTreasury(address newTreasury) external onlyAdmin returns(bool){
        treasury=newTreasury;
        tre=Treasury(payable(newTreasury));
        emit treasurySet(newTreasury, msg.sender,block.timestamp);
        return true;
    }


    ///////////////////////////////////////////////
    //////////-------GETTERS--------///////////////
    //////////////////////////////////////////////

    function getOrderStatusByOrderID(uint256 _orderID) external view  returns(ORDERSTATUS) {
        return orderIDtoOrderStatus[_orderID];

    }
    function getOrderByID(uint256 _orderID) external view override returns(Order memory){
        uint256 index=orderIDtoOrderArrayIndex[_orderID];
        return orders[index];
    }

    function getOrderAmount(uint256 _orderID) external view returns(uint256){
        uint256 index=orderIDtoOrderArrayIndex[_orderID];
        return orders[index].amountToPay;
    }

    function getTreasuryContractAddress() external view returns(address){
        return treasury;
    }

    function getProductMarketPlaceAddress() external view returns(address){
        return productMarketPlace_contract_address;
    }

    function getOrderNumber() external view returns(uint256){
        return orderCounter;
    }

    function getOrders() external view returns(Order[] memory){
        return orders;
    }

    function getOrderCounter() external view returns(uint256){
        return orderCounter;
    }

    function getOrderindex(uint256 _orderID) external view returns(uint256){
        return orderIDtoOrderArrayIndex[_orderID];
    }

    function getOrdersLength() external view returns(uint256){
        return orders.length;
    }

}
