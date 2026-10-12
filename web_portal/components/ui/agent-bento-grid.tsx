"use client"

import * as React from "react"
import { cn } from "@/lib/utils"

export interface AgentBentoGridProps
  extends React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode
}

export function AgentBentoGrid({
  className,
  children,
  ...props
}: AgentBentoGridProps) {
  return (
    <div
      className={cn(
        "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 w-full",
        className
      )}
      {...props}
    >
      {children || (
        <>
          <div className="lg:col-span-2 rounded-2xl border border-teal-500/30 bg-slate-900/60 p-6 backdrop-blur-md shadow-xl">
            <div className="flex items-center justify-between pb-4 border-b border-slate-800">
              <div className="flex items-center gap-3">
                <span className="flex h-3 w-3 rounded-full bg-teal-400 shadow-[0_0_8px_#2dd4bf]" />
                <h3 className="font-semibold text-slate-100">DRONE-01 ALPHA • TELEMETRY LINK</h3>
              </div>
              <span className="rounded-full bg-emerald-500/10 px-2.5 py-0.5 text-xs font-semibold text-emerald-400 border border-emerald-500/20">
                IN FLIGHT
              </span>
            </div>
            <div className="mt-4 grid grid-cols-3 gap-3">
              <div className="rounded-xl border border-slate-800 bg-slate-950/50 p-3">
                <p className="text-xs text-slate-400">BATTERY</p>
                <p className="text-xl font-bold text-teal-400">82%</p>
              </div>
              <div className="rounded-xl border border-slate-800 bg-slate-950/50 p-3">
                <p className="text-xs text-slate-400">ALTITUDE</p>
                <p className="text-xl font-bold text-blue-400">24.5m</p>
              </div>
              <div className="rounded-xl border border-slate-800 bg-slate-950/50 p-3">
                <p className="text-xs text-slate-400">LINK SIGNAL</p>
                <p className="text-xl font-bold text-purple-400">98%</p>
              </div>
            </div>
          </div>

          <div className="rounded-2xl border border-slate-800 bg-slate-900/60 p-6 backdrop-blur-md shadow-xl">
            <p className="text-xs font-semibold text-slate-400">COHORT SCORE</p>
            <p className="mt-2 text-3xl font-extrabold text-slate-100">84.6%</p>
            <p className="mt-1 text-xs text-emerald-400">+4.2% cohort gain this week</p>
          </div>

          <div className="rounded-2xl border border-slate-800 bg-slate-900/60 p-6 backdrop-blur-md shadow-xl">
            <p className="text-xs font-semibold text-slate-400">ACTIVE SESSIONS</p>
            <p className="mt-2 text-3xl font-extrabold text-blue-400">3</p>
            <p className="mt-1 text-xs text-slate-400">Live trainee evaluations</p>
          </div>

          <div className="rounded-2xl border border-slate-800 bg-slate-900/60 p-6 backdrop-blur-md shadow-xl">
            <p className="text-xs font-semibold text-slate-400">HAZARDS DETECTED</p>
            <p className="mt-2 text-3xl font-extrabold text-amber-400">18</p>
            <p className="mt-1 text-xs text-slate-400">91.2% detection rate</p>
          </div>

          <div className="rounded-2xl border border-slate-800 bg-slate-900/60 p-6 backdrop-blur-md shadow-xl">
            <p className="text-xs font-semibold text-slate-400">AI DIAGNOSTIC COPILOT</p>
            <p className="mt-2 text-xl font-bold text-purple-400">Online</p>
            <p className="mt-1 text-xs text-slate-400">Rubric scoring ready</p>
          </div>
        </>
      )}
    </div>
  )
}

export function AgentBentoGridDemo() {
  return <AgentBentoGrid className="my-8" />
}
