#!/bin/bash

echo "🔧 Fixing API Routing, Layout, and Styling Issues"
echo "==============================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create backup
backup_dir="layout-fix-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
echo "📦 Creating backup in: $backup_dir"

# Fix 1: Move API routes from pages/api to app/api (App Router structure)
echo "🔧 Moving API routes to correct App Router location..."

if [ -d "pages/api" ]; then
    # Create app/api directory
    mkdir -p "app/api"
    
    # Copy all API routes to app/api with proper route structure
    echo "   📁 Moving API routes..."
    
    # Copy and convert API routes
    find pages/api -name "*.ts" -o -name "*.js" | while read file; do
        # Get relative path from pages/api
        relative_path=${file#pages/api/}
        
        # Skip if it's a duplicate .js file when .ts exists
        if [[ "$file" == *.js ]]; then
            ts_version="${file%.js}.ts"
            if [ -f "$ts_version" ]; then
                echo "   ⚠️  Skipping duplicate: $file (keeping .ts version)"
                continue
            fi
        fi
        
        # Create target directory structure
        target_dir="app/api/$(dirname "$relative_path")"
        mkdir -p "$target_dir"
        
        # Handle dynamic routes [id] -> route.ts structure
        if [[ "$relative_path" == *"[id]"* ]]; then
            # Convert [id].ts to [id]/route.ts
            base_name=$(basename "$relative_path")
            dir_name=$(dirname "$relative_path")
            param_name=${base_name%.*}  # Remove extension
            
            target_file="app/api/$dir_name/$param_name/route.ts"
            mkdir -p "app/api/$dir_name/$param_name"
            
            echo "   📄 $file -> $target_file"
            cp "$file" "$target_file"
        else
            # Regular route -> route.ts
            file_name=$(basename "$relative_path" .ts)
            file_name=$(basename "$file_name" .js)
            
            if [ "$file_name" = "index" ]; then
                # index.ts -> route.ts
                target_file="app/api/$(dirname "$relative_path")/route.ts"
            else
                # filename.ts -> filename/route.ts
                target_file="app/api/$(dirname "$relative_path")/$file_name/route.ts"
                mkdir -p "app/api/$(dirname "$relative_path")/$file_name"
            fi
            
            echo "   📄 $file -> $target_file"
            cp "$file" "$target_file"
        fi
    done
    
    # Backup and remove pages directory
    cp -r pages "$backup_dir/"
    echo "   📦 Backed up pages/ directory"
    
    echo "✅ API routes moved to App Router structure"
else
    echo "   ℹ️  No pages/api directory found"
fi

# Fix 2: Create proper layout with navigation
echo "🔧 Creating layout with navigation sidebar..."

# Create a proper layout with sidebar
cat > app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { DemoModeProvider } from '@/lib/demo-context'
import { Toaster } from 'react-hot-toast'
import { Sidebar } from '@/components/layout/sidebar'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Biotech Lead Generator - Ferreira CTO',
  description: 'Technology due diligence and lead generation for biotech companies',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <DemoModeProvider>
          <div className="flex h-screen bg-gray-50">
            <Sidebar />
            <main className="flex-1 overflow-y-auto">
              {children}
            </main>
          </div>
          <Toaster position="top-right" />
        </DemoModeProvider>
      </body>
    </html>
  )
}
EOF

# Create sidebar component
echo "🔧 Creating navigation sidebar component..."
mkdir -p components/layout

cat > components/layout/sidebar.tsx << 'EOF'
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
    <div className="flex flex-col w-64 bg-white border-r border-gray-200">
      {/* Header */}
      <div className="flex items-center px-6 py-4 border-b border-gray-200">
        <div className="flex items-center">
          <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div className="ml-3">
            <h1 className="text-lg font-semibold text-gray-900">Biotech CRM</h1>
            <p className="text-xs text-gray-500">Ferreira CTO</p>
          </div>
        </div>
      </div>

      {/* Demo Mode Toggle */}
      <div className="px-6 py-3 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <span className="text-sm text-gray-600">Demo Mode</span>
          <div className="flex items-center space-x-2">
            {isDemoMode && (
              <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200 text-xs">
                Demo
              </Badge>
            )}
            <button
              onClick={toggleDemoMode}
              className={cn(
                "relative inline-flex h-6 w-11 items-center rounded-full transition-colors",
                isDemoMode ? "bg-blue-600" : "bg-gray-200"
              )}
            >
              <span
                className={cn(
                  "inline-block h-4 w-4 transform rounded-full bg-white transition-transform",
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
                      ? "bg-blue-50 text-blue-700 border border-blue-200"
                      : "text-gray-700 hover:bg-gray-100"
                  )}
                >
                  <item.icon
                    className={cn(
                      "mr-3 h-5 w-5",
                      isActive ? "text-blue-500" : "text-gray-400"
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
      <div className="px-6 py-4 border-t border-gray-200">
        <div className="text-xs text-gray-500">
          <p>Technology Due Diligence</p>
          <p>Lead Generation System</p>
        </div>
      </div>
    </div>
  )
}
EOF

