// SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;



interface IOrderManager{

    enum PRODUCT{
        Crop,
        Product
    }

    enum ORDERSTATUS{
        PLACED,
        PAID,
        CONFRIMED,
        COMPLETED
    }

    struct Order{
        uint256 orderID;
        address buyer;
        address seller;
        uint256 productId;
        uint256 quantity;
        uint256 pricePerUnit;
        ORDERSTATUS orderStatus;
    }

    // STEP-1 FARMER CREATES AN ORDER
    function addOrder(address buyer, address seller, uint256 productId,uint256 quantity) external returns(bool);

    //STEP-2 FARMER PAYS FOR THE ORDER THROUGH treasury.payForOrder() 
    //Function which will call makepaid function below
    function makepaid(uint256 _orderID) external  returns(bool);

    //STEP-3 FARMER confirms the order that it received 

    function confirmOrder(uint256 _orderID) external returns(bool);
    
    //STEP-4 after farmer confirms the order, the complet order function is called which
    // will release payment by calling treasury.release() to _seller

    function completeOrder(uint256 _orderID) external returns(bool);

    ///////////////////////////////////////////////
    //////////-------GETTERS--------///////////////
    //////////////////////////////////////////////

    function getOrderByID(uint256 _orderID) external returns(Order memory);

}