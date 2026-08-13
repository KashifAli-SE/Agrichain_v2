import { Leaf } from "lucide-react";
import Link from "next/link";

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-400 py-12 mt-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="col-span-1">
            <div className="flex items-center gap-2 text-white font-bold text-lg mb-3">
              <Leaf className="w-5 h-5 text-primary-400" />
              AgriChain
            </div>
            <p className="text-sm leading-relaxed">
              Decentralized agricultural supply chain platform connecting farmers,
              buyers, and shopkeepers on Ethereum.
            </p>
          </div>
          <div>
            <h4 className="text-white font-semibold mb-3">Marketplace</h4>
            <ul className="space-y-2 text-sm">
              <li><Link href="/marketplace/crops"    className="hover:text-white transition">Browse Crops</Link></li>
              <li><Link href="/marketplace/products" className="hover:text-white transition">Browse Products</Link></li>
            </ul>
          </div>
          <div>
            <h4 className="text-white font-semibold mb-3">Account</h4>
            <ul className="space-y-2 text-sm">
              <li><Link href="/profile"   className="hover:text-white transition">Profile</Link></li>
              <li><Link href="/documents" className="hover:text-white transition">Documents</Link></li>
              <li><Link href="/orders"    className="hover:text-white transition">Orders</Link></li>
            </ul>
          </div>
          <div>
            <h4 className="text-white font-semibold mb-3">Network</h4>
            <ul className="space-y-2 text-sm">
              <li><span className="text-primary-400">● </span>Sepolia Testnet</li>
              <li>
                <a
                  href="https://sepolia.etherscan.io"
                  target="_blank"
                  rel="noreferrer"
                  className="hover:text-white transition"
                >
                  Etherscan
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="border-t border-gray-800 mt-10 pt-6 text-center text-xs">
          © {new Date().getFullYear()} AgriChain. Built on Ethereum.
        </div>
      </div>
    </footer>
  );
}
