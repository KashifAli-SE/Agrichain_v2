import Link from "next/link";
import Button from "@/components/ui/Button";
import { Leaf } from "lucide-react";

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center text-center px-4">
      <div>
        <Leaf className="w-16 h-16 text-primary-300 mx-auto mb-6" />
        <h1 className="text-6xl font-black text-gray-200 mb-4">404</h1>
        <h2 className="text-2xl font-bold text-gray-700 mb-2">Page not found</h2>
        <p className="text-gray-500 mb-8">The page you're looking for doesn't exist.</p>
        <Link href="/"><Button>Back to Home</Button></Link>
      </div>
    </div>
  );
}
