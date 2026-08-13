"use client";
import { useState, useEffect, useCallback, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { useWeb3 } from "@/context/Web3Context";
import { REPORT_STATUS, statusColor, parseContractError } from "@/lib/helpers";
import Button from "@/components/ui/Button";
import Input from "@/components/ui/Input";
import { Card } from "@/components/ui/Card";
import Badge from "@/components/ui/Badge";
import toast from "react-hot-toast";
import { AlertTriangle, X, RefreshCw } from "lucide-react";

interface ReportItem { id: number; status: number; }

function ComplaintsInner() {
  const { contracts, isConnected, isRegistered, address } = useWeb3();
  const params = useSearchParams();

  const [reports,   setReports]  = useState<ReportItem[]>([]);
  const [loading,   setLoading]  = useState(false);
  const [txLoading, setTxLoading]= useState<number | null>(null);
  const [form, setForm] = useState({
    orderId: params.get("orderId") ?? "",
    buyer:   params.get("buyer")   ?? "",
    seller:  params.get("seller")  ?? "",
  });

  // Fetch reports by scanning events (simple approach: try IDs 1-50)
  const fetchReports = useCallback(async () => {
    if (!contracts.complaintRegistry || !address) return;
    setLoading(true);
    const found: ReportItem[] = [];
    try {
      for (let i = 1; i <= 50; i++) {
        try {
          const status = await contracts.complaintRegistry.getReportStatus(i);
          found.push({ id: i, status: Number(status) });
        } catch { break; }
      }
      setReports(found);
    } catch {}
    finally { setLoading(false); }
  }, [contracts.complaintRegistry, address]);

  useEffect(() => { fetchReports(); }, [fetchReports]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!contracts.complaintRegistry) return;
    setLoading(true);
    try {
      const tx = await contracts.complaintRegistry.submitReport(
        BigInt(form.orderId), form.buyer, form.seller
      );
      toast.loading("Filing complaint…", { id: "complaint" });
      await tx.wait();
      toast.success("Complaint filed successfully.", { id: "complaint" });
      setForm({ orderId: "", buyer: "", seller: "" });
      fetchReports();
    } catch (err) {
      toast.error(parseContractError(err), { id: "complaint" });
    } finally { setLoading(false); }
  }

  async function handleWithdraw(reportId: number) {
    if (!contracts.complaintRegistry) return;
    setTxLoading(reportId);
    try {
      const tx = await contracts.complaintRegistry.withDrawReport(reportId);
      toast.loading("Withdrawing…", { id: `wd-${reportId}` });
      await tx.wait();
      toast.success("Report withdrawn.", { id: `wd-${reportId}` });
      fetchReports();
    } catch (err) {
      toast.error(parseContractError(err), { id: `wd-${reportId}` });
    } finally { setTxLoading(null); }
  }

  if (!isConnected || !isRegistered) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <p className="text-gray-500">Connect wallet and register to file complaints.</p>
    </div>
  );

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2">
            <AlertTriangle className="w-8 h-8 text-yellow-500" /> Complaints
          </h1>
          <p className="text-gray-500 mt-1">File and track order disputes</p>
        </div>
        <Button variant="outline" size="sm" onClick={fetchReports}>
          <RefreshCw className="w-4 h-4" /> Refresh
        </Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* File complaint form */}
        <Card>
          <h2 className="text-lg font-semibold mb-5">File a Complaint</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              label="Order ID"
              type="number" min="1"
              value={form.orderId}
              onChange={e => setForm(p => ({ ...p, orderId: e.target.value }))}
              required
            />
            <Input
              label="Buyer Address"
              placeholder="0x..."
              value={form.buyer}
              onChange={e => setForm(p => ({ ...p, buyer: e.target.value }))}
              required
            />
            <Input
              label="Seller Address"
              placeholder="0x..."
              value={form.seller}
              onChange={e => setForm(p => ({ ...p, seller: e.target.value }))}
              required
            />
            <Button type="submit" loading={loading} className="w-full">
              <AlertTriangle className="w-4 h-4" /> Submit Complaint
            </Button>
          </form>
        </Card>

        {/* Reports list */}
        <div className="space-y-3">
          <h2 className="text-lg font-semibold">Filed Reports</h2>
          {reports.length === 0 ? (
            <p className="text-gray-400 text-sm">No reports found.</p>
          ) : (
            reports.map(r => (
              <Card key={r.id}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl bg-yellow-50 flex items-center justify-center text-sm font-bold text-yellow-700">
                      #{r.id}
                    </div>
                    <Badge
                      label={REPORT_STATUS[r.status]}
                      className={statusColor(r.status, REPORT_STATUS)}
                    />
                  </div>
                  {r.status === 0 && (
                    <Button size="sm" variant="ghost" loading={txLoading === r.id}
                      onClick={() => handleWithdraw(r.id)}>
                      <X className="w-4 h-4" /> Withdraw
                    </Button>
                  )}
                </div>
              </Card>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

export default function ComplaintsPage() {
  return (
    <Suspense>
      <ComplaintsInner />
    </Suspense>
  );
}
