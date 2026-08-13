"use client";
import { useState, useEffect, useCallback } from "react";
import { useWeb3 } from "@/context/Web3Context";
import { CROP_UNIT, parseContractError, shortAddress } from "@/lib/helpers";
import Button from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import Badge from "@/components/ui/Badge";
import Input from "@/components/ui/Input";
import Select from "@/components/ui/Select";
import Modal from "@/components/ui/Modal";
import toast from "react-hot-toast";
import { Wheat, Plus, Search, ShoppingCart, Edit2 } from "lucide-react";

interface Crop {
  CropID: bigint; CropName: string; CropType: string;
  cropStockAmount: bigint; unit: number; pricePerUnit: bigint;
  cropOwner: string; CropCityCountry: string; ipfsImageHash: string;
}

export default function CropsMarketplacePage() {
  const { contracts, userData, address, isConnected } = useWeb3();
  const [crops,        setCrops]       = useState<Crop[]>([]);
  const [loading,      setLoading]     = useState(true);
  const [search,       setSearch]      = useState("");
  const [showAdd,      setShowAdd]     = useState(false);
  const [showOrder,    setShowOrder]   = useState(false);
  const [selectedCrop, setSelected]    = useState<Crop | null>(null);
  const [orderQty,     setOrderQty]    = useState("1");
  const [txLoading,    setTxLoading]   = useState(false);

  const isFarmer = userData?.Role === 1;
  const isBuyer  = userData?.Role === 2;

  const fetchCrops = useCallback(async () => {
    if (!contracts.cropMarketplace) return;
    setLoading(true);
    try {
      const data = await contracts.cropMarketplace.getAllListedCrops();
      // index 0 is null crop
      setCrops(data.slice(1).filter((c: Crop) => c.cropOwner !== "0x0000000000000000000000000000000000000000"));
    } catch { /* not deployed yet */ }
    finally { setLoading(false); }
  }, [contracts.cropMarketplace]);

  useEffect(() => { fetchCrops(); }, [fetchCrops]);

  const filtered = crops.filter(c =>
    c.CropName.toLowerCase().includes(search.toLowerCase()) ||
    c.CropType.toLowerCase().includes(search.toLowerCase())
  );

  async function handleOrder() {
    if (!contracts.orderManager || !selectedCrop) return;
    setTxLoading(true);
    try {
      const tx = await contracts.orderManager.addOrder(selectedCrop.CropID, BigInt(orderQty));
      toast.loading("Placing order…", { id: "order" });
      await tx.wait();
      toast.success("Order placed! Proceed to pay in Orders page.", { id: "order" });
      setShowOrder(false);
    } catch (err) {
      toast.error(parseContractError(err), { id: "order" });
    } finally { setTxLoading(false); }
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-2">
            <Wheat className="w-8 h-8 text-primary-600" /> Crop Marketplace
          </h1>
          <p className="text-gray-500 mt-1">Fresh crops listed directly by verified farmers</p>
        </div>
        {isFarmer && (
          <Button onClick={() => setShowAdd(true)}>
            <Plus className="w-4 h-4" /> List Crop
          </Button>
        )}
      </div>

      {/* Search */}
      <div className="relative mb-8 max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        <input
          value={search} onChange={e => setSearch(e.target.value)}
          placeholder="Search crops…"
          className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        />
      </div>

      {/* Grid */}
      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="bg-white rounded-2xl border border-gray-100 p-6 animate-pulse">
              <div className="h-40 bg-gray-100 rounded-xl mb-4" />
              <div className="h-4 bg-gray-100 rounded w-3/4 mb-2" />
              <div className="h-3 bg-gray-100 rounded w-1/2" />
            </div>
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-20 text-gray-400">
          <Wheat className="w-12 h-12 mx-auto mb-3 opacity-30" />
          <p>No crops listed yet.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {filtered.map((crop) => (
            <CropCard
              key={crop.CropID.toString()}
              crop={crop}
              isBuyer={isBuyer}
              isOwner={crop.cropOwner.toLowerCase() === address?.toLowerCase()}
              onOrder={() => { setSelected(crop); setShowOrder(true); }}
            />
          ))}
        </div>
      )}

      {/* Add Crop Modal */}
      <AddCropModal
        open={showAdd}
        onClose={() => setShowAdd(false)}
        contracts={contracts}
        onSuccess={fetchCrops}
      />

      {/* Order Modal */}
      <Modal open={showOrder} onClose={() => setShowOrder(false)} title="Place Order" size="sm">
        {selectedCrop && (
          <div className="space-y-4">
            <div className="p-4 bg-gray-50 rounded-xl">
              <p className="font-semibold">{selectedCrop.CropName}</p>
              <p className="text-sm text-gray-500">{selectedCrop.CropType}</p>
              <p className="text-lg font-bold text-primary-600 mt-1">
                ${selectedCrop.pricePerUnit.toString()} / {CROP_UNIT[selectedCrop.unit]}
              </p>
            </div>
            <Input
              label="Quantity"
              type="number"
              min="1"
              max={selectedCrop.cropStockAmount.toString()}
              value={orderQty}
              onChange={e => setOrderQty(e.target.value)}
            />
            <p className="text-sm text-gray-500">
              Total: <strong>${(Number(selectedCrop.pricePerUnit) * Number(orderQty)).toLocaleString()}</strong>
            </p>
            <Button onClick={handleOrder} loading={txLoading} className="w-full">
              <ShoppingCart className="w-4 h-4" /> Place Order
            </Button>
          </div>
        )}
      </Modal>
    </div>
  );
}