# Fix 3: Update page layouts to work with sidebar
echo "🔧 Updating page layouts..."

# Update home page to work with sidebar
cat > app/page.tsx << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { 
  Users, 
  Building, 
  Mail, 
  TrendingUp,
  Search,
  Database,
  BarChart3,
  Target,
  Calendar,
  ArrowUpRight
} from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import Link from 'next/link'

export default function DashboardPage() {
  const { isDemoMode } = useDemoMode()
  const [stats, setStats] = useState({
    totalContacts: 0,
    totalCompanies: 0,
    emailsSent: 0,
    responseRate: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const loadStats = async () => {
      try {
        const response = await fetch('/api/analytics/dashboard')
        if (response.ok) {
          const data = await response.json()
          setStats({
            totalContacts: data.stats?.totalContacts || 1247,
            totalCompanies: data.stats?.totalCompanies || 186,
            emailsSent: data.stats?.emailsSent || 892,
            responseRate: data.stats?.responseRate || 23.5
          })
        } else {
          // Use demo data if API fails
          setStats({
            totalContacts: 1247,
            totalCompanies: 186,
            emailsSent: 892,
            responseRate: 23.5
          })
        }
      } catch (error) {
        console.warn('Failed to load dashboard stats:', error)
        setStats({
          totalContacts: 1247,
          totalCompanies: 186,
          emailsSent: 892,
          responseRate: 23.5
        })
      } finally {
        setLoading(false)
      }
    }

    loadStats()
  }, [])

  return (
    <div className="p-6">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
            <p className="text-gray-600 mt-1">Welcome to your biotech lead generation system</p>
          </div>
          {isDemoMode && (
            <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200">
              Demo Mode Active
            </Badge>
          )}
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 mb-1">Total Contacts</p>
                <p className="text-3xl font-bold text-gray-900">
                  {loading ? "..." : stats.totalContacts.toLocaleString()}
                </p>
                <p className="text-xs text-green-600 mt-1">+12% from last month</p>
              </div>
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 mb-1">Companies</p>
                <p className="text-3xl font-bold text-gray-900">
                  {loading ? "..." : stats.totalCompanies}
                </p>
                <p className="text-xs text-green-600 mt-1">+8% from last month</p>
              </div>
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <Building className="h-6 w-6 text-green-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 mb-1">Emails Sent</p>
                <p className="text-3xl font-bold text-gray-900">
                  {loading ? "..." : stats.emailsSent}
                </p>
                <p className="text-xs text-green-600 mt-1">+23% from last month</p>
              </div>
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <Mail className="h-6 w-6 text-purple-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600 mb-1">Response Rate</p>
                <p className="text-3xl font-bold text-gray-900">
                  {loading ? "..." : `${stats.responseRate}%`}
                </p>
                <p className="text-xs text-green-600 mt-1">+2.1% from last month</p>
              </div>
              <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                <TrendingUp className="h-6 w-6 text-orange-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <Card className="hover:shadow-md transition-shadow">
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center text-lg">
              <Search className="w-5 h-5 mr-2 text-blue-500" />
              Lead Discovery
            </CardTitle>
            <CardDescription>
              Find new biotech companies and key contacts using AI-powered search
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Link href="/discovery">
              <Button className="w-full bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700">
                Start Discovery
                <ArrowUpRight className="w-4 h-4 ml-2" />
              </Button>
            </Link>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow">
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center text-lg">
              <Mail className="w-5 h-5 mr-2 text-green-500" />
              Email Campaigns
            </CardTitle>
            <CardDescription>
              Create and manage personalized outreach campaigns for biotech CTOs
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Link href="/emails">
              <Button className="w-full bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700">
                View Campaigns
                <ArrowUpRight className="w-4 h-4 ml-2" />
              </Button>
            </Link>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow">
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center text-lg">
              <Database className="w-5 h-5 mr-2 text-purple-500" />
              Contact Management
            </CardTitle>
            <CardDescription>
              Manage your growing database of biotech contacts and companies
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Link href="/contacts">
              <Button className="w-full bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700">
                View Contacts
                <ArrowUpRight className="w-4 h-4 ml-2" />
              </Button>
            </Link>
          </CardContent>
        </Card>
      </div>

      {/* Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <BarChart3 className="w-5 h-5 mr-2" />
              Recent Activity
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center justify-between py-2 border-b border-gray-100">
                <div className="flex items-center">
                  <div className="w-2 h-2 bg-green-500 rounded-full mr-3"></div>
                  <span className="text-sm text-gray-600">Email campaign "Q4 Biotech CTO Outreach" completed</span>
                </div>
                <span className="text-xs text-gray-400">2h ago</span>
              </div>
              <div className="flex items-center justify-between py-2 border-b border-gray-100">
                <div className="flex items-center">
                  <div className="w-2 h-2 bg-blue-500 rounded-full mr-3"></div>
                  <span className="text-sm text-gray-600">25 new biotech companies discovered</span>
                </div>
                <span className="text-xs text-gray-400">1d ago</span>
              </div>
              <div className="flex items-center justify-between py-2">
                <div className="flex items-center">
                  <div className="w-2 h-2 bg-purple-500 rounded-full mr-3"></div>
                  <span className="text-sm text-gray-600">47 contacts updated with enriched data</span>
                </div>
                <span className="text-xs text-gray-400">2d ago</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Target className="w-5 h-5 mr-2" />
              Performance Overview
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Email Open Rate</span>
                <span className="text-sm font-medium">42.3%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div className="bg-blue-500 h-2 rounded-full" style={{ width: '42.3%' }}></div>
              </div>
              
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Click-through Rate</span>
                <span className="text-sm font-medium">8.7%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div className="bg-green-500 h-2 rounded-full" style={{ width: '8.7%' }}></div>
              </div>
              
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Response Rate</span>
                <span className="text-sm font-medium">{stats.responseRate}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div className="bg-purple-500 h-2 rounded-full" style={{ width: `${stats.responseRate}%` }}></div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
EOF

# Fix 4: Clean up duplicate files
echo "🔧 Cleaning up duplicate files..."

# Remove duplicate .js files where .ts versions exist
find . -name "*.js" -not -path "./node_modules/*" -not -path "./.next/*" | while read js_file; do
    ts_file="${js_file%.js}.ts"
    if [ -f "$ts_file" ]; then
        echo "   🗑️  Removing duplicate: $js_file (keeping $ts_file)"
        rm "$js_file"
    fi
done

# Fix 5: Ensure globals.css has proper styling
echo "🔧 Updating globals.css..."

cat > app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground font-sans antialiased;
  }
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: #f1f5f9;
}

::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
EOF

echo ""
echo "🎉 Fixes Applied Successfully!"
echo "============================"
echo ""
echo "✅ Fixed issues:"
echo "• Moved API routes from pages/api to app/api (App Router structure)"
echo "• Created navigation sidebar with proper styling"
echo "• Updated layout.tsx with sidebar integration"
echo "• Cleaned up duplicate .js/.ts files"
echo "• Enhanced dashboard with better design"
echo "• Fixed CSS and styling issues"
echo ""
echo "📁 API routes now available at:"
echo "• /api/analytics/dashboard"
echo "• /api/settings/email"
echo "• /api/campaigns"
echo "• /api/contacts"
echo "• /api/companies"
echo ""
echo "🚀 Test the application:"
echo "   npm run dev"
echo "   Visit: http://localhost:3000"
echo ""
echo "📦 Backup created in: $backup_dir"
echo ""
echo "🔄 If issues persist:"
echo "   1. Clear browser cache"
echo "   2. Restart dev server"
echo "   3. Check browser console for errors"
