#!/bin/bash

# Biotech Lead Generator - Dark Mode Implementation Script
# Adds professional dark theme with toggle functionality

echo "🌙 Adding Dark Mode to Biotech Lead Generator..."
echo "================================================"

# Install theme dependencies
echo "📦 Installing theme dependencies..."
npm install next-themes

# 1. Update globals.css with dark mode support
echo "🎨 Updating CSS with dark mode variables..."
cat > app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 84% 4.9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
    --radius: 0.75rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 217.2 91.2% 59.8%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 224.3 76.3% 94.0%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  
  body {
    @apply bg-background text-foreground;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', sans-serif;
    font-feature-settings: "rlig" 1, "calt" 1;
    line-height: 1.6;
  }

  h1, h2, h3, h4, h5, h6 {
    @apply font-semibold tracking-tight;
  }
}

@layer components {
  /* Light mode gradients */
  .gradient-primary-light {
    background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%);
  }
  
  .gradient-secondary-light {
    background: linear-gradient(135deg, #10B981 0%, #059669 100%);
  }

  /* Dark mode gradients */
  .dark .gradient-primary-light {
    background: linear-gradient(135deg, #1E40AF 0%, #7C3AED 100%);
  }
  
  .dark .gradient-secondary-light {
    background: linear-gradient(135deg, #047857 0%, #065F46 100%);
  }

  /* Sidebar styles for dark mode */
  .sidebar-bg {
    @apply bg-white dark:bg-gray-900 border-gray-200 dark:border-gray-700;
  }

  .sidebar-nav-active {
    @apply bg-gradient-to-r from-blue-500 to-purple-600 text-white shadow-lg shadow-blue-500/25;
  }

  .sidebar-nav-inactive {
    @apply text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-gray-900 dark:hover:text-gray-100;
  }

  /* Card backgrounds for dark mode */
  .card-bg {
    @apply bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700;
  }

  /* Header styles */
  .header-bg {
    @apply bg-white dark:bg-gray-900 border-gray-200 dark:border-gray-700;
  }

  /* Welcome section gradients */
  .welcome-gradient {
    @apply bg-gradient-to-r from-blue-600 to-purple-700 dark:from-blue-800 dark:to-purple-900;
  }

  /* Stats card gradients */
  .stats-blue {
    @apply bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20;
  }

  .stats-purple {
    @apply bg-gradient-to-br from-purple-50 to-purple-100 dark:from-purple-900/20 dark:to-purple-800/20;
  }

  .stats-green {
    @apply bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20;
  }

  .stats-orange {
    @apply bg-gradient-to-br from-orange-50 to-orange-100 dark:from-orange-900/20 dark:to-orange-800/20;
  }

  /* Text colors for stats */
  .text-blue-stat {
    @apply text-blue-600 dark:text-blue-400;
  }

  .text-blue-stat-bold {
    @apply text-blue-900 dark:text-blue-100;
  }

  .text-purple-stat {
    @apply text-purple-600 dark:text-purple-400;
  }

  .text-purple-stat-bold {
    @apply text-purple-900 dark:text-purple-100;
  }

  .text-green-stat {
    @apply text-green-600 dark:text-green-400;
  }

  .text-green-stat-bold {
    @apply text-green-900 dark:text-green-100;
  }

  .text-orange-stat {
    @apply text-orange-600 dark:text-orange-400;
  }

  .text-orange-stat-bold {
    @apply text-orange-900 dark:text-orange-100;
  }
}

/* Dark mode transition */
* {
  transition: background-color 0.3s ease, border-color 0.3s ease, color 0.3s ease;
}

/* Custom scrollbar for dark mode */
::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-track {
  @apply bg-gray-100 dark:bg-gray-800;
}

::-webkit-scrollbar-thumb {
  @apply bg-gray-300 dark:bg-gray-600 rounded;
}

::-webkit-scrollbar-thumb:hover {
  @apply bg-gray-400 dark:bg-gray-500;
}

/* Layout fixes for dark mode */
.layout-fix {
  min-height: 100vh;
  @apply bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800;
}

.sidebar-fixed {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: 16rem;
  z-index: 50;
}

.main-content {
  margin-left: 16rem;
  min-height: 100vh;
}

.header-fixed {
  height: 4rem;
  position: sticky;
  top: 0;
  z-index: 40;
}

.content-container {
  padding: 1.5rem;
}
EOF

# 2. Create theme provider
echo "🔧 Creating theme provider..."
cat > components/theme-provider.tsx << 'EOF'
'use client'

import * as React from 'react'
import { ThemeProvider as NextThemesProvider } from 'next-themes'
import { type ThemeProviderProps } from 'next-themes/dist/types'

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
EOF

# 3. Create theme toggle component
echo "🔘 Creating theme toggle component..."
cat > components/ui/theme-toggle.tsx << 'EOF'
'use client'

import * as React from 'react'
import { Moon, Sun } from 'lucide-react'
import { useTheme } from 'next-themes'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

export function ThemeToggle() {
  const { setTheme } = useTheme()

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="outline" size="sm">
          <Sun className="h-4 w-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
          <Moon className="absolute h-4 w-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
          <span className="sr-only">Toggle theme</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem onClick={() => setTheme('light')}>
          Light
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme('dark')}>
          Dark
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme('system')}>
          System
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
EOF

# 4. Update layout with theme provider
echo "🏗️ Updating layout with theme provider..."
cat > app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Sidebar } from '@/components/layout/sidebar'
import { Header } from '@/components/layout/header'
import { ThemeProvider } from '@/components/theme-provider'

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter'
})

