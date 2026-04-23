import { cookies } from 'next/headers'
import { getIronSession } from 'iron-session'
import { Header } from '@/components/header'
import { HeroSection } from '@/components/hero-section'
import { ProductCards } from '@/components/product-cards'
import { LandingPlans } from '@/components/landing-plans'
import { Footer } from '@/components/footer'
import { sessionOptions, SessionData } from '@/lib/session'
import { query, queryOne } from '@/lib/db'
import type { SiteSettings, User, SiteSetting, Plan, WorldPlan } from '@/lib/types'

export default async function HomePage() {
  const session = await getIronSession<SessionData>(await cookies(), sessionOptions)

  let user: User | null = null
  if (session.isLoggedIn && session.userId) {
    user = await queryOne<User>(
      'SELECT id, email, full_name, is_admin, created_at, updated_at FROM users WHERE id = ?',
      [session.userId]
    )
  }

  let settings: SiteSettings = {}
  try {
    const settingsRows = await query<SiteSetting[]>(
      'SELECT setting_key, setting_value FROM site_settings'
    )
    settings = settingsRows.reduce((acc, item) => {
      acc[item.setting_key] = item.setting_value
      return acc
    }, {} as SiteSettings)
  } catch {}

  let serverPlans: Plan[] = []
  try {
    serverPlans = await query<Plan[]>(
      'SELECT id, name, slug, price, cpu_percent, ram_mb, storage_mb FROM plans WHERE is_active = 1 ORDER BY sort_order ASC LIMIT 8'
    )
  } catch {}

  let worldPlans: WorldPlan[] = []
  try {
    worldPlans = await query<WorldPlan[]>(
      'SELECT id, name, slug, price, description FROM world_plans WHERE is_active = 1 ORDER BY sort_order ASC LIMIT 4'
    )
  } catch {}

  return (
    <div className="min-h-screen flex flex-col">
      <Header initialUser={user} initialSettings={settings} />

      <main className="flex-1">
        <HeroSection user={user} settings={settings} />
        <ProductCards />
        <LandingPlans serverPlans={serverPlans} worldPlans={worldPlans} />
      </main>

      <Footer settings={settings} />
    </div>
  )
}
