// SPDX-Licence-Provider: MIT


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

import {IProductMarketplace} from "../interfaces/IProductMarketplace.sol";
import {AccessControlled} from "./AccessControlled.sol";
import {OrderManager} from "./OrderManager.sol";

import {TransactionManager} from "./TransactionManager.sol";
import {Treasury} from "./Treasury.sol";

contract ProductMarketplace  is IProductMarketplace, AccessControlled{

    uint256 public productCounter;
    mapping(uint256=>Product) producdIdtoProduct;
    mapping(uint256=>uint256) producdIdtoIndex;
    mapping(address=>uint256[])  shopOwnedProducts;

    address orderManager_address;
    TransactionManager tm;
    Treasury treasury;

    event ProductListed(uint256 indexed productId,address indexed seller,uint256 quantity, uint256 price,string _ipfsImageHash);
    
    constructor(address _usermanager) AccessControlled(_usermanager){
        Product memory nullProduct= Product(0,"Null", PRODUCTTYPE.NONE, 0, 0, address(0), "NullHash");
        producdIdtoProduct[0]=nullProduct;
        productCounter=0;

    }


    modifier onlyOrderManager() {
        require(msg.sender == orderManager_address, "caller is Not the Order Manager");
        _;
    }

    function listProduct(string memory _name, PRODUCTTYPE _type, uint256 _availableUnits, uint256 _pricePerUnit,string memory _ipfsImageHash) external onlyShop override returns(bool){
        Product memory newProduct= Product(productCounter,_name,_type,_availableUnits,_pricePerUnit,msg.sender,_ipfsImageHash);
        producdIdtoProduct[productCounter]=newProduct;
        shopOwnedProducts[msg.sender].push(productCounter);
        producdIdtoIndex[productCounter]=shopOwnedProducts[msg.sender].length-1;
        emit ProductListed(productCounter,msg.sender,_availableUnits, _pricePerUnit,_ipfsImageHash);
        productCounter++;
        return true;
    }

    function updateProduct(uint256 _ProducdId, uint256 _pricePerUnit, uint256 _availableUnits) external onlyShop override returns(bool){
        Product memory newProduct= producdIdtoProduct[_ProducdId];
        require(newProduct.ProductOwner == msg.sender, "Not the Product owner");
        newProduct.pricePerUnit=_pricePerUnit;
        newProduct.availableUnits=_availableUnits;
        producdIdtoProduct[_ProducdId]=newProduct;
        return true;
    }

    function removeProduct(uint256 productId) external onlyAdminOrShop override returns (bool)
    {
        Product storage product = producdIdtoProduct[productId];
        address owner = product.ProductOwner;

        require(owner != address(0), "Product does not exist");

        uint256 index = producdIdtoIndex[productId];
        uint256 lastProductId = shopOwnedProducts[owner][shopOwnedProducts[owner].length - 1];

        // swap
        shopOwnedProducts[owner][index] = lastProductId;
        producdIdtoIndex[lastProductId] = index;

        // pop
        shopOwnedProducts[owner].pop();

        // cleanup
        delete producdIdtoIndex[productId];
        delete producdIdtoProduct[productId];

        return true;
    }
    

    function reduce(uint256 _productId,uint256 quantity) external onlyOrderManager  returns(bool) {
        Product memory product=producdIdtoProduct[_productId];
        require(quantity <= product.availableUnits, "Required quantity Not Available");
        product.availableUnits -= quantity;
        producdIdtoProduct[_productId]=product;
        return true;
     }

    function getAvailableUnits(uint256 _productId) external view returns(uint256){
        return producdIdtoProduct[_productId].availableUnits;
     }

   // function getProductUnit(uint256 prodductId) external view returns(UNIT memory){ }

   function setOrderManager(address ordermanager_address) external returns(bool){
        orderManager_address=ordermanager_address;
        return true;
    }

   function getProductsByShop(address _shopAddress) external view returns(uint256[] memory){
        return shopOwnedProducts[_shopAddress];
    }

    function getProductPrice(uint256 _ProducdId) external view override returns(uint256){
        return producdIdtoProduct[_ProducdId].pricePerUnit;

    }
    
   function getOrderManagementContractAddress() external view returns(address ){
        return orderManager_address;
    }

    function getProductById(uint256 _productId) external view override returns(Product memory){
        return producdIdtoProduct[_productId];
    } 
    
    function getOwnerAddress(uint256 _productId) external view returns(address){
        uint256 index=producdIdtoIndex[_productId];
        address OwnerAddress=producdIdtoProduct[_productId].ProductOwner;
        return OwnerAddress;
    }
    
}