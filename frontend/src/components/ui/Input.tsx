import clsx from "clsx";
import { InputHTMLAttributes, forwardRef } from "react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?:  string;
  error?:  string;
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, className, ...props }, ref) => (
    <div className="flex flex-col gap-1">
      {label && (
        <label className="text-sm font-medium text-gray-700">{label}</label>
      )}
      <input
        ref={ref}
        {...props}
        className={clsx(
          "w-full px-4 py-2.5 rounded-xl border text-sm transition-colors",
          "focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent",
          error
            ? "border-red-400 bg-red-50"
            : "border-gray-300 bg-white hover:border-gray-400",
          className
        )}
      />
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  )
);
Input.displayName = "Input";
export default Input;
