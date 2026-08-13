"use client";
import { useState, useEffect, useCallback } from "react";
import { useWeb3 } from "@/context/Web3Context";
import { SHOP_PRODUCT_TYPE, parseContractError, shortAddress } from "@/lib/helpers";
import Button from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import Badge from "@/components/ui/Badge";
import Input from "@/components/ui/Input";
import Select from "@/components/ui/Select";
import Modal from "@/components/ui/Modal";
import toast from "react-hot-toast";
import { Store, Plus, Search, ShoppingCart, Trash2 } from "lucide-react";

interface Product {
  ProducdId: bigint; ProductName: string; ProductType: number;
  availableUnits: bigint; pricePerUnit: bigint;
  ProductOwner: string; ipfsImageHash: string;
}

export default function ProductsMarketplacePage() {
  const { contracts, userData, address } = useWeb3();
  const [products,    setProducts]   = useState<Product[]>([]);
  const [loading,     setLoading]    = useState(true);
  const [search,      setSearch]     = useState("");
  const [showAdd,     setShowAdd]    = useState(false);
  const [showOrder,   setShowOrder]  = useState(false);
  const [selected,    setSelected]   = useState<Product | null>(null);
  const [orderQty,    setOrderQty]   = useState("1");
  const [txLoading,   setTxLoading]  = useState(false);

  const isShop   = userData?.Role === 3;
  const isFarmer = userData?.Role === 1;

  const fetchProducts = useCallback(async () => {
    if (!contracts.productMarketplace) return;
    setLoading(true);
    try {
      const counter = await contracts.productMarketplace.productCounter();
      const items: Product[] = [];
      for (let i = 1; i < Number(counter); i++) {
        try {
          const p = await contracts.productMarketplace.getProductById(BigInt(i));
          if (p.ProductOwner !== "0x0000000000000000000000000000000000000000") items.push(p);
        } catch {}
      }
      setProducts(items);
    } catch {}
    finally { setLoading(false); }
  }, [contracts.productMarketplace]);

  useEffect(() => { fetchProducts(); }, [fetchProducts]);

  const filtered = products.filter(p =>
    p.ProductName.toLowerCase().includes(search.toLowerCase())
  );

  async function handleOrder() {
    if (!contracts.orderManager || !selected) return;
    setTxLoading(true);
    try {
      const tx = await contracts.orderManager.addOrder(selected.ProducdId, BigInt(orderQty));
      toast.loading("Placing order…", { id: "porder" });
      await tx.wait();
      toast.success("Order placed! Go to Orders to pay.", { id: "porder" });
      setShowOrder(false);
    } catch (err) {
      toast.error(parseContractError(err), { id: "porder" });
    } finally { setTxLoading(false); }
  }

  async function handleRemove(productId: bigint) {
    if (!contracts.productMarketplace) return;
    if (!confirm("Remove this product listing?")) return;
    try {
      const tx = await contracts.productMarketplace.removeProduct(productId);
      toast.loading("Removing…", { id: "remove" });
      await tx.wait();
      toast.success("Product removed.", { id: "remove" });
      fetchProducts();
    } catch (err) {
      toast.error(parseContractError(err), { id: "remove" });
    }
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-2">
            <Store className="w-8 h-8 text-earth-500" /> Product Marketplace
          </h1>
          <p className="text-gray-500 mt-1">Fertilizers, seeds, and pesticides from verified shops</p>
        </div>
        {isShop && (
          <Button variant="secondary" onClick={() => setShowAdd(true)}>
            <Plus className="w-4 h-4" /> List Product
          </Button>
        )}
      </div>

      <div className="relative mb-8 max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search products…"
          className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
      </div>

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
          <Store className="w-12 h-12 mx-auto mb-3 opacity-30" />
          <p>No products listed yet.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {filtered.map(product => (
            <Card key={product.ProducdId.toString()} hover className="flex flex-col">
              <div className="h-40 bg-gradient-to-br from-earth-100 to-earth-50 rounded-xl mb-4 flex items-center justify-center overflow-hidden">
                {product.ipfsImageHash && product.ipfsImageHash !== "NullHash" ? (
                  <img src={`https://ipfs.io/ipfs/${product.ipfsImageHash}`} alt={product.ProductName}
                    className="w-full h-full object-cover rounded-xl"
                    onError={e => { (e.target as HTMLImageElement).style.display = "none"; }} />
                ) : (
                  <Store className="w-12 h-12 text-earth-300" />
                )}
              </div>
              <div className="flex-1">
                <div className="flex items-start justify-between">
                  <h3 className="font-semibold text-gray-900">{product.ProductName}</h3>
                  <Badge label={SHOP_PRODUCT_TYPE[product.ProductType]}
                    className="bg-earth-100 text-earth-700" />
                </div>
                <div className="mt-2 space-y-1 text-sm text-gray-500">
                  <p>📦 {product.availableUnits.toString()} units available</p>
                  <p className="text-xs">Seller: {shortAddress(product.ProductOwner)}</p>
                </div>
              </div>
              <div className="mt-4 pt-4 border-t border-gray-100 flex items-center justify-between">
                <p className="font-bold text-earth-700">${product.pricePerUnit.toString()}<span className="text-xs font-normal text-gray-400">/unit</span></p>
                <div className="flex gap-2">
                  {isShop && product.ProductOwner.toLowerCase() === address?.toLowerCase() && (
                    <Button size="sm" variant="danger" onClick={() => handleRemove(product.ProducdId)}>
                      <Trash2 className="w-3 h-3" />
                    </Button>
                  )}
                  {isFarmer && Number(product.availableUnits) > 0 && product.ProductOwner.toLowerCase() !== address?.toLowerCase() && (
                    <Button size="sm" variant="secondary" onClick={() => { setSelected(product); setShowOrder(true); }}>
                      Buy
                    </Button>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      <AddProductModal open={showAdd} onClose={() => setShowAdd(false)} contracts={contracts} onSuccess={fetchProducts} />

      <Modal open={showOrder} onClose={() => setShowOrder(false)} title="Place Order" size="sm">
        {selected && (
          <div className="space-y-4">
            <div className="p-4 bg-gray-50 rounded-xl">
              <p className="font-semibold">{selected.ProductName}</p>
              <p className="text-sm text-gray-500">{SHOP_PRODUCT_TYPE[selected.ProductType]}</p>
              <p className="text-lg font-bold text-earth-600 mt-1">${selected.pricePerUnit.toString()} / unit</p>
            </div>
            <Input label="Quantity" type="number" min="1" max={selected.availableUnits.toString()}
              value={orderQty} onChange={e => setOrderQty(e.target.value)} />
            <p className="text-sm text-gray-500">
              Total: <strong>${(Number(selected.pricePerUnit) * Number(orderQty)).toLocaleString()}</strong>
            </p>
            <Button onClick={handleOrder} loading={txLoading} variant="secondary" className="w-full">
              <ShoppingCart className="w-4 h-4" /> Place Order
            </Button>
          </div>
        )}
      </Modal>
    </div>
  );
}

function AddProductModal({ open, onClose, contracts, onSuccess }: {
  open: boolean; onClose: () => void; contracts: any; onSuccess: () => void;
}) {
  const [form, setForm] = useState({ name: "", type: "1", units: "", price: "", image: "" });
  const [loading, setLoading] = useState(false);
  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
    setForm(p => ({ ...p, [k]: e.target.value }));

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!contracts.productMarketplace) return;
    setLoading(true);
    try {
      const tx = await contracts.productMarketplace.listProduct(
        form.name, parseInt(form.type), BigInt(form.units), BigInt(form.price), form.image || "NullHash"
      );
      toast.loading("Listing product…", { id: "prod" });
      await tx.wait();
      toast.success("Product listed!", { id: "prod" });
      onSuccess(); onClose();
    } catch (err) {
      toast.error(parseContractError(err), { id: "prod" });
    } finally { setLoading(false); }
  }

  return (
    <Modal open={open} onClose={onClose} title="List a Product" size="md">
      <form onSubmit={handleSubmit} className="space-y-4">
        <Input label="Product Name" placeholder="DAP Fertilizer" value={form.name} onChange={set("name")} required />
        <Select label="Product Type" value={form.type} onChange={set("type")}
          options={[{label:"Fertilizer",value:"1"},{label:"Seed",value:"2"},{label:"Pesticides",value:"3"}]} />
        <div className="grid grid-cols-2 gap-3">
          <Input label="Available Units" type="number" min="1" value={form.units} onChange={set("units")} required />
          <Input label="Price/Unit (USD)" type="number" min="1" value={form.price} onChange={set("price")} required />
        </div>
        <Input label="IPFS Image Hash (optional)" placeholder="Qm..." value={form.image} onChange={set("image")} />
        <Button type="submit" loading={loading} variant="secondary" className="w-full">List Product</Button>
      </form>
    </Modal>
  );
}
