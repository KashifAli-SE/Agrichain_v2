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


import {ICropMarketplace} from "../interfaces/ICropMarketplace.sol";
import {AccessControlled} from "./AccessControlled.sol";
import {OrderManager} from "./OrderManager.sol";
import {TransactionManager} from "./TransactionManager.sol";
 
contract CropMarketPlace is ICropMarketplace , AccessControlled{

    /////////////////////////////////////////
    /////////------ERRORS //////////////////
    ///////////////////////////////////////


    //////////////////////////////////////////
    /////////------STATE VARIABLES //////////
    ////////////////////////////////////////

    uint256 public cropCounter=0;
    Crop[] public cropsArray;
    mapping(uint256=>uint256) cropIDtoArrayIndex;
    mapping(address=>uint256[]) farmerOwnedCrops;


    OrderManager orderManager;
    address orderManager_address;

    TransactionManager transactionManager; 
    address transactionManager_Address;

    /////////////////////////////////////////
    /////////------EVENTS //////////////////
    ///////////////////////////////////////

    event CropListed(uint256 indexed cropId, string cropName, string indexed cropType,uint256 cropStockAmount,
    UNIT unit, uint256 pricePerUnit,address indexed cropOwner, string CropCityCountry,string ipfsImageHash);

    event CropUpdated(uint256 cropID, uint256 cropStockAmount, uint256 pricePerUnit, address indexed cropOwner);
    
    event  CropSold(uint256 cropID, address indexed buyer, address indexed seller, uint256 pricePerUnit);

    constructor(address _usermanager) 
        AccessControlled(_usermanager)  {
            Crop memory nullCrop=Crop({CropID: 0, CropName: "Null",CropType :"Null", cropStockAmount :0,unit :UNIT.NONE,pricePerUnit :0, cropOwner:address(0),ipfsImageHash:"NullHash" ,CropCityCountry:"NullCityCountry"});
            cropsArray.push(nullCrop);
            cropCounter=0;
        }

    modifier onlyOrderManager(){
        require(msg.sender == orderManager_address, "Caller is not Order Manager");
        _;
    }

    function addCrop(string memory _CropName, string memory _CropType, uint256 _cropStockAmount, UNIT _unit, uint256 _pricePerUnit,
        string memory _CropCityCountry, string memory _ipfsImageHash) onlyFarmer onlyVerified  external override returns(bool)
        {
            Crop memory newCrop=Crop({CropID: cropCounter, CropName: _CropName,CropType :_CropType, cropStockAmount :_cropStockAmount,unit :_unit,pricePerUnit :_pricePerUnit, cropOwner:msg.sender,ipfsImageHash:_ipfsImageHash ,CropCityCountry:_CropCityCountry});
            cropsArray.push(newCrop);
            farmerOwnedCrops[msg.sender].push(cropCounter);
            cropIDtoArrayIndex[cropCounter]=cropsArray.length-1;
            emit CropListed(cropCounter,_CropName,_CropType,_cropStockAmount,_unit,_pricePerUnit,msg.sender,_CropCityCountry,_ipfsImageHash);
            cropCounter++;
    }

    function updateCrop(uint256 _cropID, uint256 _cropStockAmount, uint256 _pricePerUnit) external override onlyFarmer onlyVerified returns(bool){
                uint256 index=cropIDtoArrayIndex[_cropID];
                Crop storage newCrop= cropsArray[index];
                require(newCrop.cropOwner == msg.sender, "Farmer is not the owner of crop");
                newCrop.cropStockAmount=_cropStockAmount;
                newCrop.pricePerUnit=_pricePerUnit;
                emit CropUpdated(_cropID, _cropStockAmount, _pricePerUnit, msg.sender);
                return true;
    }



    function reduce(uint256 _cropId,uint256 quantity) external onlyOrderManager {
            uint256 index=cropIDtoArrayIndex[_cropId];
            Crop storage crop=cropsArray[index];
            require(quantity <= crop.cropStockAmount, "Required quantity Not Available");
            crop.cropStockAmount -= quantity;

        }

    ////////////////////////////////////////////////////
    ///////////////// SETTERS FUNCTIONS/////////////////
    ///////////////////////////////////////////////////
    
    
    function setOrderManager(address _orderManager_address) external onlyAdmin {
        orderManager_address=_orderManager_address;
        orderManager=OrderManager(_orderManager_address);
    }

    function setTransactionManager(address _transactionManager_address) external onlyAdmin {
        transactionManager_Address=_transactionManager_address;
        transactionManager=TransactionManager(_transactionManager_address);
    }

    ////////////////////////////////////////////////////
    ///////////////// GETTERS /////////////////////////
    ///////////////////////////////////////////////////

    function getCrop(uint256 _cropID) external view  override returns(Crop memory){
        uint256 index=cropIDtoArrayIndex[_cropID];
        return cropsArray[index];

    }

    function getCropPrice(uint256 _cropID) external view override returns(uint256){
        uint256 index=cropIDtoArrayIndex[_cropID];
        return cropsArray[index].pricePerUnit;        

    }

    function getOwnedCropsList() external view override returns(uint256[] memory){
        return farmerOwnedCrops[msg.sender];
    }

    function getAllListedCrops() external view override returns(Crop[] memory){
        return cropsArray;
    }

    function getAvailableUnits(uint256 _cropId) external view override returns(uint256){
        uint256 index=cropIDtoArrayIndex[_cropId];
        return cropsArray[index].cropStockAmount;
    }

    function getOrderManagerAddress() external view returns(address) {
        return orderManager_address;
    }

    function getTransactionManager() external view returns(address){
        return transactionManager_Address;
    }

    function getOwnerAddress(uint256 _cropId) external view returns(address){
        uint256 index=cropIDtoArrayIndex[_cropId];
        address OwnerAddress=cropsArray[index].cropOwner;
        return OwnerAddress;
    }

    


}