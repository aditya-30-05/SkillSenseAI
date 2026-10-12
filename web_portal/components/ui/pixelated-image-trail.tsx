"use client"

import * as React from "react"
import { cn } from "@/lib/utils"

export interface PixelatedImageTrailProps
  extends React.HTMLAttributes<HTMLDivElement> {
  images?: string[]
  imageSize?: number
  slices?: number
  smoothing?: number
  spawnThreshold?: number
  config?: {
    imageLifespan?: number
    inDuration?: number
    outDuration?: number
    staggerIn?: number
    staggerOut?: number
    slideDuration?: number
  }
}

export default function PixelatedImageTrail({
  images = [],
  imageSize = 220,
  slices = 5,
  className,
  ...props
}: PixelatedImageTrailProps) {
  const [particles, setParticles] = React.useState<
    Array<{ x: number; y: number; id: number }>
  >([])

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect()
    const x = e.clientX - rect.left
    const y = e.clientY - rect.top
    const id = Date.now() + Math.random()

    setParticles((prev) => [...prev.slice(-12), { x, y, id }])
  }

  return (
    <div
      onMouseMove={handleMouseMove}
      className={cn(
        "relative flex h-[380px] w-full items-center justify-center overflow-hidden rounded-2xl border border-teal-500/20 bg-slate-950/80 shadow-2xl",
        className
      )}
      {...props}
    >
      {/* Background blueprint grid */}
      <div className="pointer-events-none absolute inset-0 bg-[linear-gradient(to_right,#0f172a_1px,transparent_1px),linear-gradient(to_bottom,#0f172a_1px,transparent_1px)] bg-[size:2rem_2rem] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_50%,#000_70%,transparent_100%)] opacity-70" />

      {/* Center Drone Telemetry Reticle */}
      <div className="relative z-10 flex flex-col items-center gap-3">
        <div className="relative flex h-24 w-24 items-center justify-center rounded-full border border-teal-400/40 bg-teal-500/5 shadow-[0_0_30px_rgba(20,184,166,0.15)]">
          <div className="h-12 w-12 rounded-full border border-teal-400/60" />
          <div className="absolute h-1.5 w-1.5 rounded-full bg-teal-400" />
          <div className="absolute -top-1 h-2 w-0.5 bg-teal-400" />
          <div className="absolute -bottom-1 h-2 w-0.5 bg-teal-400" />
          <div className="absolute -left-1 h-0.5 w-2 bg-teal-400" />
          <div className="absolute -right-1 h-0.5 w-2 bg-teal-400" />
        </div>
        <p className="font-mono text-xs font-semibold tracking-widest text-teal-400">
          AEROGUARD QUAD-X • RADAR ACTIVE
        </p>
      </div>

      {/* Sliced trail particles */}
      {particles.map((p) => (
        <div
          key={p.id}
          className="pointer-events-none absolute -translate-x-1/2 -translate-y-1/2 animate-out fade-out duration-700"
          style={{
            left: `${p.x}px`,
            top: `${p.y}px`,
            width: `${imageSize / 4}px`,
            height: `${imageSize / 4}px`,
          }}
        >
          <div className="h-full w-full border border-teal-400/50 bg-teal-400/10 shadow-[0_0_12px_rgba(20,184,166,0.3)]" />
        </div>
      ))}
    </div>
  )
}

export function PixelatedImageTrailDemo() {
  return (
    <div className="relative h-[500px] overflow-hidden rounded-xl bg-black">
      <PixelatedImageTrail
        images={[
          "/trail-images/image1.jpg",
          "/trail-images/image4.jpg",
          "/trail-images/image5.jpg",
        ]}
        imageSize={220}
        slices={5}
        smoothing={0.32}
        spawnThreshold={32}
        config={{
          imageLifespan: 1500,
          inDuration: 280,
          outDuration: 620,
          staggerIn: 12,
          staggerOut: 9,
          slideDuration: 1300,
        }}
      />
    </div>
  )
}
