"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useWeb3 } from "@/context/Web3Context";
import Button from "@/components/ui/Button";
import Input from "@/components/ui/Input";
import Select from "@/components/ui/Select";
import { Card } from "@/components/ui/Card";
import { parseContractError } from "@/lib/helpers";
import toast from "react-hot-toast";
import { UserPlus, Leaf } from "lucide-react";

export default function RegisterPage() {
  const { contracts, isConnected, connectWallet, refreshUser, isRegistered } = useWeb3();
  const router = useRouter();

  const [form, setForm] = useState({
    name:          "",
    role:          "1",
    contactNumber: "",
    cnic:          "",
    city:          "",
    country:       "",
  });
  const [loading, setLoading] = useState(false);

  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
    setForm((p) => ({ ...p, [k]: e.target.value }));

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!contracts.userManagement) return toast.error("Contract not connected");
    setLoading(true);
    try {
      const tx = await contracts.userManagement.signUp(
        form.name,
        parseInt(form.role),
        form.contactNumber,
        form.cnic,
        form.city,
        form.country
      );
      toast.loading("Registering on blockchain…", { id: "register" });
      await tx.wait();
      toast.success("Account created successfully!", { id: "register" });
      await refreshUser();
      router.push("/documents");
    } catch (err) {
      toast.error(parseContractError(err), { id: "register" });
    } finally {
      setLoading(false);
    }
  }

  if (!isConnected) {
    return (
      <div className="max-w-md mx-auto px-4 py-24 text-center">
        <Leaf className="w-12 h-12 text-primary-600 mx-auto mb-4" />
        <h2 className="text-2xl font-bold mb-2">Connect your wallet</h2>
        <p className="text-gray-500 mb-6">You need a Web3 wallet to register on AgriChain.</p>
        <Button onClick={connectWallet} size="lg">Connect Wallet</Button>
      </div>
    );
  }

  if (isRegistered) {
    return (
      <div className="max-w-md mx-auto px-4 py-24 text-center">
        <p className="text-gray-500 mb-4">You already have an account.</p>
        <Button onClick={() => router.push("/profile")}>Go to Profile</Button>
      </div>
    );
  }

  return (
    <div className="max-w-lg mx-auto px-4 py-16">
      <div className="text-center mb-8">
        <UserPlus className="w-10 h-10 text-primary-600 mx-auto mb-3" />
        <h1 className="text-3xl font-bold text-gray-900">Create Account</h1>
        <p className="text-gray-500 mt-2">Register on AgriChain using your wallet address</p>
      </div>

      <Card>
        <form onSubmit={handleSubmit} className="space-y-5">
          <Input label="Full Name" placeholder="Muhammad Ali" required
            value={form.name} onChange={set("name")} />
          <Select label="Role" value={form.role} onChange={set("role")}
            options={[
              { label: "Farmer",      value: "1" },
              { label: "Buyer",       value: "2" },
              { label: "Shopkeeper",  value: "3" },
              { label: "Government",  value: "4" },
            ]}
          />
          <Input label="Contact Number" placeholder="+92 300 0000000" required
            value={form.contactNumber} onChange={set("contactNumber")} />
          <Input label="CNIC" placeholder="00000-0000000-0" required
            value={form.cnic} onChange={set("cnic")} />
          <div className="grid grid-cols-2 gap-4">
            <Input label="City" placeholder="Lahore" required
              value={form.city} onChange={set("city")} />
            <Input label="Country" placeholder="Pakistan" required
              value={form.country} onChange={set("country")} />
          </div>
          <Button type="submit" loading={loading} size="lg" className="w-full">
            Register
          </Button>
        </form>
      </Card>

      <p className="text-center text-sm text-gray-500 mt-4">
        After registering, upload your documents to get verified.
      </p>
    </div>
  );
}
