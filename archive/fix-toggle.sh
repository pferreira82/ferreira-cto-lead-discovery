#!/bin/bash

echo "🔧 Fixing Site-wide Demo Toggle..."
echo "================================="

# 1. Fix demo context with proper hydration handling
echo "🔄 Creating fixed demo context..."
cat > lib/demo-context.tsx << 'EOF'
'use client'

import React, { createContext, useContext, useState, useEffect } from 'react'

interface DemoContextType {
  isDemoMode: boolean
  setIsDemoMode: (demo: boolean) => void
  toggleDemoMode: () => void
  isLoaded: boolean
}

const DemoContext = createContext<DemoContextType | undefined>(undefined)

export function DemoModeProvider({ children }: { children: React.ReactNode }) {
  const [isDemoMode, setIsDemoMode] = useState(true) // Default to demo
  const [isLoaded, setIsLoaded] = useState(false)

  // Load demo mode from localStorage on mount (client-side only)
  useEffect(() => {
    try {
      const savedMode = localStorage.getItem('biotech-demo-mode')
      if (savedMode !== null) {
        setIsDemoMode(JSON.parse(savedMode))
      }
    } catch (error) {
      console.warn('Failed to load demo mode from localStorage:', error)
      setIsDemoMode(true) // Fallback to demo mode
    }
    setIsLoaded(true)
  }, [])

  // Save demo mode to localStorage when it changes (client-side only)
  useEffect(() => {
    if (isLoaded) {
      try {
        localStorage.setItem('biotech-demo-mode', JSON.stringify(isDemoMode))
      } catch (error) {
        console.warn('Failed to save demo mode to localStorage:', error)
      }
    }
  }, [isDemoMode, isLoaded])

  const toggleDemoMode = () => {
    setIsDemoMode(prev => !prev)
  }

  const contextValue = {
    isDemoMode,
    setIsDemoMode,
    toggleDemoMode,
    isLoaded
  }

  return (
    <DemoContext.Provider value={contextValue}>
      {children}
    </DemoContext.Provider>
  )
}

export function useDemoMode() {
  const context = useContext(DemoContext)
  if (context === undefined) {
    throw new Error('useDemoMode must be used within a DemoModeProvider')
  }
  return context
}

// Legacy export for compatibility
export const DemoProvider = DemoModeProvider
EOF

# 2. Fix header component with proper error handling
echo "📱 Creating fixed header component..."
cat > components/layout/header.tsx << 'EOF'
'use client'

import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ThemeToggle } from '@/components/ui/theme-toggle'
import { useDemoMode } from '@/lib/demo-context'
import { Bell, RefreshCw, Plus, Play, Settings, TestTube, Building } from 'lucide-react'
import { toast } from 'react-hot-toast'

