"use client";
import { useState } from "react";
import { useWeb3 } from "@/context/Web3Context";
import { ROLES, VERIFICATION_STATUS, statusColor, parseContractError, shortAddress } from "@/lib/helpers";
import Button from "@/components/ui/Button";
import Input from "@/components/ui/Input";
import { Card, CardHeader } from "@/components/ui/Card";
import Badge from "@/components/ui/Badge";
import toast from "react-hot-toast";
import { User, Edit2, Trash2, CheckCircle } from "lucide-react";
import Link from "next/link";

export default function ProfilePage() {
  const { userData, isConnected, isRegistered, contracts, refreshUser, address, disconnectWallet } = useWeb3();
  const [editing, setEditing]   = useState(false);
  const [loading, setLoading]   = useState(false);
  const [form, setForm]         = useState({ name: "", contact: "", city: "" });

  function startEdit() {
    if (!userData) return;
    setForm({ name: userData.Name, contact: userData.contactNumber, city: userData.city });
    setEditing(true);
  }

  async function handleUpdate(e: React.FormEvent) {
    e.preventDefault();
    if (!contracts.userManagement) return;
    setLoading(true);
    try {
      const tx = await contracts.userManagement.updateAccount(form.name, form.contact, form.city);
      toast.loading("Updating…", { id: "update" });
      await tx.wait();
      toast.success("Profile updated!", { id: "update" });
      await refreshUser();
      setEditing(false);
    } catch (err) {
      toast.error(parseContractError(err), { id: "update" });
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete() {
    if (!contracts.userManagement) return;
    if (!confirm("Are you sure? This will permanently delete your on-chain account.")) return;
    setLoading(true);
    try {
      const tx = await contracts.userManagement.deleteAccount();
      toast.loading("Deleting account…", { id: "delete" });
      await tx.wait();
      toast.success("Account deleted.", { id: "delete" });
      disconnectWallet();
    } catch (err) {
      toast.error(parseContractError(err), { id: "delete" });
    } finally {
      setLoading(false);
    }
  }

  if (!isConnected) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <p className="text-gray-500">Connect your wallet to view your profile.</p>
    </div>
  );

  if (!isRegistered) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <p className="text-gray-500 mb-4">You don't have an account yet.</p>
      <Link href="/register"><Button>Create Account</Button></Link>
    </div>
  );

  return (
    <div className="max-w-2xl mx-auto px-4 py-12">
      <h1 className="text-3xl font-bold mb-8 text-gray-900">My Profile</h1>

      {!editing ? (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-2xl bg-primary-100 flex items-center justify-center">
                  <User className="w-7 h-7 text-primary-600" />
                </div>
                <div>
                  <h2 className="text-xl font-bold text-gray-900">{userData?.Name}</h2>
                  <div className="flex items-center gap-2 mt-1">
                    <Badge label={ROLES[userData?.Role ?? 0]} className="bg-primary-100 text-primary-700" />
                    <Badge
                      label={VERIFICATION_STATUS[userData?.verificationStatus ?? 0]}
                      className={statusColor(userData?.verificationStatus ?? 0, VERIFICATION_STATUS)}
                    />
                  </div>
                </div>
              </div>
              <Button variant="outline" size="sm" onClick={startEdit}>
                <Edit2 className="w-4 h-4" /> Edit
              </Button>
            </div>
          </CardHeader>

          <div className="grid grid-cols-2 gap-4 text-sm">
            {[
              { label: "Wallet",  value: shortAddress(address ?? "") },
              { label: "Contact", value: userData?.contactNumber },
              { label: "CNIC",    value: userData?.CNIC },
              { label: "City",    value: userData?.city },
              { label: "Country", value: userData?.Country },
            ].map((row) => (
              <div key={row.label}>
                <p className="text-gray-400 text-xs mb-0.5">{row.label}</p>
                <p className="font-medium text-gray-900">{row.value}</p>
              </div>
            ))}
          </div>

          {userData?.verificationStatus === 0 && (
            <div className="mt-6 p-4 bg-yellow-50 rounded-xl border border-yellow-200 flex items-center gap-3">
              <CheckCircle className="w-5 h-5 text-yellow-500 flex-shrink-0" />
              <div>
                <p className="text-sm font-medium text-yellow-800">Upload documents to get verified</p>
                <Link href="/documents" className="text-xs text-yellow-600 underline">Go to Documents →</Link>
              </div>
            </div>
          )}

          <div className="mt-6 pt-4 border-t border-gray-100">
            <Button variant="danger" size="sm" onClick={handleDelete} loading={loading}>
              <Trash2 className="w-4 h-4" /> Delete Account
            </Button>
          </div>
        </Card>
      ) : (
        <Card>
          <h2 className="text-lg font-semibold mb-5">Edit Profile</h2>
          <form onSubmit={handleUpdate} className="space-y-4">
            <Input label="Full Name"       value={form.name}    onChange={e => setForm(p => ({...p, name:    e.target.value}))} required />
            <Input label="Contact Number"  value={form.contact} onChange={e => setForm(p => ({...p, contact: e.target.value}))} required />
            <Input label="City"            value={form.city}    onChange={e => setForm(p => ({...p, city:    e.target.value}))} required />
            <div className="flex gap-3">
              <Button type="submit" loading={loading}>Save Changes</Button>
              <Button type="button" variant="ghost" onClick={() => setEditing(false)}>Cancel</Button>
            </div>
          </form>
        </Card>
      )}
    </div>
  );
}
