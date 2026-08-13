import clsx from "clsx";
import { ReactNode } from "react";

interface CardProps {
  children:  ReactNode;
  className?: string;
  hover?:    boolean;
}

export function Card({ children, className, hover }: CardProps) {
  return (
    <div
      className={clsx(
        "bg-white rounded-2xl shadow-sm border border-gray-100 p-6",
        hover && "hover:shadow-md transition-shadow duration-200 cursor-pointer",
        className
      )}
    >
      {children}
    </div>
  );
}

export function CardHeader({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div className={clsx("mb-4 pb-4 border-b border-gray-100", className)}>
      {children}
    </div>
  );
}
