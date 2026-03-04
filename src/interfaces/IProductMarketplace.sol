// SPDX-Licence-Provider: MIT

pragma solidity 0.8.20;


interface IProductMarketplace {

    enum PRODUCTTYPE{
        Fertilizer,
        Seed,
        Pesticides,
        CROP
    
    } 

    struct Product{
        uint256 ProducdId;
        string ProductName;
        PRODUCTTYPE ProductType;
        uint256 availableUnits;
        uint256 pricePerUnit;
        address ProductOwner;
        string ipfsImageHash;
    }

    function listProduct(string memory _name, PRODUCTTYPE _type, uint256 _availableUnits, uint256 _pricePerUnit,string memory _ipfsImageHash) external returns(bool);

    function updateProduct(uint256 _ProducdId, uint256 _pricePerUnit, uint256 _availableUnits) external returns(bool);
    
    function removeProduct(uint256 _ProducdId) external returns(bool);
    
    function getProductPrice(uint256 _ProducdId) external view returns(uint256);
    
    function getProductsByShop(address) external view returns(uint256[] memory);

    function getProductById(uint256 _productId) external view returns(Product memory);
    
    //orders are shifted complety to orderManager 
    //function buyProduct(uint256 ProductId, uint256 boughtUnits, address ProductOwner) payable external  returns(bool);


}