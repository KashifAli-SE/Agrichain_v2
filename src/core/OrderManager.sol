// SPDX-License-Identifier: MIT

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


import {Treasury} from "./Treasury.sol";
import {ProductMarketplace} from "./ProductMarketplace.sol";
import {CropMarketPlace} from "./CropMarketplace.sol";

import {PriceConverter} from "../libraries/PriceConverter.sol";

contract OrderManager is IOrderManager, AccessControlled{

    Order[] orders;
    uint256 public orderCounter=0;
    mapping(uint256=>uint256) orderIDtoOrderArrayIndex;
    mapping(uint256=>ORDERSTATUS) orderIDtoOrderStatus;

    ProductMarketplace public productMarketPlace;
    CropMarketPlace public cropMarketPlace;
    address productMarketPlace_contract_address;
    address cropMarketPlace_contract_address;
    Treasury tre;

    address treasury;

    event OrderCreated(uint256 indexed orderID, address indexed buyer, address indexed seller, uint256 productId,ORDERSTATUS orderStatus,uint256 time);
    event orderUpdated(uint256 indexed orderID, ORDERSTATUS indexed newStatus, uint256 indexed time);
    event treasurySet(address indexed treasuryAddress, address indexed updatedBy,uint256 indexed time);
    event cropMarketPlaceSet(address indexed cropMarketPlace, address indexed updatedBy, uint256 indexed time);
    event productMarketPlaceSet(address indexed productMarketPlace, address indexed updatedBy, uint256 indexed time);
    event orderBuyerUpdated(uint256 indexed orderID, address indexed newBuyer, uint256 indexed time);

    constructor(address _usermanager) AccessControlled(_usermanager) {
            // productMarketPlace=ProductMarketplace(_pm);
            Order memory dummyOrder= Order(0,address(0),address(0),0,0,0,0,PRODUCTTYPE.NONE,ORDERSTATUS.COMPLETED);
            orders.push(dummyOrder);
            orderIDtoOrderArrayIndex[0]=0;
            orderIDtoOrderStatus[0]=ORDERSTATUS.COMPLETED;
            orderCounter=1;

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
        uint256 productId; // can be product or crop 
        PRODUCT productType;
        uint256 quantity;
        uint256 pricePerUnit;
        ORDERSTATUS orderStatus;
    }

*/

    function addOrder(uint256 _productId,uint256 _quantity) external onlyFarmerOrBuyer onlyVerified override returns(bool){
            address seller;
            if(um.isFarmer(msg.sender)){
                uint256 price=productMarketPlace.getProductPrice(_productId);
                uint256 availableUnits=productMarketPlace.getAvailableUnits(_productId);
                seller=productMarketPlace.getOwnerAddress(_productId);
                require(availableUnits >= _quantity, "required quantity not available");
                uint256 amountToPay=price*_quantity;
                orders.push(Order(orderCounter,msg.sender,seller,_productId,_quantity,price,amountToPay,PRODUCTTYPE.Product,ORDERSTATUS.PLACED));
                orderIDtoOrderStatus[orderCounter]=ORDERSTATUS.PLACED;
                productMarketPlace.reduce(_productId,_quantity);
            }
            else if(um.isBuyer(msg.sender)){
                uint256 price=cropMarketPlace.getCropPrice(_productId);
                seller=cropMarketPlace.getOwnerAddress(_productId);
                uint256 availableUnits=cropMarketPlace.getAvailableUnits(_productId);
                require(availableUnits >= _quantity, "required quantity not available");
                uint256 amountToPay=price*_quantity;
                orders.push(Order(orderCounter,msg.sender,seller,_productId,_quantity,price,amountToPay,PRODUCTTYPE.Crop,ORDERSTATUS.PLACED));
                orderIDtoOrderStatus[orderCounter]=ORDERSTATUS.PLACED;
                cropMarketPlace.reduce(_productId,_quantity);

            }
            orderIDtoOrderArrayIndex[orderCounter]=orders.length-1;
            emit OrderCreated(orderCounter, msg.sender, seller, _productId, ORDERSTATUS.PLACED, block.timestamp);
            orderCounter++;
            return true;
    }
    
    function makepaid(uint256 _orderID) external override onlyTreasury returns(bool) {
        require(_orderID <= orderCounter, "order does not exist");
        uint256 index = orderIDtoOrderArrayIndex[_orderID];
        require(index < orders.length, "Invalid Order index");
        Order storage od = orders[index];
        require(od.orderStatus == ORDERSTATUS.PLACED, "Order Already Passed this phase");
        od.orderStatus = ORDERSTATUS.PAID;
        orderIDtoOrderStatus[_orderID] = ORDERSTATUS.PAID;
        emit orderUpdated(_orderID, ORDERSTATUS.PAID, block.timestamp);
        return true;
    }

    function confirmOrder(uint256 _orderID) external onlyFarmerOrBuyer onlyVerified returns(bool){
        require(orderIDtoOrderStatus[_orderID] == ORDERSTATUS.PAID, "Order Not paid");
        
        // FIX: Get the actual array index from the mapping
        uint256 index = orderIDtoOrderArrayIndex[_orderID];
        
        // FIX: Use the index, not the orderID
        Order storage od = orders[index];
        
        od.orderStatus = ORDERSTATUS.CONFIRMED;
        orderIDtoOrderStatus[_orderID] = ORDERSTATUS.CONFIRMED;
        require(od.seller != address(0), "seller address is Null");
        tre.release(_orderID, payable(od.seller), payable(od.buyer));
        emit orderUpdated(_orderID, ORDERSTATUS.CONFIRMED, block.timestamp);
        return true;
    }


    function completeOrder(uint256 _orderID) external override onlyTreasury returns(bool) {
        uint256 index=orderIDtoOrderArrayIndex[_orderID];
        Order memory order=orders[index];
        require(order.orderStatus == ORDERSTATUS.CONFIRMED,"order not confirmed from Customer");
        order.orderStatus=ORDERSTATUS.COMPLETED;
        orders[index]=order;
        orderIDtoOrderStatus[_orderID]=ORDERSTATUS.COMPLETED;
        emit orderUpdated(_orderID, ORDERSTATUS.COMPLETED, block.timestamp);
        return true;   
    }


    ///////////////////////////////////////////////
    //////////-------CONTRACT SETTERS--------/////
    /////////////////////////////////////////////

    
    function setProductMarketPlace(address _productMarketPlaceAddress) external onlyAdmin returns(bool){
        productMarketPlace_contract_address=_productMarketPlaceAddress;
        productMarketPlace=ProductMarketplace(_productMarketPlaceAddress);
        emit productMarketPlaceSet(_productMarketPlaceAddress, msg.sender,block.timestamp);
        return true;
    }

    function setTreasury(address newTreasury) external onlyAdmin returns(bool){
        treasury=newTreasury;
        tre=Treasury(payable(newTreasury));
        emit treasurySet(newTreasury, msg.sender,block.timestamp);
        return true;
    }

    function setCropMarketPlace(address _cropMarketPlaceAddress) external onlyAdmin returns(bool){
        cropMarketPlace_contract_address=_cropMarketPlaceAddress;
        cropMarketPlace=CropMarketPlace(_cropMarketPlaceAddress);
        emit cropMarketPlaceSet(_cropMarketPlaceAddress, msg.sender,block.timestamp);
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
