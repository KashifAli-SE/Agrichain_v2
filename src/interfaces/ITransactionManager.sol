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
        uint256 orderID;
        address seller;
        address buyer;
        uint256 amountTransferred;
    }

 /*   struct reportedTransaction{
        uint256 transactionID;


    } */


    function reportTransection(uint256 transactionID, address _reported, address accused,string memory reason) external returns(bool);

    function addTransaction(uint256 orderID, address payable seller, address payable buyer, uint256 amountTransferred) external returns(bool);

    function getTransactions() external view returns(Transaction[] memory);

    function getTransactionByID(uint256 _transactionId) external view returns(Transaction memory);

    function getTransactionsByUser(address user) external view returns(uint256[] memory);

}