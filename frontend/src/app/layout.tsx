import type { Metadata } from "next";
import "./globals.css";
import { Web3Provider } from "@/context/Web3Context";
import Navbar from "@/components/layout/Navbar";
import Footer from "@/components/layout/Footer";
import { Toaster } from "react-hot-toast";

export const metadata: Metadata = {
  title:       "AgriChain — Decentralized Agricultural Supply Chain",
  description: "Connect farmers, buyers, and shopkeepers on the blockchain.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Web3Provider>
          <Navbar />
          <main className="min-h-screen">{children}</main>
          <Footer />
          <Toaster
            position="top-right"
            toastOptions={{
              style: { borderRadius: "12px", fontSize: "14px" },
            }}
          />
        </Web3Provider>
      </body>
    </html>
  );
}
