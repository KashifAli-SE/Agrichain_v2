import { ethers } from "ethers";

// ─── Enum maps ────────────────────────────────────────────────
export const ROLES: Record<number, string> = {
  0: "None",
  1: "Farmer",
  2: "Buyer",
  3: "Shopkeeper",
  4: "Government",
  5: "Admin",
};

export const VERIFICATION_STATUS: Record<number, string> = {
  0: "Pending",
  1: "Applied",
  2: "Verified",
  3: "Rejected",
};

export const ORDER_STATUS: Record<number, string> = {
  0: "Placed",
  1: "Paid",
  2: "Confirmed",
  3: "Completed",
};

export const PRODUCT_TYPE: Record<number, string> = {
  0: "None",
  1: "Crop",
  2: "Product",
};

export const CROP_UNIT: Record<number, string> = {
  0: "None",
  1: "KG",
  2: "Tonn",
  3: "Dozen",
};

export const SHOP_PRODUCT_TYPE: Record<number, string> = {
  0: "None",
  1: "Fertilizer",
  2: "Seed",
  3: "Pesticides",
};

export const DOC_TYPES: { label: string; value: number }[] = [
  { label: "CNIC",                value: 1  },
  { label: "Smart CNIC",          value: 2  },
  { label: "Passport",            value: 3  },
  { label: "Land Ownership Fard", value: 4  },
  { label: "Land Registry Deed",  value: 5  },
  { label: "Kisan Card",          value: 6  },
  { label: "Tenancy Agreement",   value: 7  },
  { label: "Irrigation Permit",   value: 8  },
  { label: "Business Registration",value:9  },
  { label: "Shop License",        value: 10 },
  { label: "Dealer License",      value: 11 },
  { label: "Govt Employee ID",    value: 12 },
];

export const REPORT_STATUS: Record<number, string> = {
  0: "Filed",
  1: "Under Review",
  2: "Resolved (Buyer)",
  3: "Resolved (Seller)",
  4: "Rejected",
  5: "Resolved",
};

// ─── Formatting helpers ───────────────────────────────────────
export function shortAddress(addr: string) {
  return `${addr.slice(0, 6)}…${addr.slice(-4)}`;
}

export function formatEth(wei: bigint | string, decimals = 4) {
  return parseFloat(ethers.formatEther(wei)).toFixed(decimals);
}

export function formatUSD(amount: bigint | number) {
  const n = typeof amount === "bigint" ? Number(amount) : amount;
  return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(n);
}

export function statusColor(status: number, map: Record<number, string>): string {
  const s = map[status]?.toLowerCase() ?? "";
  if (s.includes("verified") || s.includes("completed") || s.includes("resolved"))
    return "bg-green-100 text-green-700";
  if (s.includes("pending") || s.includes("placed") || s.includes("paid"))
    return "bg-yellow-100 text-yellow-700";
  if (s.includes("rejected"))
    return "bg-red-100 text-red-700";
  if (s.includes("applied") || s.includes("confirmed") || s.includes("review"))
    return "bg-blue-100 text-blue-700";
  return "bg-gray-100 text-gray-600";
}

// Raise contract errors as readable messages
export function parseContractError(err: unknown): string {
  if (err instanceof Error) {
    const msg = err.message;
    const match = msg.match(/reason="([^"]+)"/);
    if (match) return match[1];
    if (msg.includes("user rejected")) return "Transaction rejected by user.";
    return msg.slice(0, 120);
  }
  return "Unknown error";
}
