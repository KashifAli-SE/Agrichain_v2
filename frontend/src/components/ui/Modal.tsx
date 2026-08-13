"use client";
import { ReactNode, useEffect } from "react";
import { X } from "lucide-react";
import clsx from "clsx";

interface ModalProps {
  open:       boolean;
  onClose:    () => void;
  title?:     string;
  children:   ReactNode;
  size?:      "sm" | "md" | "lg" | "xl";
}

export default function Modal({ open, onClose, title, children, size = "md" }: ModalProps) {
  useEffect(() => {
    if (open) document.body.style.overflow = "hidden";
    else       document.body.style.overflow = "";
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />
      {/* Panel */}
      <div
        className={clsx(
          "relative bg-white rounded-2xl shadow-2xl w-full overflow-y-auto max-h-[90vh]",
          {
            "max-w-sm":  size === "sm",
            "max-w-lg":  size === "md",
            "max-w-2xl": size === "lg",
            "max-w-4xl": size === "xl",
          }
        )}
      >
        {title && (
          <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100">
            <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
            <button onClick={onClose} className="p-1 rounded-lg hover:bg-gray-100 transition">
              <X className="w-5 h-5 text-gray-500" />
            </button>
          </div>
        )}
        <div className="p-6">{children}</div>
      </div>
    </div>
  );
}
