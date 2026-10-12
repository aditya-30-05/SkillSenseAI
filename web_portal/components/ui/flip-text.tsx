"use client"

import * as React from "react"
import { cn } from "@/lib/utils"

export interface FlipTextProps extends React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode
  text?: string
}

export function FlipText({
  children,
  text,
  className,
  ...props
}: FlipTextProps) {
  const content = text || (typeof children === "string" ? children : "")
  const chars = content ? content.split("") : []

  return (
    <div
      className={cn(
        "inline-flex flex-wrap items-center font-bold tracking-tight text-slate-100",
        className
      )}
      {...props}
    >
      {chars.length > 0
        ? chars.map((char, index) => (
            <span
              key={index}
              className="inline-block transition-transform duration-300 ease-out hover:-translate-y-1 hover:text-teal-400"
              style={{
                transitionDelay: `${index * 20}ms`,
              }}
            >
              {char === " " ? "\u00A0" : char}
            </span>
          ))
        : children}
    </div>
  )
}

export default function Example() {
  return (
    <FlipText className="text-4xl font-bold">
      Smart Drone Safety Training
    </FlipText>
  )
}