export const metadata: Metadata = {
  title: 'Biotech Lead Generator - Ferreira CTO',
  description: 'Technology due diligence lead generation for biotech companies',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable} suppressHydrationWarning>
      <body className={`${inter.className} layout-fix`}>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800">
            <div className="sidebar-fixed">
              <Sidebar />
            </div>
            <div className="main-content">
              <div className="header-fixed">
                <Header />
              </div>
              <main className="content-container">
                {children}
              </main>
            </div>
          </div>
        </ThemeProvider>
      </body>
    </html>
  )
}
EOF

# 5. Update sidebar with dark mode support
echo "📱 Updating sidebar with dark mode..."
cat > components/layout/sidebar.tsx << 'EOF'
'use client'

import { useState } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'
import {
  LayoutDashboard,
  Users,
  Mail,
  BarChart3,
  Settings,
  Zap,
  Building,
  Search,
  Database
} from 'lucide-react'

const navigation = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Contacts', href: '/contacts', icon: Users },
  { name: 'Companies', href: '/companies', icon: Building },
  { name: 'Lead Discovery', href: '/discovery', icon: Search },
  { name: 'Email Campaigns', href: '/emails', icon: Mail },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
  { name: 'Data Sync', href: '/sync', icon: Database },
  { name: 'Settings', href: '/settings', icon: Settings },
]

export function Sidebar() {
  const pathname = usePathname()

  return (
    <div className="sidebar-bg shadow-xl border-r">
      {/* Logo */}
      <div className="flex h-16 items-center px-6 border-b border-gray-200 dark:border-gray-700">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
            <Zap className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-lg font-bold text-gray-900 dark:text-white">Ferreira CTO</h1>
            <p className="text-xs text-gray-500 dark:text-gray-400">Lead Generator</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="mt-6 px-3">
        <div className="space-y-1">
          {navigation.map((item) => {
            const isActive = pathname === item.href
            return (
              <Link
                key={item.name}
                href={item.href}
                className={cn(
                  'group flex items-center px-3 py-2.5 text-sm font-medium rounded-lg transition-all duration-200',
                  isActive
                    ? 'sidebar-nav-active'
                    : 'sidebar-nav-inactive'
                )}
              >
                <item.icon
                  className={cn(
                    'mr-3 h-5 w-5 flex-shrink-0',
                    isActive
                      ? 'text-white'
                      : 'text-gray-400 dark:text-gray-500 group-hover:text-gray-500 dark:group-hover:text-gray-400'
                  )}
                />
                {item.name}
              </Link>
            )
          })}
        </div>
      </nav>

      {/* Footer */}
      <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-200 dark:border-gray-700">
        <div className="text-xs text-gray-500 dark:text-gray-400">
          <p className="font-medium">Biotech Due Diligence</p>
          <p>peter@ferreiracto.com</p>
        </div>
      </div>
    </div>
  )
}
EOF

