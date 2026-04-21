//SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

interface ICropMarketplace {
      
    enum UNIT{
        NONE,
        KG,
        TONN,
        DOZEN
    }

    struct Crop{
        uint256 CropID;
        string CropName;
        string CropType;
        uint256 cropStockAmount;
        UNIT unit;
        uint256 pricePerUnit;
        address cropOwner;
        string CropCityCountry;
        string ipfsImageHash;
    }

    function addCrop(string memory _CropName, string memory _CropType, uint256 _cropStockAmount, UNIT _unit, uint256 _pricePerUnit,
        string memory _CropCityCountry,string memory _ipfsImageHash)  external  returns(bool);

    function updateCrop(uint256 _cropID, uint256 _cropStockAmount, uint256 _pricePerUnit) external returns(bool);


    //order logic completely handled by orderManager
    // function buyCrop(uint256 _cropID, uint256 _cropAmountToBuy, address _cropOwner) payable external returns(bool);


    //order logic completely handled by orderManager
    // function buyCrop(uint256 _cropID, uint256 _cropAmountToBuy, address _cropOwner) payable external returns(bool);

    ////////////////////////////////////////////////////
    ///////////////// GETTERS /////////////////////////
    ///////////////////////////////////////////////////

    function getCrop(uint256 cropID) external view returns(Crop memory);

    function getOwnedCropsList() external view returns(uint256[] memory);

    function getAllListedCrops() external view returns(Crop[] memory);

    function getCropPrice(uint256 _cropID) external view returns(uint256);

    function getAvailableUnits(uint256 _cropID) external view returns(uint256);
    
}