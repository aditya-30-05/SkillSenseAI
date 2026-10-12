"use client"

import * as React from "react"
import { cn } from "@/lib/utils"

export interface AnimatedButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "outline" | "warning" | "critical"
  isLoading?: boolean
  icon?: React.ReactNode
}

export default function AnimatedButton({
  children,
  className,
  variant = "primary",
  isLoading = false,
  icon,
  disabled,
  ...props
}: AnimatedButtonProps) {
  const variantStyles = {
    primary:
      "bg-teal-500 hover:bg-teal-400 text-slate-950 shadow-[0_0_20px_rgba(20,184,166,0.3)] border-teal-400/40",
    secondary:
      "bg-blue-600 hover:bg-blue-500 text-white shadow-[0_0_20px_rgba(59,130,246,0.3)] border-blue-400/40",
    outline:
      "bg-slate-900/60 hover:bg-slate-800/80 text-slate-100 border-slate-700 hover:border-teal-400/50",
    warning:
      "bg-amber-500 hover:bg-amber-400 text-slate-950 shadow-[0_0_20px_rgba(245,158,11,0.3)] border-amber-400/40",
    critical:
      "bg-red-600 hover:bg-red-500 text-white shadow-[0_0_20px_rgba(239,68,68,0.3)] border-red-400/40",
  }

  return (
    <button
      className={cn(
        "group relative inline-flex items-center justify-center gap-2 rounded-xl border px-5 py-2.5 text-sm font-semibold transition-all duration-200 ease-out active:scale-[0.98] disabled:pointer-events-none disabled:opacity-50",
        variantStyles[variant],
        className
      )}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <span className="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
      ) : (
        <>
          {icon && <span className="transition-transform group-hover:scale-110">{icon}</span>}
          <span>{children}</span>
        </>
      )}
    </button>
  )
}

export function AnimatedButtonDemo() {
  return <AnimatedButton>Get Started</AnimatedButton>
}
