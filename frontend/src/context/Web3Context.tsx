"use client";

import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  ReactNode,
} from "react";
import { ethers } from "ethers";
import { NETWORK_CONFIG, CONTRACT_ADDRESSES } from "@/config/contracts";
import {
  UserManagementABI,
  DocumentRegistryABI,
  CropMarketplaceABI,
  ProductMarketplaceABI,
  OrderManagerABI,
  TreasuryABI,
  TransactionManagerABI,
  ComplaintRegistryABI,
} from "@/config/abis";

// ─── Types ────────────────────────────────────────────────────
export interface UserData {
  Name: string;
  Role: number;          // enum index
  contactNumber: string;
  CNIC: string;
  city: string;
  Country: string;
  verificationStatus: number; // enum index
}

interface Web3ContextType {
  // connection
  provider:         ethers.BrowserProvider | null;
  signer:           ethers.JsonRpcSigner   | null;
  address:          string | null;
  chainId:          number | null;
  isConnected:      boolean;
  isConnecting:     boolean;
  connectWallet:    () => Promise<void>;
  disconnectWallet: () => void;

  // user state
  userData:         UserData | null;
  isRegistered:     boolean;
  refreshUser:      () => Promise<void>;

  // contracts (signed)
  contracts: {
    userManagement:     ethers.Contract | null;
    documentRegistry:   ethers.Contract | null;
    cropMarketplace:    ethers.Contract | null;
    productMarketplace: ethers.Contract | null;
    orderManager:       ethers.Contract | null;
    treasury:           ethers.Contract | null;
    transactionManager: ethers.Contract | null;
    complaintRegistry:  ethers.Contract | null;
  };
}

// ─── Context ──────────────────────────────────────────────────
const Web3Context = createContext<Web3ContextType | null>(null);

export function Web3Provider({ children }: { children: ReactNode }) {
  const [provider,     setProvider]     = useState<ethers.BrowserProvider | null>(null);
  const [signer,       setSigner]       = useState<ethers.JsonRpcSigner   | null>(null);
  const [address,      setAddress]      = useState<string | null>(null);
  const [chainId,      setChainId]      = useState<number | null>(null);
  const [isConnecting, setIsConnecting] = useState(false);
  const [userData,     setUserData]     = useState<UserData | null>(null);
  const [isRegistered, setIsRegistered] = useState(false);
  const [contracts,    setContracts]    = useState<Web3ContextType["contracts"]>({
    userManagement:     null,
    documentRegistry:   null,
    cropMarketplace:    null,
    productMarketplace: null,
    orderManager:       null,
    treasury:           null,
    transactionManager: null,
    complaintRegistry:  null,
  });

  // Build contract instances whenever signer changes
  const buildContracts = useCallback(
    (s: ethers.JsonRpcSigner) => {
      const addr = CONTRACT_ADDRESSES;
      setContracts({
        userManagement:     new ethers.Contract(addr.UserManagement,     UserManagementABI,     s),
        documentRegistry:   new ethers.Contract(addr.DocumentRegistry,   DocumentRegistryABI,   s),
        cropMarketplace:    new ethers.Contract(addr.CropMarketplace,    CropMarketplaceABI,    s),
        productMarketplace: new ethers.Contract(addr.ProductMarketplace, ProductMarketplaceABI, s),
        orderManager:       new ethers.Contract(addr.OrderManager,       OrderManagerABI,       s),
        treasury:           new ethers.Contract(addr.Treasury,           TreasuryABI,           s),
        transactionManager: new ethers.Contract(addr.TransactionManager, TransactionManagerABI, s),
        complaintRegistry:  new ethers.Contract(addr.ComplaintRegistry,  ComplaintRegistryABI,  s),
      });
    },
    []
  );

  // Fetch on-chain user profile
  const refreshUser = useCallback(async () => {
    if (!contracts.userManagement || !address) return;
    try {
      const active = await contracts.userManagement.isActiveUser(address);
      if (active) {
        const data = await contracts.userManagement.login();
        setUserData({
          Name:               data.Name,
          Role:               Number(data.Role),
          contactNumber:      data.contactNumber,
          CNIC:               data.CNIC,
          city:               data.city,
          Country:            data.Country,
          verificationStatus: Number(data.verificationStatus),
        });
        setIsRegistered(true);
      } else {
        setUserData(null);
        setIsRegistered(false);
      }
    } catch {
      setUserData(null);
      setIsRegistered(false);
    }
  }, [contracts.userManagement, address]);

  // Switch / add Sepolia in MetaMask
  const switchToSepolia = async (p: ethers.BrowserProvider) => {
    try {
      await (window as any).ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: `0x${NETWORK_CONFIG.chainId.toString(16)}` }],
      });
    } catch (switchError: any) {
      if (switchError.code === 4902) {
        await (window as any).ethereum.request({
          method: "wallet_addEthereumChain",
          params: [{
            chainId:         `0x${NETWORK_CONFIG.chainId.toString(16)}`,
            chainName:        NETWORK_CONFIG.name,
            nativeCurrency:  { name: "ETH", symbol: "ETH", decimals: 18 },
            rpcUrls:         [NETWORK_CONFIG.rpcUrl],
            blockExplorerUrls:[NETWORK_CONFIG.explorer],
          }],
        });
      }
    }
  };

  const connectWallet = useCallback(async () => {
    if (!(window as any).ethereum) {
      alert("No wallet detected. Please install MetaMask or another Web3 wallet.");
      return;
    }
    setIsConnecting(true);
    try {
      const p = new ethers.BrowserProvider((window as any).ethereum);
      await p.send("eth_requestAccounts", []);
      const network = await p.getNetwork();
      if (Number(network.chainId) !== NETWORK_CONFIG.chainId) {
        await switchToSepolia(p);
      }
      const s = await p.getSigner();
      const addr = await s.getAddress();
      setProvider(p);
      setSigner(s);
      setAddress(addr);
      setChainId(Number(network.chainId));
      buildContracts(s);
    } finally {
      setIsConnecting(false);
    }
  }, [buildContracts]);

  const disconnectWallet = useCallback(() => {
    setProvider(null);
    setSigner(null);
    setAddress(null);
    setChainId(null);
    setUserData(null);
    setIsRegistered(false);
    setContracts({
      userManagement: null, documentRegistry: null, cropMarketplace: null,
      productMarketplace: null, orderManager: null, treasury: null,
      transactionManager: null, complaintRegistry: null,
    });
  }, []);

  // Listen for account / chain changes
  useEffect(() => {
    const eth = (window as any).ethereum;
    if (!eth) return;
    const onAccounts = () => connectWallet();
    const onChain   = () => connectWallet();
    eth.on("accountsChanged", onAccounts);
    eth.on("chainChanged",    onChain);
    return () => {
      eth.removeListener("accountsChanged", onAccounts);
      eth.removeListener("chainChanged",    onChain);
    };
  }, [connectWallet]);

  // Refresh user whenever contracts / address change
  useEffect(() => {
    refreshUser();
  }, [refreshUser]);

  return (
    <Web3Context.Provider
      value={{
        provider, signer, address, chainId,
        isConnected: !!address,
        isConnecting,
        connectWallet, disconnectWallet,
        userData, isRegistered, refreshUser,
        contracts,
      }}
    >
      {children}
    </Web3Context.Provider>
  );
}

export function useWeb3() {
  const ctx = useContext(Web3Context);
  if (!ctx) throw new Error("useWeb3 must be used inside Web3Provider");
  return ctx;
}
