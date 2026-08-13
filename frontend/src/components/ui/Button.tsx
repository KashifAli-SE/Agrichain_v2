import clsx from "clsx";
import { ReactNode, ButtonHTMLAttributes } from "react";
import { Loader2 } from "lucide-react";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "danger" | "outline" | "ghost";
  size?:    "sm" | "md" | "lg";
  loading?: boolean;
  children: ReactNode;
}

export default function Button({
  variant  = "primary",
  size     = "md",
  loading  = false,
  children,
  className,
  disabled,
  ...props
}: ButtonProps) {
  return (
    <button
      {...props}
      disabled={disabled || loading}
      className={clsx(
        "inline-flex items-center justify-center gap-2 font-semibold rounded-xl transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2",
        {
          // variants
          "bg-primary-600 hover:bg-primary-700 text-white focus:ring-primary-500":
            variant === "primary",
          "bg-earth-500 hover:bg-earth-600 text-white focus:ring-earth-400":
            variant === "secondary",
          "bg-red-600 hover:bg-red-700 text-white focus:ring-red-500":
            variant === "danger",
          "border-2 border-primary-600 text-primary-600 hover:bg-primary-50 focus:ring-primary-500":
            variant === "outline",
          "text-gray-600 hover:bg-gray-100 focus:ring-gray-300":
            variant === "ghost",
          // sizes
          "px-3 py-1.5 text-sm": size === "sm",
          "px-5 py-2.5 text-sm": size === "md",
          "px-7 py-3.5 text-base": size === "lg",
          // disabled
          "opacity-50 cursor-not-allowed": disabled || loading,
        },
        className
      )}
    >
      {loading && <Loader2 className="w-4 h-4 animate-spin" />}
      {children}
    </button>
  );
}