function CropCard({ crop, isBuyer, isOwner, onOrder }: {
  crop: Crop; isBuyer: boolean; isOwner: boolean; onOrder: () => void;
}) {
  const available = Number(crop.cropStockAmount) > 0;
  return (
    <Card hover className="flex flex-col">
      {/* Image placeholder */}
      <div className="h-40 bg-gradient-to-br from-primary-100 to-primary-50 rounded-xl mb-4 flex items-center justify-center overflow-hidden">
        {crop.ipfsImageHash && crop.ipfsImageHash !== "NullHash" ? (
          <img
            src={`https://ipfs.io/ipfs/${crop.ipfsImageHash}`}
            alt={crop.CropName}
            className="w-full h-full object-cover rounded-xl"
            onError={e => { (e.target as HTMLImageElement).style.display = "none"; }}
          />
        ) : (
          <Wheat className="w-12 h-12 text-primary-300" />
        )}
      </div>
      <div className="flex-1">
        <div className="flex items-start justify-between">
          <div>
            <h3 className="font-semibold text-gray-900">{crop.CropName}</h3>
            <p className="text-sm text-gray-500">{crop.CropType}</p>
          </div>
          <Badge
            label={available ? "Available" : "Out of Stock"}
            className={available ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-500"}
          />
        </div>
        <div className="mt-3 space-y-1 text-sm text-gray-600">
          <p>📦 {crop.cropStockAmount.toString()} {CROP_UNIT[crop.unit]}</p>
          <p>📍 {crop.CropCityCountry}</p>
          <p className="text-xs text-gray-400">Seller: {shortAddress(crop.cropOwner)}</p>
        </div>
      </div>
      <div className="mt-4 pt-4 border-t border-gray-100 flex items-center justify-between">
        <p className="font-bold text-primary-700">${crop.pricePerUnit.toString()}<span className="text-xs font-normal text-gray-400">/{CROP_UNIT[crop.unit]}</span></p>
        {isBuyer && available && !isOwner && (
          <Button size="sm" onClick={onOrder}>Buy</Button>
        )}
      </div>
    </Card>
  );
}

function AddCropModal({ open, onClose, contracts, onSuccess }: {
  open: boolean; onClose: () => void; contracts: any; onSuccess: () => void;
}) {
  const [form, setForm] = useState({
    name: "", type: "", stock: "", unit: "1", price: "", location: "", image: "",
  });
  const [loading, setLoading] = useState(false);
  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
    setForm(p => ({ ...p, [k]: e.target.value }));

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!contracts.cropMarketplace) return;
    setLoading(true);
    try {
      const tx = await contracts.cropMarketplace.addCrop(
        form.name, form.type, BigInt(form.stock), parseInt(form.unit),
        BigInt(form.price), form.location, form.image || "NullHash"
      );
      toast.loading("Listing crop…", { id: "crop" });
      await tx.wait();
      toast.success("Crop listed!", { id: "crop" });
      onSuccess();
      onClose();
    } catch (err) {
      toast.error(parseContractError(err), { id: "crop" });
    } finally { setLoading(false); }
  }

  return (
    <Modal open={open} onClose={onClose} title="List a Crop" size="md">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-3">
          <Input label="Crop Name"  placeholder="Wheat"   value={form.name}  onChange={set("name")}  required />
          <Input label="Crop Type"  placeholder="Winter"  value={form.type}  onChange={set("type")}  required />
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Input label="Stock Amount" type="number" min="1" value={form.stock} onChange={set("stock")} required />
          <Select label="Unit" value={form.unit} onChange={set("unit")}
            options={[{label:"KG",value:"1"},{label:"Tonn",value:"2"},{label:"Dozen",value:"3"}]} />
        </div>
        <Input label="Price Per Unit (USD)" type="number" min="1" value={form.price} onChange={set("price")} required />
        <Input label="Location (City, Country)" placeholder="Lahore, Pakistan" value={form.location} onChange={set("location")} required />
        <Input label="IPFS Image Hash (optional)" placeholder="Qm..." value={form.image} onChange={set("image")} />
        <Button type="submit" loading={loading} className="w-full">List Crop</Button>
      </form>
    </Modal>
  );
}
