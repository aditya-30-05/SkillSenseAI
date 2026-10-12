"use client"

import * as React from "react"
import { cn } from "@/lib/utils"

export interface FlipFadeTextProps
  extends React.HTMLAttributes<HTMLDivElement> {
  words: string[]
  interval?: number
  prefix?: string
}

export function FlipFadeText({
  words,
  interval = 3000,
  prefix,
  className,
  ...props
}: FlipFadeTextProps) {
  const [index, setIndex] = React.useState(0)
  const [isFlipping, setIsFlipping] = React.useState(false)

  React.useEffect(() => {
    if (words.length <= 1) return
    const timer = setInterval(() => {
      setIsFlipping(true)
      setTimeout(() => {
        setIndex((prev) => (prev + 1) % words.length)
        setIsFlipping(false)
      }, 350)
    }, interval)

    return () => clearInterval(timer)
  }, [words, interval])

  return (
    <div
      className={cn(
        "inline-flex items-center gap-2 font-bold tracking-tight text-teal-400",
        className
      )}
      {...props}
    >
      {prefix && <span className="text-slate-400">{prefix}</span>}
      <span
        className={cn(
          "inline-block transition-all duration-300 ease-out",
          isFlipping
            ? "-translate-y-2 opacity-0 rotate-x-90"
            : "translate-y-0 opacity-100 rotate-x-0"
        )}
      >
        {words[index]}
      </span>
    </div>
  )
}

export function FlipFadeTextDemo() {
  return (
    <FlipFadeText
      words={["Beautiful", "Dynamic", "Powerful"]}
      className="text-4xl font-bold"
    />
  )
}
