'use client'

/**
 * components/hero-section.tsx
 * Landing page hero with dual CTAs for logged-out users.
 * FIX: Previously only showed "Login to Continue" for guests — now shows
 * "Get Started Free" (→ sign-up) + secondary "View Plans" link.
 */

import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { motion } from 'framer-motion'
import { Zap, ArrowRight, Server, Shield, Clock } from 'lucide-react'
import type { User } from '@/lib/types'

interface HeroSectionProps {
  user: User | null
  settings: {
    hero_title?: string
    hero_subtitle?: string
    discord_url?: string
  }
}

const TRUST_BADGES = [
  { icon: Shield, label: 'DDoS Protected' },
  { icon: Server, label: 'Instant Setup' },
  { icon: Clock,  label: '24/7 Monitoring' },
]

export function HeroSection({ user, settings }: HeroSectionProps) {
  const title    = settings.hero_title    || 'CubiqHost — Where Your Minecraft Server Comes Alive Instantly'
  const subtitle = settings.hero_subtitle || 'Affordable, fast & reliable Minecraft hosting built for smooth gameplay.'

  // Split title on em dash for green accent
  const [titleLeft, titleRight] = title.includes('—')
    ? title.split('—')
    : [title, null]

  return (
    <section className="relative py-24 md:py-36 overflow-hidden">
      {/* Background glows */}
      <div className="absolute inset-0 bg-gradient-to-b from-primary/5 via-transparent to-transparent pointer-events-none" />
      <div className="absolute top-20 left-1/4 w-80 h-80 bg-primary/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-20 right-1/4 w-96 h-96 bg-primary/5 rounded-full blur-3xl pointer-events-none" />

      <div className="container mx-auto px-4 relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="max-w-3xl mx-auto text-center"
        >
          {/* Badge */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.1 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 border border-primary/20 text-primary text-sm font-medium mb-6"
          >
            <Zap className="w-4 h-4" />
            Instant Server Deployment
          </motion.div>

          {/* Title */}
          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight text-balance mb-6 leading-tight"
          >
            {titleLeft}
            {titleRight && (
              <>
                <span className="text-primary">—</span>
                {titleRight}
              </>
            )}
          </motion.h1>

          {/* Subtitle */}
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto mb-10 text-pretty"
          >
            {subtitle}
          </motion.p>

          {/* CTAs */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="flex flex-col sm:flex-row items-center justify-center gap-3"
          >
            {user ? (
              // Logged in: go to dashboard or browse plans
              <>
                <Button asChild size="lg" className="gap-2 glow-green min-w-40">
                  <Link href="/dashboard">
                    My Dashboard
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                </Button>
                <Button asChild size="lg" variant="outline" className="min-w-40">
                  <Link href="/plans/server">Browse Plans</Link>
                </Button>
              </>
            ) : (
              // Logged out: sign up primary, view plans secondary
              <>
                <Button asChild size="lg" className="gap-2 glow-green min-w-44">
                  <Link href="/auth/sign-up">
                    Get Started Free
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                </Button>
                <Button asChild size="lg" variant="outline" className="min-w-44">
                  <Link href="/plans/server">View Plans</Link>
                </Button>
              </>
            )}
          </motion.div>

          {/* Trust badges */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.6 }}
            className="flex flex-wrap items-center justify-center gap-6 mt-12"
          >
            {TRUST_BADGES.map(({ icon: Icon, label }) => (
              <div key={label} className="flex items-center gap-2 text-sm text-muted-foreground">
                <Icon className="w-4 h-4 text-primary" />
                {label}
              </div>
            ))}
            {settings.discord_url && (
              <a
                href={settings.discord_url}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-sm text-muted-foreground hover:text-primary transition-colors"
              >
                <svg className="w-4 h-4 text-primary" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057.1 18.08.114 18.1.143 18.116a19.943 19.943 0 0 0 6.002 3.03.078.078 0 0 0 .084-.028c.462-.63.874-1.295 1.226-1.994a.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03z"/>
                </svg>
                Join Discord
              </a>
            )}
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}
