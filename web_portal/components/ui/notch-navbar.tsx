"use client"

import * as React from "react"
import { cn } from "@/lib/utils"

export interface NotchNavbarProps
  extends React.HTMLAttributes<HTMLDivElement> {
  activeItem?: string
  onItemClick?: (item: string) => void
}

const defaultNavItems = [
  "Dashboard",
  "Trainees",
  "Live Monitor",
  "Hazard Map",
  "Sessions",
  "Performance",
  "AI Coach",
  "Reports",
  "Settings",
]

export function NotchNavbar({
  className,
  activeItem = "Dashboard",
  onItemClick,
  ...props
}: NotchNavbarProps) {
  const [active, setActive] = React.useState(activeItem)

  const handleSelect = (item: string) => {
    setActive(item)
    if (onItemClick) onItemClick(item)
  }

  return (
    <nav
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full border border-teal-500/30 bg-slate-950/80 p-2 backdrop-blur-xl shadow-2xl",
        className
      )}
      {...props}
    >
      <div className="flex items-center gap-2 rounded-full border border-slate-800 bg-slate-900/80 px-3 py-1 mr-2 text-xs font-semibold text-slate-200">
        <span className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
        <span className="font-mono text-[11px] tracking-wide text-teal-400">
          AEROGUARD HUD
        </span>
      </div>

      <div className="flex items-center gap-1 overflow-x-auto">
        {defaultNavItems.map((item) => {
          const isSelected = active === item
          return (
            <button
              key={item}
              onClick={() => handleSelect(item)}
              className={cn(
                "rounded-full px-3.5 py-1 text-xs font-medium transition-all duration-200 whitespace-nowrap",
                isSelected
                  ? "bg-teal-500/20 text-teal-300 border border-teal-400/40 shadow-[0_0_12px_rgba(20,184,166,0.2)]"
                  : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/40"
              )}
            >
              {item}
            </button>
          )
        })}
      </div>
    </nav>
  )
}

export function NotchNavbarDemo() {
  return <NotchNavbar />
}
