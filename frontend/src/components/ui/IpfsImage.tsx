"use client";
import { useState } from "react";

// Ordered list of IPFS gateways — fastest first
const GATEWAYS = [
  "https://cloudflare-ipfs.com/ipfs/",
  "https://gateway.pinata.cloud/ipfs/",
  "https://{cid}.ipfs.w3s.link/",   // CID-based subdomain (fastest when supported)
  "https://ipfs.io/ipfs/",
];

interface IpfsImageProps {
  cid:       string;
  alt:       string;
  className?: string;
  fallback?: React.ReactNode;
}

export default function IpfsImage({ cid, alt, className, fallback }: IpfsImageProps) {
  const [gatewayIndex, setGatewayIndex] = useState(0);

  if (!cid || cid === "NullHash" || cid === "") {
    return <>{fallback}</>;
  }

  // Build URL — handle CID-subdomain gateway specially
  function buildUrl(index: number): string {
    const gw = GATEWAYS[index];
    if (gw.includes("{cid}")) {
      return `https://${cid}.ipfs.w3s.link/`;
    }
    return `${gw}${cid}`;
  }

  function handleError() {
    if (gatewayIndex < GATEWAYS.length - 1) {
      setGatewayIndex(i => i + 1);
    }
  }

  return (
    <img
      key={gatewayIndex}                   // force remount on gateway change
      src={buildUrl(gatewayIndex)}
      alt={alt}
      className={className}
      onError={handleError}
      loading="lazy"
    />
  );
}
