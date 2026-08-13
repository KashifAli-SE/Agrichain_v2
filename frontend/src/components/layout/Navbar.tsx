"use client";
import Link from "next/link";
import { useWeb3 } from "@/context/Web3Context";
import { shortAddress, ROLES, VERIFICATION_STATUS } from "@/lib/helpers";
import Button from "@/components/ui/Button";
import Badge from "@/components/ui/Badge";
import { Wallet, Leaf, LogOut, ChevronDown } from "lucide-react";
import { useState } from "react";
import clsx from "clsx";

export default function Navbar() {
  const { isConnected, address, connectWallet, disconnectWallet, isConnecting, userData } =
    useWeb3();
  const [menuOpen, setMenuOpen] = useState(false);

  const navLinks = [
    { href: "/marketplace/crops",    label: "Crops"    },
    { href: "/marketplace/products", label: "Products" },
    { href: "/orders",               label: "Orders"   },
    { href: "/transactions",         label: "Transactions" },
  ];

  return (
    <header className="sticky top-0 z-40 bg-white/80 backdrop-blur border-b border-gray-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2 font-bold text-xl text-primary-700">
            <Leaf className="w-6 h-6" />
            <span>AgriChain</span>
          </Link>

          {/* Nav Links */}
          <nav className="hidden md:flex items-center gap-6">
            {navLinks.map((l) => (
              <Link
                key={l.href}
                href={l.href}
                className="text-sm font-medium text-gray-600 hover:text-primary-600 transition-colors"
              >
                {l.label}
              </Link>
            ))}
          </nav>

          {/* Right side */}
          <div className="flex items-center gap-3">
            {isConnected && address ? (
              <div className="relative">
                <button
                  onClick={() => setMenuOpen((v) => !v)}
                  className="flex items-center gap-2 px-3 py-2 rounded-xl border border-gray-200 hover:bg-gray-50 transition text-sm"
                >
                  <div className="w-7 h-7 rounded-full bg-primary-100 flex items-center justify-center">
                    <Wallet className="w-4 h-4 text-primary-600" />
                  </div>
                  <span className="font-medium text-gray-700">{shortAddress(address)}</span>
                  {userData && (
                    <Badge
                      label={ROLES[userData.Role]}
                      className="bg-primary-100 text-primary-700"
                    />
                  )}
                  <ChevronDown className="w-4 h-4 text-gray-400" />
                </button>

                {menuOpen && (
                  <div className="absolute right-0 mt-2 w-64 bg-white rounded-2xl shadow-lg border border-gray-100 py-2 z-50">
                    {userData && (
                      <div className="px-4 py-3 border-b border-gray-100">
                        <p className="font-semibold text-gray-900">{userData.Name}</p>
                        <p className="text-xs text-gray-500 mt-0.5">
                          {VERIFICATION_STATUS[userData.verificationStatus]}
                        </p>
                      </div>
                    )}
                    <div className="py-1">
                      {[
                        { href: "/profile",       label: "My Profile"       },
                        { href: "/documents",     label: "Documents"        },
                        { href: "/orders",        label: "My Orders"        },
                        { href: "/complaints",    label: "Complaints"       },
                        { href: "/admin",         label: "Admin Panel"      },
                      ].map((item) => (
                        <Link
                          key={item.href}
                          href={item.href}
                          onClick={() => setMenuOpen(false)}
                          className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                        >
                          {item.label}
                        </Link>
                      ))}
                    </div>
                    <div className="border-t border-gray-100 pt-1">
                      <button
                        onClick={() => { disconnectWallet(); setMenuOpen(false); }}
                        className="w-full flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50"
                      >
                        <LogOut className="w-4 h-4" /> Disconnect
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <Button onClick={connectWallet} loading={isConnecting} size="sm">
                <Wallet className="w-4 h-4" /> Connect Wallet
              </Button>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
