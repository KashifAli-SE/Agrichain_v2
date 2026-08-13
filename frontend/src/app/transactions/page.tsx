"use client";
import { useState, useEffect, useCallback } from "react";
import { useWeb3 } from "@/context/Web3Context";
import { parseContractError, shortAddress, formatEth } from "@/lib/helpers";
import { Card } from "@/components/ui/Card";
import Button from "@/components/ui/Button";
import Modal from "@/components/ui/Modal";
import Input from "@/components/ui/Input";
import toast from "react-hot-toast";
import { ArrowLeftRight, Flag, RefreshCw } from "lucide-react";
import { ethers } from "ethers";

interface Transaction {
  transactionID: bigint; orderID: bigint;
  seller: string; buyer: string; amountTransferred: bigint;
}

export default function TransactionsPage() {
  const { contracts, address, isConnected } = useWeb3();
  const [txns,      setTxns]      = useState<Transaction[]>([]);
  const [loading,   setLoading]   = useState(true);
  const [showReport, setShowReport] = useState(false);
  const [reportTxn,  setReportTxn] = useState<Transaction | null>(null);
  const [reason,     setReason]    = useState("");
  const [rLoading,   setRLoading]  = useState(false);

  const fetchTxns = useCallback(async () => {
    if (!contracts.transactionManager || !address) return;
    setLoading(true);
    try {
      const ids: bigint[] = await contracts.transactionManager.getTransactionsByUser(address);
      const items: Transaction[] = await Promise.all(
        ids.map(id => contracts.transactionManager!.getTransactionByID(id))
      );
      setTxns(items.reverse());
    } catch {}
    finally { setLoading(false); }
  }, [contracts.transactionManager, address]);

  useEffect(() => { fetchTxns(); }, [fetchTxns]);

  async function handleReport(e: React.FormEvent) {
    e.preventDefault();
    if (!contracts.transactionManager || !reportTxn) return;
    setRLoading(true);
    try {
      const accused = reportTxn.seller.toLowerCase() === address?.toLowerCase()
        ? reportTxn.buyer : reportTxn.seller;
      const tx = await contracts.transactionManager.reportTransection(
        reportTxn.transactionID, accused, accused, reason
      );
      toast.loading("Submitting report…", { id: "report" });
      await tx.wait();
      toast.success("Transaction reported.", { id: "report" });
      setShowReport(false);
      setReason("");
    } catch (err) {
      toast.error(parseContractError(err), { id: "report" });
    } finally { setRLoading(false); }
  }

  if (!isConnected) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <p className="text-gray-500">Connect wallet to view transactions.</p>
    </div>
  );

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2">
            <ArrowLeftRight className="w-8 h-8 text-primary-600" /> Transactions
          </h1>
          <p className="text-gray-500 mt-1">On-chain payment history</p>
        </div>
        <Button variant="outline" size="sm" onClick={fetchTxns}>
          <RefreshCw className="w-4 h-4" /> Refresh
        </Button>
      </div>

      {loading ? (
        <div className="space-y-4">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-gray-100 p-6 animate-pulse h-24" />
          ))}
        </div>
      ) : txns.length === 0 ? (
        <div className="text-center py-20 text-gray-400">
          <ArrowLeftRight className="w-12 h-12 mx-auto mb-3 opacity-30" />
          <p>No transactions yet.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {txns.map(txn => {
            const isSeller = txn.seller.toLowerCase() === address?.toLowerCase();
            return (
              <Card key={txn.transactionID.toString()}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center font-bold text-sm ${isSeller ? "bg-green-100 text-green-700" : "bg-blue-100 text-blue-700"}`}>
                      {isSeller ? "IN" : "OUT"}
                    </div>
                    <div>
                      <p className="font-semibold text-gray-900">
                        Txn #{txn.transactionID.toString()} · Order #{txn.orderID.toString()}
                      </p>
                      <p className="text-sm text-gray-500">
                        {isSeller
                          ? `From buyer: ${shortAddress(txn.buyer)}`
                          : `To seller: ${shortAddress(txn.seller)}`}
                      </p>
                    </div>
                  </div>
                  <div className="text-right flex items-center gap-3">
                    <div>
                      <p className={`font-bold text-lg ${isSeller ? "text-green-600" : "text-gray-700"}`}>
                        {isSeller ? "+" : ""}{formatEth(txn.amountTransferred)} ETH
                      </p>
                    </div>
                    <Button size="sm" variant="ghost"
                      onClick={() => { setReportTxn(txn); setShowReport(true); }}>
                      <Flag className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      <Modal open={showReport} onClose={() => setShowReport(false)} title="Report Transaction" size="sm">
        <form onSubmit={handleReport} className="space-y-4">
          <p className="text-sm text-gray-500">
            Reporting transaction #{reportTxn?.transactionID.toString()} for order #{reportTxn?.orderID.toString()}
          </p>
          <Input label="Reason" placeholder="Describe the issue…" required
            value={reason} onChange={e => setReason(e.target.value)} />
          <Button type="submit" loading={rLoading} variant="danger" className="w-full">
            <Flag className="w-4 h-4" /> Submit Report
          </Button>
        </form>
      </Modal>
    </div>
  );
}
