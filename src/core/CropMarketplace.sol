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
    uint256 public boughtCropCounter=0;
    mapping(uint256 => Crop) cropIdToCrop;
    mapping(address=>uint256[]) farmerOwnedCrops;
    mapping(uint256=>boughtCrop) boughtCropIDtoCrop;
    mapping(address=>uint256[]) buyerOwnedCrops;

    OrderManager orderManager;
    address orderManager_address;
    TransactionManager transactionManager; 

    /////////////////////////////////////////
    /////////------EVENTS //////////////////
    ///////////////////////////////////////

    event CropListed(uint256 indexed cropId, string cropName, string indexed cropType,uint256 cropStockAmount,
    UNIT unit, uint256 pricePerUnit,address indexed cropOwner, string CropCityCountry);

    event CropUpdated(uint256 cropID, uint256 cropStockAmount, uint256 pricePerUnit, address indexed cropOwner);
    
    event  CropSold(uint256 cropID, address indexed buyer, address indexed seller, uint256 pricePerUnit);

    constructor(address _usermanager) 
        AccessControlled(_usermanager)  {
              //  orderManager= OrderManager(_orderManager);
            //  transactionManager= TransactionManager(_transectionManager);
        }
    


    modifier onlyOrderManager(){
        require(msg.sender == orderManager_address, "Caller is not Order Manager");
        _;
    }

    function addCrop(string memory _CropName, string memory _CropType, uint256 _cropStockAmount, UNIT _unit, uint256 _pricePerUnit,
        string memory _CropCityCountry) onlyFarmer external override returns(bool)
        {
                Crop memory newCrop=Crop({CropID: cropCounter, CropName: _CropName,CropType :_CropType, cropStockAmount :_cropStockAmount,unit :_unit,pricePerUnit :_pricePerUnit, cropOwner:msg.sender, CropCityCountry:_CropCityCountry});
                cropIdToCrop[newCrop.CropID]=newCrop;
                farmerOwnedCrops[msg.sender].push(cropCounter);
                
                emit CropListed(cropCounter,_CropName,_CropType,_cropStockAmount,_unit,_pricePerUnit,msg.sender,_CropCityCountry);
                cropCounter++;
    }

    function updateCrop(uint256 _cropID, uint256 _cropStockAmount, uint256 _pricePerUnit) external override onlyFarmer returns(bool){
                Crop memory newCrop= cropIdToCrop[_cropID];
                newCrop.cropStockAmount=_cropStockAmount;
                newCrop.pricePerUnit=_pricePerUnit;
                cropIdToCrop[_cropID]=newCrop;
                return true;
    }

   /* function buyCrop(uint256 _cropID, uint256 _cropAmountToBuy, address _cropOwner) payable external override returns(bool){
                Crop memory crop=cropIdToCrop[_cropID];
                require(crop.cropStockAmount>_cropAmountToBuy && msg.value > crop.pricePerUnit*_cropAmountToBuy, "Crop Out of stock or Insufficient Funds");
                address transferedTo= crop.cropOwner;
                crop.cropStockAmount -= _cropAmountToBuy;
                buyerOwnedCrops[msg.sender].push(boughtCropCounter);
                boughtCropIDtoCrop[boughtCropCounter]=boughtCrop(boughtCropCounter,_cropAmountToBuy,crop.unit,crop.cropOwner,msg.sender);
    }
    */

    function reduce(uint256 _cropId) external onlyOrderManager {
        
        }

    ////////////////////////////////////////////////////
    ///////////////// GETTERS /////////////////////////
    ///////////////////////////////////////////////////

    function getCrop(uint256 _cropID) external view  override returns(Crop memory){}

    function getOwnedCropsList() external view override returns(bool){}

    function getAllListedCrops() external view override returns(bool){}
    
}