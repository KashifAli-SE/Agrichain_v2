export const UserManagementABI = [
  "function signUp(string _name, uint8 _role, string _contactNumber, string _CNIC, string _city, string _country) external returns (bool)",
  "function signUpAsAdmin(string _name, string _contactNumber, string _CNIC, string _city, string _country, address _address) external returns (bool)",
  "function login() external view returns (tuple(string Name, uint8 Role, string contactNumber, string CNIC, string city, string Country, uint8 verificationStatus))",
  "function deleteAccount() external returns (bool)",
  "function updateAccount(string _name, string _contactNumber, string _city) external returns (bool)",
  "function isFarmer(address user) external view returns (bool)",
  "function isBuyer(address user) external view returns (bool)",
  "function isShop(address user) external view returns (bool)",
  "function isGovernment(address user) external view returns (bool)",
  "function isAdmin(address user) external view returns (bool)",
  "function isActiveUser(address user) external view returns (bool)",
  "function isVerified(address user) external view returns (bool)",
  "function verifyRole(address _address) external returns (bool)",
  "function rejectRole(address _address) external returns (bool)",
  "function getUserId(address _address) external view returns (uint256)",
  "function setDocumentRegistry(address _address) external returns (bool)",
  "function getDocumentRegistry() external view returns (address)",
  "event UserSignedUp(address indexed userAddress, string name, uint8 role, uint256 indexed time)",
  "event UserUpdated(address indexed userAddress, string name, string contactNumber, string city, uint256 indexed time)",
  "event UserVerified(address indexed userAddress, uint256 indexed time)",
  "event UserRejected(address indexed userAddress, uint256 indexed time)",
  "event userRoleVerificationStatusUpdated(address indexed userAddress, uint8 role, uint8 verificationStatus, uint256 indexed time)",
  "event AdminAdded(address indexed adminAddress, string name, uint256 indexed time)",
] as const;

export const DocumentRegistryABI = [
  "function addDocument(string _encryptedCID, bytes32 _hash, uint8 _docType) external",
  "function getDocumentsByUser(address _address) external view returns (tuple(address owner, string encryptedCID, bytes32 hash, uint8 docType))",
  "function verifyUser(address _address) external",
  "function rejectUser(address _address) external",
  "event DocumentAdded(address indexed user, string encryptedCID, bytes32 hash, uint8 docType, uint256 indexed time)",
] as const;

export const CropMarketplaceABI = [
  "function addCrop(string _CropName, string _CropType, uint256 _cropStockAmount, uint8 _unit, uint256 _pricePerUnit, string _CropCityCountry, string _ipfsImageHash) external returns (bool)",
  "function updateCrop(uint256 _cropID, uint256 _cropStockAmount, uint256 _pricePerUnit) external returns (bool)",
  "function getCrop(uint256 _cropID) external view returns (tuple(uint256 CropID, string CropName, string CropType, uint256 cropStockAmount, uint8 unit, uint256 pricePerUnit, address cropOwner, string CropCityCountry, string ipfsImageHash))",
  "function getOwnedCropsList() external view returns (uint256[])",
  "function getAllListedCrops() external view returns (tuple(uint256 CropID, string CropName, string CropType, uint256 cropStockAmount, uint8 unit, uint256 pricePerUnit, address cropOwner, string CropCityCountry, string ipfsImageHash)[])",
  "function getCropPrice(uint256 _cropID) external view returns (uint256)",
  "function getAvailableUnits(uint256 _cropId) external view returns (uint256)",
  "function getOwnerAddress(uint256 _cropId) external view returns (address)",
  "function setOrderManager(address _orderManager_address) external",
  "event CropListed(uint256 indexed cropId, uint256 indexed time, string cropName, string cropType, uint256 cropStockAmount, uint8 unit, uint256 pricePerUnit, address indexed cropOwner, string CropCityCountry, string ipfsImageHash)",
  "event CropUpdated(uint256 indexed cropID, address indexed cropOwner, uint256 indexed time, uint256 cropStockAmount, uint256 pricePerUnit)",
] as const;

