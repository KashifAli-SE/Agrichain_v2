import clsx from "clsx";
import { SelectHTMLAttributes } from "react";

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label?:   string;
  error?:   string;
  options:  { label: string; value: string | number }[];
}

export default function Select({ label, error, options, className, ...props }: SelectProps) {
  return (
    <div className="flex flex-col gap-1">
      {label && <label className="text-sm font-medium text-gray-700">{label}</label>}
      <select
        {...props}
        className={clsx(
          "w-full px-4 py-2.5 rounded-xl border text-sm bg-white transition-colors",
          "focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent",
          error ? "border-red-400" : "border-gray-300 hover:border-gray-400",
          className
        )}
      >
        {options.map((o) => (
          <option key={o.value} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  );
}
