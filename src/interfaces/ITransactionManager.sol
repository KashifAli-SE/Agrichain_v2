// SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

interface ITransactionManager {


    enum PRODUCT{
        Crop,
        PRODUCT
    }

    enum UNIT{
        KG,
        TONN,
        VIALS
    }


    struct Transaction{
        uint256 transactionID;
        address seller;
        address buyer;
        PRODUCT product;
        uint256 amountTransferred;
        uint256 totalStockBought;
        UNIT unit;
    }

    function addtransaction(Transaction memory) external returns(bool);

    function getTransactions() external view returns(bool);

    function getTransactionsByID() external view returns(bool);

    function getTransactionsByUser() external view returns(bool);

}