export const ProductMarketplaceABI = [
  "function listProduct(string _name, uint8 _type, uint256 _availableUnits, uint256 _pricePerUnit, string _ipfsImageHash) external returns (bool)",
  "function updateProduct(uint256 _ProducdId, uint256 _pricePerUnit, uint256 _availableUnits) external returns (bool)",
  "function removeProduct(uint256 productId) external returns (bool)",
  "function getProductById(uint256 _productId) external view returns (tuple(uint256 ProducdId, string ProductName, uint8 ProductType, uint256 availableUnits, uint256 pricePerUnit, address ProductOwner, string ipfsImageHash))",
  "function getProductsByShop(address _shopAddress) external view returns (uint256[])",
  "function getProductPrice(uint256 _ProducdId) external view returns (uint256)",
  "function getAvailableUnits(uint256 _productId) external view returns (uint256)",
  "function getOwnerAddress(uint256 _productId) external view returns (address)",
  "function setOrderManager(address ordermanager_address) external returns (bool)",
  "function productCounter() external view returns (uint256)",
  "event ProductListed(uint256 indexed productId, address indexed seller, uint256 indexed time, uint256 quantity, uint256 price, string _ipfsImageHash)",
  "event ProductUpdated(uint256 indexed productId, uint256 indexed time, address indexed updatedBy, uint256 quantity, uint256 price)",
  "event ProductRemoved(uint256 indexed productId, uint256 indexed time, address indexed removedBy)",
] as const;

export const OrderManagerABI = [
  "function addOrder(uint256 _productId, uint256 _quantity) external returns (bool)",
  "function confirmOrder(uint256 _orderID) external returns (bool)",
  "function getOrderByID(uint256 _orderID) external view returns (tuple(uint256 orderID, address buyer, address seller, uint256 productId, uint256 quantity, uint256 pricePerUnit, uint256 amountToPay, uint8 Type, uint8 orderStatus))",
  "function getOrders() external view returns (tuple(uint256 orderID, address buyer, address seller, uint256 productId, uint256 quantity, uint256 pricePerUnit, uint256 amountToPay, uint8 Type, uint8 orderStatus)[])",
  "function getOrderStatusByOrderID(uint256 _orderID) external view returns (uint8)",
  "function getOrderAmount(uint256 _orderID) external view returns (uint256)",
  "function getOrderCounter() external view returns (uint256)",
  "function setProductMarketPlace(address _productMarketPlaceAddress) external returns (bool)",
  "function setCropMarketPlace(address _cropMarketPlaceAddress) external returns (bool)",
  "function setTreasury(address newTreasury) external returns (bool)",
  "event OrderCreated(uint256 indexed orderID, address indexed buyer, address indexed seller, uint256 productId, uint8 orderStatus, uint256 time)",
  "event orderUpdated(uint256 indexed orderID, uint8 indexed newStatus, uint256 indexed time)",
] as const;

export const TreasuryABI = [
  "function payForOrder(uint256 _orderID) external payable returns (bool)",
  "function release(uint256 _orderID, address payable _seller, address payable _buyer) external returns (bool)",
  "function setOrderManager(address _ordermanager) external returns (bool)",
  "function setTransactionManager(address tm) external returns (bool)",
  "function setAggregatorv3InterfacePriceFeed(address _priceFeed) external returns (bool)",
  "function getOrderManagementContractAddress() external view returns (address)",
  "function getTransactionManagerContractAddress() external view returns (address)",
  "function getPriceFeed() external view returns (address)",
  "event PaymentReceived(uint256 indexed orderID, address indexed payer, uint256 amount, uint256 indexed time)",
  "event PaymentReleased(uint256 indexed orderID, address indexed seller, uint256 amount, uint256 indexed time)",
] as const;

export const TransactionManagerABI = [
  "function getTransactions() external view returns (tuple(uint256 transactionID, uint256 orderID, address seller, address buyer, uint256 amountTransferred)[])",
  "function getTransactionByID(uint256 _transactionId) external view returns (tuple(uint256 transactionID, uint256 orderID, address seller, address buyer, uint256 amountTransferred))",
  "function getTransactionsByUser(address user) external view returns (uint256[])",
  "function reportTransection(uint256 transactionID, address _reported, address accused, string reason) external returns (bool)",
  "function setTreasury(address _treasury) external returns (bool)",
  "event TransactionAdded(uint256 indexed transactionID, uint256 indexed orderID, address indexed seller, address buyer, uint256 amountTransferred)",
  "event TransactionReported(uint256 indexed transactionID, address indexed reporter, address indexed accused, string reason, uint256 time)",
] as const;

export const ComplaintRegistryABI = [
  "function submitReport(uint256 _orderID, address _buyer, address _seller) external returns (bool)",
  "function resolveReportToBuyer(uint256 reportId) external returns (bool)",
  "function resolveReportToSeller(uint256 reportId) external returns (bool)",
  "function rejectReport(uint256 reportId) external returns (bool)",
  "function withDrawReport(uint256 reportId) external returns (bool)",
  "function getReportStatus(uint256 reportId) external view returns (uint8)",
  "event ReportSubmitted(uint256 indexed reportID, uint256 indexed orderID, address indexed buyer, address seller, uint256 timestamp)",
  "event ReportResolved(uint256 indexed reportID, uint8 status, uint256 indexed time)",
  "event ReportWithdrawn(uint256 indexed reportID, uint256 indexed time)",
] as const;
