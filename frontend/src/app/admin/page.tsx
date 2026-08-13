"use client";
import { useState, useEffect, useCallback } from "react";
import { ethers } from "ethers";
import { useWeb3 } from "@/context/Web3Context";
import {
  ROLES, VERIFICATION_STATUS, statusColor,
  parseContractError, shortAddress,
} from "@/lib/helpers";
import Button from "@/components/ui/Button";
import Input from "@/components/ui/Input";
import { Card, CardHeader } from "@/components/ui/Card";
import Badge from "@/components/ui/Badge";
import toast from "react-hot-toast";
import {
  Shield, UserCheck, UserX, CheckCircle,
  XCircle, Settings, RefreshCw, Users,
} from "lucide-react";
import Link from "next/link";
import { CONTRACT_ADDRESSES, DEPLOYMENT_BLOCK } from "@/config/contracts";
import { UserManagementABI } from "@/config/abis";

// ─── Types ────────────────────────────────────────────────────
interface PendingUser {
  address:            string;
  name:               string;
  role:               number;
  verificationStatus: number;
}

export default function AdminPage() {
  const { contracts, userData, isConnected, provider } = useWeb3();
  const isAdmin = userData?.Role === 5;

  // ── User list state ──────────────────────────────────────────
  const [pendingUsers, setPendingUsers] = useState<PendingUser[]>([]);
  const [loadingUsers, setLoadingUsers] = useState(false);
  const [txLoading,    setTxLoading]    = useState<string | null>(null);

  // ── Complaint state ──────────────────────────────────────────
  const [reportId, setReportId] = useState("");

  // ── Add admin form ───────────────────────────────────────────
  const [adminForm, setAdminForm] = useState({
    name: "", contact: "", cnic: "", city: "", country: "", address: "",
  });

  // ── Fetch pending users from events ─────────────────────────
  // Strategy:
  //   1. Read all UserSignedUp events  → get (address, name, role)
  //   2. Read all userRoleVerificationStatusUpdated events → get latest status per address
  //   3. Merge and show users whose latest status is PENDING(0) or APPLIED(1)

  // Helper: fetch all logs for a topic in 9000-block chunks (MetaMask limit = 10000)
  const fetchAllLogs = useCallback(
    async (
      p: ethers.BrowserProvider,
      contractAddr: string,
      topic: string,
      fromBlock: number,
      toBlock: number
    ): Promise<ethers.Log[]> => {
      const CHUNK   = 9000;
      const results: ethers.Log[] = [];
      for (let from = fromBlock; from <= toBlock; from += CHUNK) {
        const to   = Math.min(from + CHUNK - 1, toBlock);
        const logs = await p.getLogs({
          address:   contractAddr,
          topics:    [topic],
          fromBlock: from,
          toBlock:   to,
        });
        results.push(...logs);
      }
      return results;
    },
    []
  );

  const fetchPendingUsers = useCallback(async () => {
    if (!provider) return;
    setLoadingUsers(true);
    try {
      const iface = new ethers.Interface(UserManagementABI);

      const signUpTopic  = ethers.id("UserSignedUp(address,string,uint8,uint256)");
      const statusTopic  = ethers.id("userRoleVerificationStatusUpdated(address,uint8,uint8,uint256)");
      const contractAddr = CONTRACT_ADDRESSES.UserManagement;
      const latestBlock  = await provider.getBlockNumber();

      const [signUpLogs, statusLogs] = await Promise.all([
        fetchAllLogs(provider, contractAddr, signUpTopic,  DEPLOYMENT_BLOCK, latestBlock),
        fetchAllLogs(provider, contractAddr, statusTopic, DEPLOYMENT_BLOCK, latestBlock),
      ]);

      console.log(`Fetched ${signUpLogs.length} UserSignedUp events`);
      console.log(`Fetched ${statusLogs.length} statusUpdated events`);

      // Build latest verification status per address
      const latestStatus: Record<string, number> = {};
      for (const log of statusLogs) {
        const decoded = iface.parseLog({ topics: [...log.topics], data: log.data });
        if (!decoded) continue;
        const userAddr = decoded.args[0] as string;
        const status   = Number(decoded.args[2]);
        latestStatus[userAddr.toLowerCase()] = status;
      }

      // Build pending user list
      const users: PendingUser[] = [];
      const seen = new Set<string>();

      for (const log of signUpLogs) {
        const decoded = iface.parseLog({ topics: [...log.topics], data: log.data });
        if (!decoded) continue;
        const userAddr = decoded.args[0] as string;
        const name     = decoded.args[1] as string;
        const role     = Number(decoded.args[2]);
        const key      = userAddr.toLowerCase();

        if (seen.has(key)) continue;
        seen.add(key);

        const status = latestStatus[key] ?? 0;
        if (status === 0 || status === 1) {
          users.push({ address: userAddr, name, role, verificationStatus: status });
        }
      }

      console.log(`Found ${users.length} pending users`);
      setPendingUsers(users);
    } catch (err: any) {
      console.error("Failed to fetch users:", err);
      toast.error(err?.message?.slice(0, 120) ?? "Could not load pending users.");
    } finally {
      setLoadingUsers(false);
    }
  }, [provider, fetchAllLogs]);

  useEffect(() => {
    if (isAdmin) fetchPendingUsers();
  }, [isAdmin, fetchPendingUsers]);

  // ── Verify user ──────────────────────────────────────────────
  async function handleVerify(addr: string) {
    if (!contracts.documentRegistry) return;
    setTxLoading(`verify-${addr}`);
    try {
      const tx = await contracts.documentRegistry.verifyUser(addr);
      toast.loading("Verifying…", { id: `v-${addr}` });
      await tx.wait();
      toast.success("User verified!", { id: `v-${addr}` });
      fetchPendingUsers();
    } catch (err) {
      toast.error(parseContractError(err), { id: `v-${addr}` });
    } finally { setTxLoading(null); }
  }

  // ── Reject user ──────────────────────────────────────────────
  async function handleReject(addr: string) {
    if (!contracts.documentRegistry) return;
    setTxLoading(`reject-${addr}`);
    try {
      const tx = await contracts.documentRegistry.rejectUser(addr);
      toast.loading("Rejecting…", { id: `r-${addr}` });
      await tx.wait();
      toast.success("User rejected.", { id: `r-${addr}` });
      fetchPendingUsers();
    } catch (err) {
      toast.error(parseContractError(err), { id: `r-${addr}` });
    } finally { setTxLoading(null); }
  }

  // ── Resolve complaint ────────────────────────────────────────
  async function handleResolveReport(action: "buyer" | "seller" | "reject") {
    if (!contracts.complaintRegistry || !reportId) return;
    setTxLoading(`resolve-${action}`);
    try {
      const id = BigInt(reportId);
      let tx;
      if (action === "buyer")  tx = await contracts.complaintRegistry.resolveReportToBuyer(id);
      if (action === "seller") tx = await contracts.complaintRegistry.resolveReportToSeller(id);
      if (action === "reject") tx = await contracts.complaintRegistry.rejectReport(id);
      toast.loading("Processing…", { id: "resolve" });
      await tx!.wait();
      toast.success("Report updated.", { id: "resolve" });
      setReportId("");
    } catch (err) {
      toast.error(parseContractError(err), { id: "resolve" });
    } finally { setTxLoading(null); }
  }

  // ── Add admin ────────────────────────────────────────────────
  async function handleAddAdmin(e: React.FormEvent) {
    e.preventDefault();
    if (!contracts.userManagement) return;
    setTxLoading("addAdmin");
    try {
      const tx = await contracts.userManagement.signUpAsAdmin(
        adminForm.name, adminForm.contact, adminForm.cnic,
        adminForm.city, adminForm.country, adminForm.address
      );
      toast.loading("Adding admin…", { id: "addAdmin" });
      await tx.wait();
      toast.success("Admin added.", { id: "addAdmin" });
      setAdminForm({ name: "", contact: "", cnic: "", city: "", country: "", address: "" });
    } catch (err) {
      toast.error(parseContractError(err), { id: "addAdmin" });
    } finally { setTxLoading(null); }
  }

  // ── Guards ───────────────────────────────────────────────────
  if (!isConnected) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <p className="text-gray-500">Connect wallet to access admin panel.</p>
    </div>
  );

  if (!isAdmin) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <Shield className="w-12 h-12 text-gray-300 mx-auto mb-4" />
      <h2 className="text-xl font-semibold text-gray-700 mb-2">Admin Only</h2>
      <p className="text-gray-500">You need an Admin role to access this page.</p>
      <Link href="/" className="mt-4 inline-block">
        <Button variant="outline">Go Home</Button>
      </Link>
    </div>
  );

  // ── Render ───────────────────────────────────────────────────
  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-3">
          <Shield className="w-9 h-9 text-primary-600" />
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Admin Panel</h1>
            <p className="text-gray-500 mt-0.5">Manage users, verifications, and disputes</p>
          </div>
        </div>
      </div>

      {/* ── Pending Verifications ── */}
      <Card className="mb-6">
        <CardHeader>
          <div className="flex items-center justify-between">
            <h2 className="font-semibold flex items-center gap-2 text-lg">
              <Users className="w-5 h-5 text-primary-600" />
              Pending Verifications
              {pendingUsers.length > 0 && (
                <span className="ml-2 px-2 py-0.5 rounded-full bg-yellow-100 text-yellow-700 text-xs font-bold">
                  {pendingUsers.length}
                </span>
              )}
            </h2>
            <Button
              size="sm" variant="outline"
              onClick={fetchPendingUsers}
              loading={loadingUsers}
            >
              <RefreshCw className="w-4 h-4" /> Refresh
            </Button>
          </div>
        </CardHeader>

        {loadingUsers ? (
          <div className="space-y-3">
            {[1, 2, 3].map(i => (
              <div key={i} className="h-16 bg-gray-100 rounded-xl animate-pulse" />
            ))}
          </div>
        ) : pendingUsers.length === 0 ? (
          <div className="text-center py-10 text-gray-400">
            <UserCheck className="w-10 h-10 mx-auto mb-2 opacity-30" />
            <p className="text-sm">No users pending verification.</p>
          </div>
        ) : (
          <div className="space-y-3">
            {pendingUsers.map(user => (
              <div
                key={user.address}
                className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl border border-gray-100 bg-gray-50 hover:bg-white transition"
              >
                {/* User info */}
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-xl bg-primary-100 flex items-center justify-center font-bold text-primary-700 text-sm flex-shrink-0">
                    {user.name.charAt(0).toUpperCase()}
                  </div>
                  <div>
                    <p className="font-semibold text-gray-900">{user.name}</p>
                    <p className="text-xs text-gray-500 font-mono mt-0.5">{shortAddress(user.address)}</p>
                    <p className="text-xs text-gray-400 font-mono">{user.address}</p>
                  </div>
                </div>

                {/* Badges + actions */}
                <div className="flex items-center gap-3 flex-wrap">
                  <Badge
                    label={ROLES[user.role]}
                    className="bg-blue-100 text-blue-700"
                  />
                  <Badge
                    label={VERIFICATION_STATUS[user.verificationStatus]}
                    className={statusColor(user.verificationStatus, VERIFICATION_STATUS)}
                  />
                  <Button
                    size="sm"
                    onClick={() => handleVerify(user.address)}
                    loading={txLoading === `verify-${user.address}`}
                    disabled={user.verificationStatus !== 1}
                    title={user.verificationStatus !== 1 ? "User must upload documents first (status: Applied)" : ""}
                  >
                    <CheckCircle className="w-4 h-4" /> Verify
                  </Button>
                  <Button
                    size="sm"
                    variant="danger"
                    onClick={() => handleReject(user.address)}
                    loading={txLoading === `reject-${user.address}`}
                    disabled={user.verificationStatus !== 1}
                  >
                    <XCircle className="w-4 h-4" /> Reject
                  </Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

        {/* ── Resolve Complaint ── */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <h2 className="font-semibold flex items-center gap-2">
              <Settings className="w-5 h-5 text-yellow-500" /> Resolve Complaint
            </h2>
          </CardHeader>
          <div className="flex flex-col sm:flex-row gap-3 items-end">
            <Input
              label="Report ID" type="number" min="1" placeholder="1"
              value={reportId}
              onChange={e => setReportId(e.target.value)}
              className="w-40"
            />
            <div className="flex gap-2 flex-wrap">
              <Button
                size="sm"
                onClick={() => handleResolveReport("buyer")}
                loading={txLoading === "resolve-buyer"}
              >
                Resolve → Buyer
              </Button>
              <Button
                size="sm" variant="secondary"
                onClick={() => handleResolveReport("seller")}
                loading={txLoading === "resolve-seller"}
              >
                Resolve → Seller
              </Button>
              <Button
                size="sm" variant="danger"
                onClick={() => handleResolveReport("reject")}
                loading={txLoading === "resolve-reject"}
              >
                Reject Report
              </Button>
            </div>
          </div>
        </Card>

        {/* ── Add Admin ── */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <h2 className="font-semibold flex items-center gap-2">
              <Shield className="w-5 h-5 text-blue-500" /> Add Admin
            </h2>
          </CardHeader>
          <form onSubmit={handleAddAdmin} className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {[
              { key: "name",    label: "Name",    ph: "Ali Ahmad"        },
              { key: "contact", label: "Contact", ph: "+92..."           },
              { key: "cnic",    label: "CNIC",    ph: "00000-0000000-0"  },
              { key: "city",    label: "City",    ph: "Karachi"          },
              { key: "country", label: "Country", ph: "Pakistan"         },
              { key: "address", label: "Wallet",  ph: "0x..."            },
            ].map(f => (
              <Input
                key={f.key}
                label={f.label}
                placeholder={f.ph}
                value={(adminForm as any)[f.key]}
                onChange={e => setAdminForm(p => ({ ...p, [f.key]: e.target.value }))}
                required
              />
            ))}
            <div className="sm:col-span-2 lg:col-span-3">
              <Button type="submit" loading={txLoading === "addAdmin"}>
                Add Admin
              </Button>
            </div>
          </form>
        </Card>

      </div>
    </div>
  );
}