# 6. Update header with theme toggle
echo "📋 Updating header with theme toggle..."
cat > components/layout/header.tsx << 'EOF'
'use client'

import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ThemeToggle } from '@/components/ui/theme-toggle'
import { Bell, RefreshCw, Plus } from 'lucide-react'

export function Header() {
  return (
    <header className="h-16 header-bg border-b flex items-center justify-between px-6">
      <div>
        <h2 className="text-xl font-semibold text-gray-900 dark:text-white">Biotech Lead Generation</h2>
        <p className="text-sm text-gray-500 dark:text-gray-400">Technology Due Diligence Dashboard</p>
      </div>
      
      <div className="flex items-center space-x-4">
        <Badge variant="secondary" className="bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400">
          System Active
        </Badge>
        
        <Button variant="outline" size="sm" className="flex items-center space-x-2">
          <RefreshCw className="w-4 h-4" />
          <span>Sync Data</span>
        </Button>
        
        <Button size="sm" className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700">
          <Plus className="w-4 h-4" />
          <span>New Campaign</span>
        </Button>

        <ThemeToggle />
        
        <div className="relative">
          <Button variant="ghost" size="sm">
            <Bell className="w-5 h-5" />
          </Button>
          <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></div>
        </div>
      </div>
    </header>
  )
}
EOF

# 7. Update dashboard with dark mode classes
echo "📊 Updating dashboard with dark mode support..."
cat > app/page.tsx << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { 
  Users, 
  Building, 
  Mail, 
  TrendingUp, 
  Target,
  Activity
} from 'lucide-react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'

interface DashboardStats {
  totalContacts: number
  totalCompanies: number
  emailsSent: number
  responseRate: number
  contactedThisWeek: number
  notContactedCount: number
  pipeline_value: number
  active_campaigns: number
}

