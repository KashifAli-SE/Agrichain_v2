"use client";
import { useState, useEffect, useCallback } from "react";
import { ethers } from "ethers";
import { useWeb3 } from "@/context/Web3Context";
import {
  ORDER_STATUS, PRODUCT_TYPE, statusColor,
  parseContractError, shortAddress,
} from "@/lib/helpers";
import Button from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import Badge from "@/components/ui/Badge";
import Modal from "@/components/ui/Modal";
import toast from "react-hot-toast";
import {
  ClipboardList, CreditCard, CheckCircle,
  RefreshCw, AlertTriangle, Loader2, ArrowRight,
} from "lucide-react";
import Link from "next/link";

interface Order {
  orderID:     bigint;
  buyer:       string;
  seller:      string;
  productId:   bigint;
  quantity:    bigint;
  pricePerUnit:bigint;
  amountToPay: bigint;
  Type:        number;
  orderStatus: number;
}

// Order status flow:
//  0 = PLACED   → buyer must pay
//  1 = PAID     → buyer must confirm receipt
//  2 = CONFIRMED→ treasury releases payment (auto)
//  3 = COMPLETED

export default function OrdersPage() {
  const { contracts, address, isConnected, isRegistered, provider } = useWeb3();

  const [orders,    setOrders]   = useState<Order[]>([]);
  const [loading,   setLoading]  = useState(true);
  const [txId,      setTxId]     = useState<bigint | null>(null);

  // Pay modal state
  const [payModal,      setPayModal]      = useState(false);
  const [payOrder,      setPayOrder]      = useState<Order | null>(null);
  const [ethRequired,   setEthRequired]   = useState<bigint | null>(null);
  const [ethLoading,    setEthLoading]    = useState(false);

  // ── Fetch orders ─────────────────────────────────────────────
  const fetchOrders = useCallback(async () => {
    if (!contracts.orderManager || !address) return;
    setLoading(true);
    try {
      const all: Order[] = await contracts.orderManager.getOrders();
      const mine = all
        .filter(o =>
          o.buyer.toLowerCase()  === address.toLowerCase() ||
          o.seller.toLowerCase() === address.toLowerCase()
        )
        .reverse();
      setOrders(mine);
    } catch (err) {
      console.error("fetchOrders:", err);
    } finally {
      setLoading(false);
    }
  }, [contracts.orderManager, address]);

  useEffect(() => { fetchOrders(); }, [fetchOrders]);

  // ── Open pay modal — fetch required ETH from contract ────────
  async function openPayModal(order: Order) {
    setPayOrder(order);
    setEthRequired(null);
    setPayModal(true);
    setEthLoading(true);
    try {
      // Treasury.payForOrder internally calls getUSDtoEth(orderAmount, priceFeed)
      // We replicate the same call to show the user the exact amount needed.
      // We use eth_call with a 2% buffer so the tx doesn't fail on price movement.
      const usdAmount: bigint = await contracts.orderManager!.getOrderAmount(order.orderID);

      // Use the PriceConverter library logic:
      // ethAmount = (usdAmount * 1e26) / ethPrice
      // We get ethPrice from the pricefeed via a static call to Treasury
      // Simplest: just send the call with a high value and the contract refunds excess.
      // But we still need an estimate to show the user.
      // Use a read-only JSON-RPC provider to query Chainlink price feed directly.
      if (!provider) throw new Error("No provider");

      // Chainlink ETH/USD Sepolia: 0x694AA1769357215DE4FAC081bf1f309aDC325306
      const priceFeedAddr = await contracts.treasury!.getPriceFeed();
      const priceFeedABI  = ["function latestRoundData() view returns (uint80,int256,uint256,uint256,uint80)"];
      const priceFeed     = new ethers.Contract(priceFeedAddr, priceFeedABI, provider);
      const [, answer]    = await priceFeed.latestRoundData(); // int256, 8 decimals
      const ethPrice      = BigInt(answer); // e.g. 250000000000 = $2500.00000000

      // ethAmount = (usdAmount * 1e26) / ethPrice
      const ethAmount = (usdAmount * BigInt("100000000000000000000000000")) / ethPrice;

      // Add 2% buffer so user isn't underpaying due to price movement
      const withBuffer = ethAmount * BigInt(102) / BigInt(100);
      setEthRequired(withBuffer);
    } catch (err) {
      console.error("ETH estimate failed:", err);
      // Fallback: use a rough estimate — user can still proceed
      // We'll let the contract calculate it and just use a safe large buffer
      setEthRequired(null);
    } finally {
      setEthLoading(false);
    }
  }

  // ── Execute payment ──────────────────────────────────────────
  async function handlePay() {
    if (!contracts.treasury || !payOrder) return;
    setTxId(payOrder.orderID);
    const id = `pay-${payOrder.orderID}`;
    try {
      // If we couldn't estimate, send 0.1 ETH as a safe upper bound
      // The contract refunds any excess above the required amount
      const valueToSend = ethRequired ?? ethers.parseEther("0.1");

      toast.loading("Sending payment to escrow…", { id });
      const tx = await contracts.treasury.payForOrder(
        payOrder.orderID,
        { value: valueToSend }
      );
      await tx.wait();
      toast.success("Payment held in escrow. Confirm receipt when delivered.", { id });
      setPayModal(false);
      fetchOrders();
    } catch (err) {
      toast.error(parseContractError(err), { id });
    } finally {
      setTxId(null);
    }
  }

  // ── Confirm receipt ──────────────────────────────────────────
  async function handleConfirm(order: Order) {
    if (!contracts.orderManager) return;
    setTxId(order.orderID);
    const id = `conf-${order.orderID}`;
    try {
      toast.loading("Confirming receipt…", { id });
      const tx = await contracts.orderManager.confirmOrder(order.orderID);
      await tx.wait();
      toast.success("Receipt confirmed! Payment released to seller.", { id });
      fetchOrders();
    } catch (err) {
      toast.error(parseContractError(err), { id });
    } finally {
      setTxId(null); }
  }

  // ── Guards ───────────────────────────────────────────────────
  if (!isConnected) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <p className="text-gray-500">Connect your wallet to view orders.</p>
    </div>
  );

  if (!isRegistered) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <p className="text-gray-500 mb-4">Register first to access orders.</p>
      <Link href="/register"><Button>Register</Button></Link>
    </div>
  );

  // ── Step indicator helper ────────────────────────────────────
  const steps = ["Placed", "Paid", "Confirmed", "Completed"];

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">

      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2">
            <ClipboardList className="w-8 h-8 text-primary-600" /> My Orders
          </h1>
          <p className="text-gray-500 mt-1">Track and manage your orders</p>
        </div>
        <Button variant="outline" size="sm" onClick={fetchOrders}>
          <RefreshCw className="w-4 h-4" /> Refresh
        </Button>
      </div>

      {/* Order flow explainer */}
      <div className="flex items-center gap-2 mb-8 overflow-x-auto pb-2">
        {steps.map((s, i) => (
          <div key={s} className="flex items-center gap-2 flex-shrink-0">
            <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white border border-gray-200 text-xs font-medium text-gray-600">
              <span className="w-4 h-4 rounded-full bg-primary-100 text-primary-700 flex items-center justify-center text-xs font-bold">
                {i + 1}
              </span>
              {s}
            </div>
            {i < steps.length - 1 && <ArrowRight className="w-3 h-3 text-gray-300 flex-shrink-0" />}
          </div>
        ))}
      </div>

      {/* Orders list */}
      {loading ? (
        <div className="space-y-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-gray-100 p-6 animate-pulse h-32" />
          ))}
        </div>
      ) : orders.length === 0 ? (
        <div className="text-center py-20 text-gray-400">
          <ClipboardList className="w-12 h-12 mx-auto mb-3 opacity-30" />
          <p className="mb-4">No orders yet. Browse the marketplace to place one.</p>
          <div className="flex gap-3 justify-center">
            <Link href="/marketplace/crops">
              <Button size="sm" variant="outline">Crop Market</Button>
            </Link>
            <Link href="/marketplace/products">
              <Button size="sm" variant="outline">Product Market</Button>
            </Link>
          </div>
        </div>
      ) : (
        <div className="space-y-4">
          {orders.map(order => {
            const isBuyer   = order.buyer.toLowerCase()  === address?.toLowerCase();
            const isSeller  = order.seller.toLowerCase() === address?.toLowerCase();
            const isLoading = txId === order.orderID;
            const status    = Number(order.orderStatus);

            return (
              <Card key={order.orderID.toString()}>
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">

                  {/* Left: order info */}
                  <div className="flex items-start gap-4">
                    <div className="w-12 h-12 rounded-xl bg-primary-50 flex items-center justify-center font-bold text-primary-700 text-sm flex-shrink-0">
                      #{order.orderID.toString()}
                    </div>
                    <div className="space-y-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="font-semibold text-gray-900">
                          {PRODUCT_TYPE[order.Type]} Order
                        </span>
                        <Badge
                          label={ORDER_STATUS[status]}
                          className={statusColor(status, ORDER_STATUS)}
                        />
                        <Badge
                          label={isBuyer ? "You are Buyer" : "You are Seller"}
                          className="bg-blue-100 text-blue-700"
                        />
                      </div>

                      <div className="text-sm text-gray-500 flex flex-wrap gap-x-4 gap-y-0.5">
                        <span>Qty: <strong className="text-gray-700">{order.quantity.toString()}</strong></span>
                        <span>Price: <strong className="text-gray-700">${order.pricePerUnit.toString()}/unit</strong></span>
                        <span>Total: <strong className="text-primary-700">${order.amountToPay.toString()}</strong></span>
                      </div>

                      <div className="text-xs text-gray-400">
                        {isBuyer
                          ? `Seller: ${shortAddress(order.seller)}`
                          : `Buyer: ${shortAddress(order.buyer)}`
                        }
                      </div>

                      {/* Progress bar */}
                      <div className="flex gap-1 mt-2">
                        {steps.map((s, i) => (
                          <div
                            key={s}
                            className={`h-1.5 flex-1 rounded-full transition-colors ${
                              i <= Number(status) ? "bg-primary-500" : "bg-gray-200"
                            }`}
                          />
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Right: action buttons */}
                  <div className="flex gap-2 flex-shrink-0 flex-wrap">

                    {/* STEP 1 → PAY: shown to buyer when order is PLACED */}
                    {isBuyer && Number(status) === 0 && (
                      <Button
                        size="sm"
                        onClick={() => openPayModal(order)}
                        loading={isLoading}
                      >
                        <CreditCard className="w-4 h-4" /> Pay Now
                      </Button>
                    )}

                    {/* STEP 2 → CONFIRM: shown to buyer when order is PAID */}
                    {isBuyer && Number(status) === 1 && (
                      <Button
                        size="sm"
                        variant="secondary"
                        onClick={() => handleConfirm(order)}
                        loading={isLoading}
                      >
                        <CheckCircle className="w-4 h-4" /> Confirm Receipt
                      </Button>
                    )}

                    {/* Seller: awaiting states */}
                    {isSeller && Number(status) === 0 && (
                      <span className="text-xs text-gray-400 self-center">Awaiting buyer payment…</span>
                    )}
                    {isSeller && Number(status) === 1 && (
                      <span className="text-xs text-yellow-600 self-center font-medium">Ship the order — awaiting buyer confirmation</span>
                    )}
                    {Number(status) === 3 && (
                      <span className="text-xs text-green-600 self-center font-medium">✓ Completed</span>
                    )}

                    {/* Dispute */}
                    {(isBuyer || isSeller) && Number(status) >= 1 && Number(status) < 3 && (
                      <Link
                        href={`/complaints?orderId=${order.orderID}&buyer=${order.buyer}&seller=${order.seller}`}
                      >
                        <Button size="sm" variant="ghost">
                          <AlertTriangle className="w-4 h-4" /> Dispute
                        </Button>
                      </Link>
                    )}
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* ── Pay Modal ── */}
      <Modal
        open={payModal}
        onClose={() => { if (txId === null) setPayModal(false); }}
        title="Pay for Order"
        size="sm"
      >
        {payOrder && (
          <div className="space-y-5">

            {/* Order summary */}
            <div className="p-4 bg-gray-50 rounded-xl space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-500">Order</span>
                <span className="font-semibold">#{payOrder.orderID.toString()}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Type</span>
                <span>{PRODUCT_TYPE[payOrder.Type]}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Quantity</span>
                <span>{payOrder.quantity.toString()} units</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Price/unit</span>
                <span>${payOrder.pricePerUnit.toString()}</span>
              </div>
              <div className="flex justify-between border-t border-gray-200 pt-2 mt-2">
                <span className="font-medium text-gray-700">Total (USD)</span>
                <span className="font-bold text-gray-900">${payOrder.amountToPay.toString()}</span>
              </div>
            </div>

            {/* ETH amount */}
            <div className="p-4 bg-primary-50 rounded-xl border border-primary-100">
              <p className="text-xs text-primary-600 mb-1 font-medium">Amount to send (ETH)</p>
              {ethLoading ? (
                <div className="flex items-center gap-2 text-primary-700">
                  <Loader2 className="w-4 h-4 animate-spin" />
                  <span className="text-sm">Fetching live ETH price…</span>
                </div>
              ) : ethRequired !== null ? (
                <div>
                  <p className="text-2xl font-bold text-primary-700">
                    {parseFloat(ethers.formatEther(ethRequired)).toFixed(6)} ETH
                  </p>
                  <p className="text-xs text-primary-500 mt-0.5">
                    Includes 2% buffer for price movement. Unused ETH is refunded.
                  </p>
                </div>
              ) : (
                <div>
                  <p className="text-sm text-primary-700 font-medium">Could not fetch live price.</p>
                  <p className="text-xs text-primary-500 mt-0.5">
                    A safe amount will be sent. The contract will refund any excess.
                  </p>
                </div>
              )}
            </div>

            {/* Escrow info */}
            <div className="flex gap-2 p-3 bg-yellow-50 rounded-xl border border-yellow-100 text-xs text-yellow-700">
              <AlertTriangle className="w-4 h-4 flex-shrink-0 mt-0.5" />
              <p>
                Funds go into the <strong>escrow Treasury</strong> — not directly to the seller.
                Payment is only released when you confirm receipt of the order.
              </p>
            </div>

            {/* Seller */}
            <div className="text-xs text-gray-400">
              Seller: <span className="font-mono">{payOrder.seller}</span>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <Button
                className="flex-1"
                onClick={handlePay}
                loading={txId === payOrder.orderID}
                disabled={ethLoading}
              >
                <CreditCard className="w-4 h-4" />
                {ethLoading ? "Loading…" : "Confirm Payment"}
              </Button>
              <Button
                variant="ghost"
                onClick={() => setPayModal(false)}
                disabled={txId !== null}
              >
                Cancel
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