export function Header() {
  const { isDemoMode, toggleDemoMode, isLoaded } = useDemoMode()

  const handleToggle = () => {
    try {
      toggleDemoMode()
      const newMode = !isDemoMode
      toast.success(`Switched to ${newMode ? 'Demo' : 'Production'} mode`, {
        icon: newMode ? '🎮' : '⚙️'
      })
    } catch (error) {
      console.error('Failed to toggle demo mode:', error)
      toast.error('Failed to toggle mode')
    }
  }

  // Show loading state while hydrating
  if (!isLoaded) {
    return (
      <header className="h-16 header-bg border-b flex items-center justify-between px-6">
        <div>
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white">Biotech Lead Generation</h2>
          <p className="text-sm text-gray-500 dark:text-gray-400">
            Technology Due Diligence Dashboard • Loading...
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <div className="w-20 h-8 bg-gray-200 dark:bg-gray-700 rounded animate-pulse"></div>
          <ThemeToggle />
        </div>
      </header>
    )
  }

  return (
    <header className="h-16 header-bg border-b flex items-center justify-between px-6">
      <div>
        <h2 className="text-xl font-semibold text-gray-900 dark:text-white">Biotech Lead Generation</h2>
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Technology Due Diligence Dashboard • {isDemoMode ? 'Demo Mode' : 'Production Mode'}
        </p>
      </div>
      
      <div className="flex items-center space-x-4">
        {/* Demo/Production Toggle */}
        <div className="flex items-center space-x-2 px-3 py-1.5 rounded-lg bg-gray-100 dark:bg-gray-800 border">
          <TestTube className={`w-4 h-4 ${isDemoMode ? 'text-blue-600' : 'text-gray-400'}`} />
          <span className="text-sm text-gray-600 dark:text-gray-400">Demo</span>
          <button
            onClick={handleToggle}
            className={`relative inline-flex h-5 w-9 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 ${
              isDemoMode ? 'bg-gray-300 dark:bg-gray-600' : 'bg-green-500'
            }`}
            aria-label={`Switch to ${isDemoMode ? 'Production' : 'Demo'} mode`}
          >
            <span
              className={`inline-block h-3 w-3 transform rounded-full bg-white transition-transform ${
                isDemoMode ? 'translate-x-1' : 'translate-x-5'
              }`}
            />
          </button>
          <span className="text-sm text-gray-600 dark:text-gray-400">Prod</span>
          <Building className={`w-4 h-4 ${!isDemoMode ? 'text-green-600' : 'text-gray-400'}`} />
        </div>

        <Badge 
          variant="secondary" 
          className={`${
            isDemoMode 
              ? 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-400' 
              : 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400'
          }`}
        >
          {isDemoMode ? 'Demo Active' : 'Production Active'}
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

# 3. Fix layout to ensure proper provider wrapping
echo "🏗️ Updating layout with proper provider order..."
cat > app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Sidebar } from '@/components/layout/sidebar'
import { Header } from '@/components/layout/header'
import { ThemeProvider } from '@/components/theme-provider'
import { DemoModeProvider } from '@/lib/demo-context'
import { Toaster } from 'react-hot-toast'

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
          <DemoModeProvider>
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
            <Toaster 
              position="top-right"
              toastOptions={{
                duration: 4000,
                style: {
                  background: 'var(--card)',
                  color: 'var(--card-foreground)',
                  border: '1px solid var(--border)'
                }
              }}
            />
          </DemoModeProvider>
        </ThemeProvider>
      </body>
    </html>
  )
}
EOF

# 4. Create a debug component to test the toggle
echo "🐛 Creating debug component to test demo toggle..."
cat > components/debug-demo-toggle.tsx << 'EOF'
'use client'

