// ─────────────────────────────────────────────────────────────
//  Deployed contract addresses — FullDeploy.s.sol on Sepolia
// ─────────────────────────────────────────────────────────────
export const CONTRACT_ADDRESSES = {
  UserManagement:     "0x7d17FE19Ce087F53b31f1faDec0129Fa8AAf2989" as `0x${string}`,
  DocumentRegistry:   "0xA30458879db97C7479428eeDA05585189e46664b" as `0x${string}`,
  CropMarketplace:    "0x36579e9F4CEd5f22B1e7a238DE6F74B7C65e1A2a" as `0x${string}`,
  ProductMarketplace: "0x3e613caF46dd96248c5dAf227e1F9860bDF5730D" as `0x${string}`,
  OrderManager:       "0x2D4C13Bc5C35B8131F74Da9c3A10347520048E0E" as `0x${string}`,
  Treasury:           "0xdd7fD10c3e36B9b0E741a5f2B553F117aa426D49" as `0x${string}`,
  TransactionManager: "0xC18d4Fc5C3bE13f8f7Aa2171F345D9b18ECCBDB7" as `0x${string}`,
  ComplaintRegistry:  "0x5CFDed0d868aBA1376b1B4BFAf0D53950409E004" as `0x${string}`,
};

// Sepolia testnet (chain ID 11155111)
export const CHAIN_ID = 11155111;

export const NETWORK_CONFIG = {
  chainId:  CHAIN_ID,
  name:     "Sepolia",
  currency: "ETH",
  rpcUrl:   "https://eth-sepolia.g.alchemy.com/v2/kyPmAKub4bjXT3m84Hzt-",
  explorer: "https://sepolia.etherscan.io",
};

// Chainlink ETH/USD price feed on Sepolia
export const PRICE_FEED_ADDRESS = "0x694AA1769357215DE4FAC081bf1f309aDC325306";

// Deployment block — FullDeploy.s.sol confirmed at block 11682727
export const DEPLOYMENT_BLOCK = 11682727;
