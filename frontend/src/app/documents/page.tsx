"use client";
import { useState, useEffect } from "react";
import { useWeb3 } from "@/context/Web3Context";
import { DOC_TYPES, parseContractError } from "@/lib/helpers";
import Button from "@/components/ui/Button";
import Select from "@/components/ui/Select";
import Input from "@/components/ui/Input";
import { Card, CardHeader } from "@/components/ui/Card";
import toast from "react-hot-toast";
import { ethers } from "ethers";
import { FileText, Upload, CheckCircle } from "lucide-react";

interface DocData { owner: string; encryptedCID: string; hash: string; docType: number; }

export default function DocumentsPage() {
  const { contracts, isConnected, isRegistered, address } = useWeb3();
  const [doc,      setDoc]     = useState<DocData | null>(null);
  const [loading,  setLoading] = useState(false);
  const [fetching, setFetching]= useState(true);
  const [form, setForm] = useState({ cid: "", docType: "1" });

  useEffect(() => {
    async function fetchDoc() {
      if (!contracts.documentRegistry || !address) return;
      try {
        const d = await contracts.documentRegistry.getDocumentsByUser(address);
        if (d.owner !== ethers.ZeroAddress) setDoc({ owner: d.owner, encryptedCID: d.encryptedCID, hash: d.hash, docType: Number(d.docType) });
      } catch { /* no doc yet */ }
      finally { setFetching(false); }
    }
    fetchDoc();
  }, [contracts.documentRegistry, address]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!contracts.documentRegistry) return;
    setLoading(true);
    try {
      // Hash the CID on client-side as a simple proof
      const hash = ethers.keccak256(ethers.toUtf8Bytes(form.cid));
      const tx = await contracts.documentRegistry.addDocument(form.cid, hash, parseInt(form.docType));
      toast.loading("Uploading document reference on-chain…", { id: "doc" });
      await tx.wait();
      toast.success("Document submitted! Awaiting admin verification.", { id: "doc" });
      setDoc({ owner: address!, encryptedCID: form.cid, hash, docType: parseInt(form.docType) });
    } catch (err) {
      toast.error(parseContractError(err), { id: "doc" });
    } finally {
      setLoading(false);
    }
  }

  const docLabel = (type: number) => DOC_TYPES.find(d => d.value === type)?.label ?? "Unknown";

  if (!isConnected || !isRegistered) return (
    <div className="max-w-lg mx-auto px-4 py-24 text-center">
      <p className="text-gray-500">Register an account first to manage documents.</p>
    </div>
  );

  return (
    <div className="max-w-2xl mx-auto px-4 py-12">
      <h1 className="text-3xl font-bold mb-2 text-gray-900">Documents</h1>
      <p className="text-gray-500 mb-8">Submit your KYC document IPFS CID to apply for verification.</p>

      {/* Current doc */}
      {!fetching && doc && (
        <Card className="mb-8 bg-green-50 border-green-200">
          <div className="flex items-center gap-4">
            <CheckCircle className="w-8 h-8 text-green-600 flex-shrink-0" />
            <div>
              <p className="font-semibold text-green-900">Document Submitted</p>
              <p className="text-sm text-green-700 mt-0.5">Type: {docLabel(doc.docType)}</p>
              <p className="text-xs text-green-600 break-all mt-1">CID: {doc.encryptedCID}</p>
            </div>
          </div>
        </Card>
      )}

      <Card>
        <CardHeader>
          <div className="flex items-center gap-3">
            <FileText className="w-6 h-6 text-primary-600" />
            <div>
              <h2 className="font-semibold text-gray-900">{doc ? "Update Document" : "Submit Document"}</h2>
              <p className="text-xs text-gray-500 mt-0.5">
                Upload your document to IPFS first, then paste the CID here.
              </p>
            </div>
          </div>
        </CardHeader>

        <form onSubmit={handleSubmit} className="space-y-4">
          <Select
            label="Document Type"
            value={form.docType}
            onChange={e => setForm(p => ({ ...p, docType: e.target.value }))}
            options={DOC_TYPES}
          />
          <Input
            label="IPFS CID (Encrypted)"
            placeholder="Qm... or bafk..."
            required
            value={form.cid}
            onChange={e => setForm(p => ({ ...p, cid: e.target.value }))}
          />

          <div className="p-4 bg-blue-50 rounded-xl text-sm text-blue-700">
            <strong>How to get an IPFS CID:</strong> Upload your encrypted document to{" "}
            <a href="https://www.pinata.cloud" target="_blank" rel="noreferrer" className="underline">Pinata</a>{" "}
            or{" "}
            <a href="https://web3.storage" target="_blank" rel="noreferrer" className="underline">Web3.Storage</a>{" "}
            and paste the resulting CID here.
          </div>

          <Button type="submit" loading={loading} className="w-full">
            <Upload className="w-4 h-4" /> Submit Document
          </Button>
        </form>
      </Card>
    </div>
  );
}