import { useDemoMode } from '@/lib/demo-context'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export function DebugDemoToggle() {
  const { isDemoMode, toggleDemoMode, isLoaded } = useDemoMode()

  return (
    <Card className="w-full max-w-md">
      <CardHeader>
        <CardTitle>Demo Toggle Debug</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          <div>
            <strong>Is Loaded:</strong> {isLoaded ? 'Yes' : 'No'}
          </div>
          <div>
            <strong>Current Mode:</strong> {isDemoMode ? 'Demo' : 'Production'}
          </div>
          <div>
            <strong>localStorage value:</strong> 
            <span className="ml-2 font-mono text-sm">
              {typeof window !== 'undefined' ? localStorage.getItem('biotech-demo-mode') : 'N/A (SSR)'}
            </span>
          </div>
          <Button onClick={toggleDemoMode} className="w-full">
            Toggle to {isDemoMode ? 'Production' : 'Demo'}
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
EOF

# 5. Update the discovery page to use the fixed context properly
echo "🔍 Updating discovery page with fixed context usage..."
cat > app/discovery/page.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { 
  Search, 
  Users, 
  Building, 
  RefreshCw,
  Download,
  Target,
  Brain,
  Globe,
  Play,
  Settings
} from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { toast } from 'react-hot-toast'
import { DebugDemoToggle } from '@/components/debug-demo-toggle'

const DEMO_LEADS = [
  {
    id: 'demo-1',
    company: 'BioTech Innovations Inc.',
    industry: 'Biotechnology',
    fundingStage: 'Series B',
    location: 'Boston, MA, USA',
    totalFunding: 45000000,
    contacts: [
      { name: 'Dr. Sarah Chen', title: 'CEO & Co-Founder', role_category: 'Founder' },
      { name: 'Michael Rodriguez', title: 'Chief Technology Officer', role_category: 'Executive' }
    ]
  },
  {
    id: 'demo-2',
    company: 'GenomeTherapeutics',
    industry: 'Gene Therapy',
    fundingStage: 'Series A',
    location: 'San Francisco, CA, USA',
    totalFunding: 28000000,
    contacts: [
      { name: 'Dr. James Liu', title: 'CEO', role_category: 'Founder' }
    ]
  },
  {
    id: 'demo-3',
    company: 'NeuralBio Systems',
    industry: 'Neurotechnology',
    fundingStage: 'Series C',
    location: 'Cambridge, MA, USA',
    totalFunding: 125000000,
    contacts: [
      { name: 'Dr. Amanda Foster', title: 'Co-Founder & CEO', role_category: 'Founder' },
      { name: 'David Park', title: 'Chief Technology Officer', role_category: 'Executive' }
    ]
  }
]

export default function LeadDiscoveryPage() {
  const { isDemoMode, isLoaded } = useDemoMode()
  const [isSearching, setIsSearching] = useState(false)
  const [searchProgress, setSearchProgress] = useState(0)
  const [discoveredLeads, setDiscoveredLeads] = useState([])

  const handleSearch = async () => {
    setIsSearching(true)
    setSearchProgress(0)
    setDiscoveredLeads([])

    try {
      if (isDemoMode) {
        // Demo mode simulation
        for (let i = 25; i <= 100; i += 25) {
          await new Promise(resolve => setTimeout(resolve, 800))
          setSearchProgress(i)
        }
        setDiscoveredLeads(DEMO_LEADS)
        toast.success(`Found ${DEMO_LEADS.length} demo leads!`)
      } else {
        // Production mode (would call real APIs)
        toast.success('Production search would happen here')
        setDiscoveredLeads([])
      }
    } catch (error) {
      console.error('Search error:', error)
      toast.error('Search failed. Please try again.')
    } finally {
      setIsSearching(false)
      setTimeout(() => setSearchProgress(0), 2000)
    }
  }

  const handleLoadDemo = () => {
    setDiscoveredLeads(DEMO_LEADS)
    toast.success(`Loaded ${DEMO_LEADS.length} demo leads!`)
  }

  // Show loading while context loads
  if (!isLoaded) {
    return (
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">AI-Powered Lead Discovery</h1>
            <p className="text-gray-600 dark:text-gray-400">Loading...</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">AI-Powered Lead Discovery</h1>
          <p className="text-gray-600 dark:text-gray-400">
            Discover biotech leads nationwide • Using {isDemoMode ? 'Demo Data' : 'Production APIs'}
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <Button variant="outline" className="flex items-center space-x-2">
            <Download className="w-4 h-4" />
            <span>Export</span>
          </Button>
          <Button 
            onClick={handleSearch} 
            disabled={isSearching} 
            className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600"
          >
            <Search className="w-4 h-4" />
            <span>{isSearching ? 'Searching...' : 'Start Discovery'}</span>
          </Button>
        </div>
      </div>

      {/* Debug Component - Remove this in production */}
      <DebugDemoToggle />

      {/* Mode Info Banner */}
      <Card className={`border-0 shadow-sm ${isDemoMode ? 'bg-blue-50 dark:bg-blue-900/20' : 'bg-green-50 dark:bg-green-900/20'}`}>
        <CardContent className="p-4">
          <div className="flex items-center space-x-3">
            {isDemoMode ? (
              <Play className="w-5 h-5 text-blue-600 dark:text-blue-400" />
            ) : (
              <Settings className="w-5 h-5 text-green-600 dark:text-green-400" />
            )}
            <div>
              <p className={`font-medium ${isDemoMode ? 'text-blue-800 dark:text-blue-300' : 'text-green-800 dark:text-green-300'}`}>
                {isDemoMode ? 'Demo Mode Active' : 'Production Mode Active'}
              </p>
              <p className={`text-sm ${isDemoMode ? 'text-blue-600 dark:text-blue-400' : 'text-green-600 dark:text-green-400'}`}>
                {isDemoMode 
                  ? 'Using sample data for testing and exploration. Toggle to Production in the header for real API calls.'
                  : 'Live system using real APIs (Apollo, Crunchbase, OpenAI) and saving to production database.'
                }
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Quick Demo Load */}
      {discoveredLeads.length === 0 && !isSearching && (
        <Card className="bg-gradient-to-r from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 border-0 shadow-sm">
          <CardContent className="p-6 text-center">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
              Quick Start
            </h3>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              {isDemoMode 
                ? 'Load sample leads instantly to see the discovery system in action'
                : 'Configure search parameters for production lead discovery'
              }
            </p>
            {isDemoMode && (
              <Button 
                onClick={handleLoadDemo}
                className="bg-gradient-to-r from-blue-500 to-purple-600 mr-4"
              >
                <Target className="w-4 h-4 mr-2" />
                Load Demo Leads
              </Button>
            )}
            <Button 
              onClick={handleSearch}
              variant={isDemoMode ? "outline" : "default"}
              className={!isDemoMode ? "bg-gradient-to-r from-blue-500 to-purple-600" : ""}
            >
              <Search className="w-4 h-4 mr-2" />
              Start {isDemoMode ? 'Demo' : 'Production'} Search
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Search Progress */}
      {isSearching && (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardContent className="p-6">
            <div className="flex items-center space-x-4">
              <RefreshCw className="w-5 h-5 animate-spin text-blue-500" />
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900 dark:text-white">
                  Discovering leads... ({isDemoMode ? 'Demo Mode' : 'Production'})
                </p>
                <Progress value={searchProgress} className="mt-2" />
              </div>
              <span className="text-sm text-gray-500 dark:text-gray-400">{searchProgress}%</span>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Results Stats */}
      {discoveredLeads.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Building className="w-8 h-8 mx-auto mb-2 text-blue-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{discoveredLeads.length}</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Companies Found</p>
            </CardContent>
          </Card>
          
          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Users className="w-8 h-8 mx-auto mb-2 text-green-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {discoveredLeads.reduce((sum, lead) => sum + lead.contacts.length, 0)}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Contacts Found</p>
            </CardContent>
          </Card>

          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Brain className="w-8 h-8 mx-auto mb-2 text-purple-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {isDemoMode ? '3' : '0'}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">High-Quality Leads</p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Results List */}
      {discoveredLeads.length > 0 && (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">
              Discovered Leads ({discoveredLeads.length})
            </CardTitle>
            <CardDescription>
              {isDemoMode ? 'Demo data' : 'Production results'} - AI-analyzed biotech companies
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {discoveredLeads.map((lead) => (
                <div key={lead.id} className="p-4 border rounded-lg dark:border-gray-700">
                  <div className="flex justify-between items-start">
                    <div>
                      <h3 className="font-semibold text-gray-900 dark:text-white">{lead.company}</h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">{lead.industry} • {lead.fundingStage}</p>
                      <p className="text-sm text-gray-500 dark:text-gray-400">{lead.location}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-medium text-gray-900 dark:text-white">
                        ${(lead.totalFunding / 1000000).toFixed(1)}M
                      </p>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {lead.contacts.length} contact{lead.contacts.length !== 1 ? 's' : ''}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Empty State */}
      {!isSearching && discoveredLeads.length === 0 && (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardContent className="p-12 text-center">
            <Search className="w-16 h-16 mx-auto mb-4 text-gray-400 dark:text-gray-500" />
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">Ready to Discover Leads</h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              Currently in {isDemoMode ? 'Demo' : 'Production'} mode. 
              {isDemoMode ? ' Click "Load Demo Leads" for instant results.' : ' Configure your search parameters to start.'}
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
EOF

echo ""
echo "✅ Site-wide Demo Toggle Fixed!"
echo ""
echo "🔧 Fixed Issues:"
echo "  - Proper hydration handling to prevent SSR/client mismatch"
echo "  - Better error handling and fallbacks"
echo "  - Loading states while context initializes"
echo "  - Improved localStorage error handling"
echo "  - Added isLoaded state to prevent hydration issues"
echo "  - Debug component to test toggle functionality"
echo ""
echo "🎯 Key Improvements:"
echo "  - Context now handles client/server differences properly"
echo "  - Toggle includes visual feedback and toast notifications"
echo "  - Header shows loading state during hydration"
echo "  - Better accessibility with proper ARIA labels"
echo "  - Consistent naming (DemoModeProvider vs DemoProvider)"
echo ""
echo "🧪 Testing:"
echo "  1. Check the debug component on discovery page"
echo "  2. Toggle should work and persist across page refreshes"
echo "  3. Header should show correct mode immediately"
echo "  4. Toast notifications should appear when toggling"
echo ""
echo "The toggle should now work properly across all pages!"
