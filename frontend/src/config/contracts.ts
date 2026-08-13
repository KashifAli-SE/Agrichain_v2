// ─────────────────────────────────────────────────────────────
//  Deployed contract addresses (Sepolia — updated after redeploy)
// ─────────────────────────────────────────────────────────────
export const CONTRACT_ADDRESSES = {
  UserManagement:     "0x469Fc0102B6ee0FCefCD502cF55E2FFd4DF925e3" as `0x${string}`,
  DocumentRegistry:   "0xFE1d0ca9526b7bc9FB321b80De84892FD39F77b0" as `0x${string}`,
  CropMarketplace:    "0xd11276441bD8E37f74F60Ba5d27e360208C6a244" as `0x${string}`,
  ProductMarketplace: "0xc138FbEA0E6d82A6355d5eff62b175bfCADD5507" as `0x${string}`,
  OrderManager:       "0xa433ed2D3D4bAc6231ACce8900bBCAA012cDBBc4" as `0x${string}`,
  Treasury:           "0xcB38Aaa3d3e3ff616AC57C0dBaEb8681B439335C" as `0x${string}`,
  TransactionManager: "0x4b395A38a229E76B90aeBcF06D254b6E8E3af37D" as `0x${string}`,
  ComplaintRegistry:  "0xb4855B05C6BC621D4ee1a33E77F83E57398410B2" as `0x${string}`,
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

// Block number when contracts were deployed.
// Used to limit event log queries — update this after each redeployment.
// Exact deployment block from broadcast: 0xaec5cb = 11454923
export const DEPLOYMENT_BLOCK = 11454923;