export default function Dashboard() {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setTimeout(() => {
      setStats({
        totalContacts: 1247,
        totalCompanies: 186,
        emailsSent: 892,
        responseRate: 23.5,
        contactedThisWeek: 47,
        notContactedCount: 723,
        pipeline_value: 2400000,
        active_campaigns: 5
      })
      setLoading(false)
    }, 1000)
  }, [])

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[...Array(4)].map((_, i) => (
            <Card key={i} className="animate-pulse card-bg">
              <CardContent className="p-6">
                <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2 mb-2"></div>
                <div className="h-8 bg-gray-200 dark:bg-gray-700 rounded w-1/3"></div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  const chartData = [
    { date: 'Sep 1', contacts: 45, emails: 25, responses: 6 },
    { date: 'Sep 2', contacts: 52, emails: 30, responses: 8 },
    { date: 'Sep 3', contacts: 48, emails: 22, responses: 5 },
    { date: 'Sep 4', contacts: 61, emails: 35, responses: 12 },
    { date: 'Sep 5', contacts: 55, emails: 28, responses: 9 },
    { date: 'Sep 6', contacts: 47, emails: 20, responses: 4 },
    { date: 'Sep 7', contacts: 38, emails: 15, responses: 3 },
  ]

  const companyData = [
    { stage: 'Series A', count: 75, color: '#3B82F6' },
    { stage: 'Series B', count: 64, color: '#8B5CF6' },
    { stage: 'Series C', count: 47, color: '#06B6D4' },
  ]

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="welcome-gradient rounded-2xl p-8 text-white">
        <h1 className="text-2xl font-bold mb-2">Welcome back, Peter</h1>
        <p className="text-blue-100 dark:text-blue-200">
          Your biotech lead generation system has discovered {stats?.totalContacts} contacts 
          across {stats?.totalCompanies} Series A-C companies this month.
        </p>
        <div className="flex items-center mt-4 space-x-4">
          <Badge className="bg-white/20 text-white border-white/30">
            {stats?.active_campaigns} Active Campaigns
          </Badge>
          <Badge className="bg-white/20 text-white border-white/30">
            {stats?.responseRate}% Response Rate
          </Badge>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="border-0 shadow-lg stats-blue">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-blue-stat">Total Contacts</p>
                <p className="text-3xl font-bold text-blue-stat-bold">{stats?.totalContacts.toLocaleString()}</p>
                <p className="text-xs text-blue-stat mt-1">
                  {stats?.notContactedCount} not contacted
                </p>
              </div>
              <div className="w-12 h-12 bg-blue-500 rounded-xl flex items-center justify-center">
                <Users className="w-6 h-6 text-white" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg stats-purple">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-purple-stat">Companies</p>
                <p className="text-3xl font-bold text-purple-stat-bold">{stats?.totalCompanies}</p>
                <p className="text-xs text-purple-stat mt-1">Biotech Series A-C</p>
              </div>
              <div className="w-12 h-12 bg-purple-500 rounded-xl flex items-center justify-center">
                <Building className="w-6 h-6 text-white" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg stats-green">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-green-stat">Emails Sent</p>
                <p className="text-3xl font-bold text-green-stat-bold">{stats?.emailsSent}</p>
                <p className="text-xs text-green-stat mt-1">
                  {stats?.contactedThisWeek} this week
                </p>
              </div>
              <div className="w-12 h-12 bg-green-500 rounded-xl flex items-center justify-center">
                <Mail className="w-6 h-6 text-white" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg stats-orange">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-orange-stat">Response Rate</p>
                <p className="text-3xl font-bold text-orange-stat-bold">{stats?.responseRate}%</p>
                <Progress value={stats?.responseRate} className="mt-2 h-2" />
              </div>
              <div className="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center">
                <TrendingUp className="w-6 h-6 text-white" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card className="border-0 shadow-lg card-bg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">Lead Generation Activity</CardTitle>
            <CardDescription>Daily performance over the last 7 days</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" className="dark:stroke-gray-700" />
                <XAxis dataKey="date" stroke="#64748b" className="dark:stroke-gray-400" />
                <YAxis stroke="#64748b" className="dark:stroke-gray-400" />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: 'var(--card)',
                    borderColor: 'var(--border)',
                    color: 'var(--card-foreground)',
                    borderRadius: '8px',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                  }} 
                />
                <Line type="monotone" dataKey="contacts" stroke="#3B82F6" strokeWidth={3} />
                <Line type="monotone" dataKey="emails" stroke="#8B5CF6" strokeWidth={3} />
                <Line type="monotone" dataKey="responses" stroke="#10B981" strokeWidth={3} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg card-bg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">Companies by Funding Stage</CardTitle>
            <CardDescription>Distribution of biotech companies in pipeline</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={companyData}
                  cx="50%"
                  cy="50%"
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="count"
                  label={({ stage, count }) => `${stage}: ${count}`}
                >
                  {companyData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ 
                  backgroundColor: 'var(--card)',
                  borderColor: 'var(--border)',
                  color: 'var(--card-foreground)'
                }} />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <Card className="border-0 shadow-lg card-bg">
        <CardHeader>
          <CardTitle className="text-gray-900 dark:text-white">Quick Actions</CardTitle>
          <CardDescription>Common tasks and workflows</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Button className="h-20 flex-col space-y-2 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700">
              <Target className="w-6 h-6" />
              <span>Discover New Leads</span>
            </Button>
            <Button className="h-20 flex-col space-y-2 bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700">
              <Mail className="w-6 h-6" />
              <span>Send Email Campaign</span>
            </Button>
            <Button className="h-20 flex-col space-y-2 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700">
              <Activity className="w-6 h-6" />
              <span>View Analytics</span>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
EOF

echo ""
echo "🌙 Dark Mode Implementation Complete!"
echo ""
echo "✅ Added:"
echo "  - Dark theme with professional color scheme"
echo "  - Theme toggle button in header"
echo "  - System theme detection"
echo "  - Smooth transitions between themes"
echo "  - Dark mode optimized gradients"
echo "  - Updated all components for dark mode"
echo ""
echo "🚀 How to use:"
echo "  1. Look for the sun/moon icon in the header"
echo "  2. Click to toggle between Light/Dark/System themes"
echo "  3. Theme preference is saved automatically"
echo ""
echo "The theme toggle is in the top-right corner of the header!"
