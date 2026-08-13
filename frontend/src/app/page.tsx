"use client";
import Link from "next/link";
import { useWeb3 } from "@/context/Web3Context";
import Button from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import {
  Leaf, ShoppingBag, Users, ShieldCheck,
  ArrowRight, Wheat, Store, UserCheck,
} from "lucide-react";

export default function HomePage() {
  const { isConnected, connectWallet, isConnecting, userData } = useWeb3();

  const features = [
    {
      icon: <Wheat className="w-7 h-7 text-primary-600" />,
      title: "Crop Marketplace",
      desc:  "Farmers list crops directly. Buyers purchase with transparent pricing and blockchain-backed proof.",
    },
    {
      icon: <Store className="w-7 h-7 text-earth-500" />,
      title: "Product Marketplace",
      desc:  "Shops list fertilizers, seeds, and pesticides. Farmers order what they need, when they need it.",
    },
    {
      icon: <UserCheck className="w-7 h-7 text-blue-500" />,
      title: "Identity Verification",
      desc:  "Document-based KYC with IPFS storage ensures every participant is verified before trading.",
    },
    {
      icon: <ShieldCheck className="w-7 h-7 text-purple-500" />,
      title: "Escrow Payments",
      desc:  "Funds held in the on-chain Treasury. Released automatically when orders are confirmed.",
    },
  ];

  const stats = [
    { label: "Smart Contracts", value: "8" },
    { label: "Network",         value: "Sepolia" },
    { label: "Language",        value: "Solidity 0.8.20" },
    { label: "Price Feed",      value: "Chainlink" },
  ];

  return (
    <div>
      {/* Hero */}
      <section className="relative overflow-hidden bg-gradient-to-br from-primary-700 via-primary-600 to-primary-800 text-white">
        <div className="absolute inset-0 opacity-10">
          {/* decorative blobs */}
          <div className="absolute top-0 left-1/4 w-96 h-96 bg-white rounded-full blur-3xl" />
          <div className="absolute bottom-0 right-1/4 w-64 h-64 bg-earth-300 rounded-full blur-3xl" />
        </div>
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-28 text-center">
          <div className="inline-flex items-center gap-2 bg-white/10 rounded-full px-4 py-1.5 text-sm mb-6">
            <Leaf className="w-4 h-4" /> Powered by Ethereum
          </div>
          <h1 className="text-5xl md:text-6xl font-extrabold leading-tight mb-6">
            Agricultural Supply Chain
            <br />
            <span className="text-earth-300">On the Blockchain</span>
          </h1>
          <p className="text-lg text-primary-100 max-w-2xl mx-auto mb-10">
            AgriChain connects farmers, buyers, and shopkeepers through a fully
            decentralized platform — transparent, trustless, and traceable.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            {isConnected ? (
              <>
                <Link href="/marketplace/crops">
                  <Button size="lg" variant="secondary">
                    Browse Marketplace <ArrowRight className="w-5 h-5" />
                  </Button>
                </Link>
                {!userData && (
                  <Link href="/register">
                    <Button size="lg" variant="outline" className="border-white text-white hover:bg-white/10">
                      Complete Registration
                    </Button>
                  </Link>
                )}
              </>
            ) : (
              <Button size="lg" variant="secondary" onClick={connectWallet} loading={isConnecting}>
                <ShoppingBag className="w-5 h-5" /> Connect Wallet to Start
              </Button>
            )}
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="bg-white border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
            {stats.map((s) => (
              <div key={s.label}>
                <p className="text-2xl font-bold text-primary-700">{s.value}</p>
                <p className="text-sm text-gray-500 mt-1">{s.label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div className="text-center mb-14">
          <h2 className="text-3xl font-bold text-gray-900">Everything in one platform</h2>
          <p className="text-gray-500 mt-3 max-w-xl mx-auto">
            From listing crops to releasing payments — AgriChain handles the entire
            agricultural commerce lifecycle on-chain.
          </p>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((f) => (
            <Card key={f.title} className="text-center hover:shadow-md transition-shadow">
              <div className="flex justify-center mb-4">
                <div className="p-3 bg-gray-50 rounded-2xl">{f.icon}</div>
              </div>
              <h3 className="font-semibold text-gray-900 mb-2">{f.title}</h3>
              <p className="text-sm text-gray-500 leading-relaxed">{f.desc}</p>
            </Card>
          ))}
        </div>
      </section>

      {/* How it works */}
      <section className="bg-primary-50 py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-gray-900 text-center mb-14">How it works</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              { step: "01", title: "Connect & Register", desc: "Connect your Web3 wallet and sign up with your role — Farmer, Buyer, or Shopkeeper." },
              { step: "02", title: "Get Verified", desc: "Upload your KYC documents (CNIC, Kisan Card, etc.) to IPFS and get verified by an admin." },
              { step: "03", title: "Start Trading", desc: "List crops or products, place orders, pay via the escrow Treasury, and confirm delivery." },
            ].map((item) => (
              <div key={item.step} className="flex gap-5">
                <div className="flex-shrink-0 w-12 h-12 rounded-2xl bg-primary-600 text-white flex items-center justify-center font-bold text-sm">
                  {item.step}
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 mb-1">{item.title}</h3>
                  <p className="text-sm text-gray-600 leading-relaxed">{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 text-center">
        <h2 className="text-3xl font-bold mb-4">Ready to get started?</h2>
        <p className="text-gray-500 mb-8 max-w-lg mx-auto">
          Join the AgriChain ecosystem and start trading agricultural goods
          with full transparency on Ethereum.
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link href="/marketplace/crops">
            <Button size="lg">Browse Crops <ArrowRight className="w-5 h-5" /></Button>
          </Link>
          <Link href="/register">
            <Button size="lg" variant="outline">Create Account</Button>
          </Link>
        </div>
      </section>
    </div>
  );
}
