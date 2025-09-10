'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { 
  BarChart3, 
  Building, 
  Mail, 
  Search, 
  Settings, 
  Users,
  Database,
  Target,
  Home
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { ThemeToggle } from '@/components/ui/theme-toggle'
import { useDemoMode } from '@/lib/demo-context'

const navigation = [
  { name: 'Dashboard', href: '/', icon: Home },
  { name: 'Lead Discovery', href: '/discovery', icon: Search },
  { name: 'Contacts', href: '/contacts', icon: Users },
  { name: 'Companies', href: '/companies', icon: Building },
  { name: 'Email Campaigns', href: '/emails', icon: Mail },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
  { name: 'Email Settings', href: '/email-settings', icon: Settings },
]

export function Sidebar() {
  const pathname = usePathname()
  const { isDemoMode, toggleDemoMode } = useDemoMode()

  return (
    <div className="flex flex-col w-64 bg-card border-r border-border">
      {/* Header */}
      <div className="flex items-center justify-between px-6 py-4 border-b border-border">
        <div className="flex items-center">
          <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div className="ml-3">
            <h1 className="text-lg font-semibold text-foreground">Biotech CRM</h1>
            <p className="text-xs text-muted-foreground">Ferreira CTO</p>
          </div>
        </div>
        <ThemeToggle />
      </div>

      {/* Demo Mode Toggle */}
      <div className="px-6 py-3 border-b border-border">
        <div className="flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Demo Mode</span>
          <div className="flex items-center space-x-2">
            {isDemoMode && (
              <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200 text-xs dark:bg-yellow-900/20 dark:text-yellow-400 dark:border-yellow-800">
                Demo
              </Badge>
            )}
            <button
              onClick={toggleDemoMode}
              className={cn(
                "relative inline-flex h-6 w-11 items-center rounded-full transition-colors",
                isDemoMode ? "bg-blue-600" : "bg-muted"
              )}
            >
              <span
                className={cn(
                  "inline-block h-4 w-4 transform rounded-full bg-background transition-transform",
                  isDemoMode ? "translate-x-6" : "translate-x-1"
                )}
              />
            </button>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-6 py-4">
        <ul className="space-y-1">
          {navigation.map((item) => {
            const isActive = pathname === item.href
            return (
              <li key={item.name}>
                <Link
                  href={item.href}
                  className={cn(
                    "flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors",
                    isActive
                      ? "bg-primary/10 text-primary border border-primary/20"
                      : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
                  )}
                >
                  <item.icon
                    className={cn(
                      "mr-3 h-5 w-5",
                      isActive ? "text-primary" : "text-muted-foreground"
                    )}
                  />
                  {item.name}
                </Link>
              </li>
            )
          })}
        </ul>
      </nav>

      {/* Footer */}
      <div className="px-6 py-4 border-t border-border">
        <div className="text-xs text-muted-foreground">
          <p>Technology Due Diligence</p>
          <p>Lead Generation System</p>
        </div>
      </div>
    </div>
  )
}
