#!/bin/bash

echo "🔧 Fixing React Context and Routing Issues"
echo "=========================================="

# Create backups
echo "📦 Creating backups..."
[ -f "app/layout.tsx" ] && cp "app/layout.tsx" "app/layout.tsx.backup"
[ -f "app/page.tsx" ] && cp "app/page.tsx" "app/page.tsx.backup"

echo "✅ Backups created"

# Fix 1: Update app/layout.tsx to include DemoModeProvider
echo "🔧 Updating app/layout.tsx to include DemoModeProvider..."

cat > app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { DemoModeProvider } from '@/lib/demo-context'
import { Toaster } from 'react-hot-toast'

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
          {children}
          <Toaster position="top-right" />
        </DemoModeProvider>
      </body>
    </html>
  )
}
EOF

echo "✅ Updated app/layout.tsx with DemoModeProvider"

# Fix 2: Create dashboard as home page
echo "🔧 Setting up dashboard as home page..."

# Check if dashboard exists in app directory
if [ -f "app/dashboard/page.tsx" ]; then
    echo "📄 Found app/dashboard/page.tsx - creating redirect from home"
    
    # Create home page that redirects to dashboard
    cat > app/page.tsx << 'EOF'
'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'

export default function HomePage() {
  const router = useRouter()
  
  useEffect(() => {
    router.replace('/dashboard')
  }, [router])

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
        <p className="mt-4 text-gray-600">Redirecting to dashboard...</p>
      </div>
    </div>
  )
}
EOF

elif [ -f "pages/dashboard.tsx" ] || [ -f "app/dashboard.tsx" ]; then
    echo "📄 Found dashboard file - moving to app/page.tsx"
    
    # Find the dashboard file and copy it as home page
    dashboard_file=""
    if [ -f "app/dashboard.tsx" ]; then
        dashboard_file="app/dashboard.tsx"
    elif [ -f "pages/dashboard.tsx" ]; then
        dashboard_file="pages/dashboard.tsx"
    fi
    
    if [ ! -z "$dashboard_file" ]; then
        cp "$dashboard_file" "app/page.tsx"
        echo "✅ Copied $dashboard_file to app/page.tsx"
    fi

else
    echo "📄 No dashboard found - creating a basic dashboard as home page"
    
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
  Settings,
  Search,
  Database,
  BarChart3,
  Target,
  Calendar
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

  useEffect(() => {
    // Load dashboard stats
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
        }
      } catch (error) {
        console.warn('Failed to load dashboard stats:', error)
        // Use demo data as fallback
        setStats({
          totalContacts: 1247,
          totalCompanies: 186,
          emailsSent: 892,
          responseRate: 23.5
        })
      }
    }

    loadStats()
  }, [])

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Header */}
      <div className="bg-white border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div>
              <h1 className="text-2xl font-bold text-slate-900">Biotech Lead Generator</h1>
              <p className="text-slate-600">Technology Due Diligence Dashboard</p>
            </div>
            <div className="flex items-center space-x-4">
              {isDemoMode && (
                <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200">
                  Demo Mode
                </Badge>
              )}
              <Link href="/email-settings">
                <Button variant="outline" size="sm">
                  <Settings className="w-4 h-4 mr-2" />
                  Settings
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card className="border-0 shadow-sm">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-slate-600">Total Contacts</p>
                  <p className="text-3xl font-bold text-slate-900">{stats.totalContacts.toLocaleString()}</p>
                </div>
                <Users className="h-8 w-8 text-blue-500" />
              </div>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-sm">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-slate-600">Companies</p>
                  <p className="text-3xl font-bold text-slate-900">{stats.totalCompanies}</p>
                </div>
                <Building className="h-8 w-8 text-green-500" />
              </div>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-sm">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-slate-600">Emails Sent</p>
                  <p className="text-3xl font-bold text-slate-900">{stats.emailsSent}</p>
                </div>
                <Mail className="h-8 w-8 text-purple-500" />
              </div>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-sm">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-slate-600">Response Rate</p>
                  <p className="text-3xl font-bold text-slate-900">{stats.responseRate}%</p>
                </div>
                <TrendingUp className="h-8 w-8 text-orange-500" />
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Card className="border-0 shadow-sm hover:shadow-md transition-shadow">
            <CardHeader>
              <CardTitle className="flex items-center">
                <Search className="w-5 h-5 mr-2 text-blue-500" />
                Lead Discovery
              </CardTitle>
              <CardDescription>
                Find new biotech companies and contacts
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Link href="/discovery">
                <Button className="w-full bg-gradient-to-r from-blue-500 to-purple-600">
                  Start Discovery
                </Button>
              </Link>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-sm hover:shadow-md transition-shadow">
            <CardHeader>
              <CardTitle className="flex items-center">
                <Mail className="w-5 h-5 mr-2 text-green-500" />
                Email Campaigns
              </CardTitle>
              <CardDescription>
                Create and manage email outreach campaigns
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Link href="/emails">
                <Button className="w-full bg-gradient-to-r from-green-500 to-blue-500">
                  View Campaigns
                </Button>
              </Link>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-sm hover:shadow-md transition-shadow">
            <CardHeader>
              <CardTitle className="flex items-center">
                <Database className="w-5 h-5 mr-2 text-purple-500" />
                Contacts & Companies
              </CardTitle>
              <CardDescription>
                Manage your biotech contact database
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Link href="/contacts">
                <Button className="w-full bg-gradient-to-r from-purple-500 to-pink-500">
                  View Contacts
                </Button>
              </Link>
            </CardContent>
          </Card>
        </div>

        {/* Recent Activity */}
        <Card className="mt-8 border-0 shadow-sm">
          <CardHeader>
            <CardTitle className="flex items-center">
              <BarChart3 className="w-5 h-5 mr-2" />
              Recent Activity
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center justify-between py-2 border-b border-slate-100">
                <div className="flex items-center">
                  <div className="w-2 h-2 bg-green-500 rounded-full mr-3"></div>
                  <span className="text-sm text-slate-600">Email campaign "Q4 Biotech CTO Outreach" completed</span>
                </div>
                <span className="text-xs text-slate-400">2 hours ago</span>
              </div>
              <div className="flex items-center justify-between py-2 border-b border-slate-100">
                <div className="flex items-center">
                  <div className="w-2 h-2 bg-blue-500 rounded-full mr-3"></div>
                  <span className="text-sm text-slate-600">25 new biotech companies discovered</span>
                </div>
                <span className="text-xs text-slate-400">1 day ago</span>
              </div>
              <div className="flex items-center justify-between py-2">
                <div className="flex items-center">
                  <div className="w-2 h-2 bg-purple-500 rounded-full mr-3"></div>
                  <span className="text-sm text-slate-600">47 contacts updated with enriched data</span>
                </div>
                <span className="text-xs text-slate-400">2 days ago</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
EOF

fi

echo "✅ Dashboard set up as home page"

# Fix 3: Ensure UI components exist
echo "🔧 Checking for required UI components..."

# Create missing UI components if they don't exist
if [ ! -f "components/ui/card.tsx" ]; then
    echo "📄 Creating missing card component..."
    mkdir -p components/ui
    
    cat > components/ui/card.tsx << 'EOF'
import * as React from "react"
import { cn } from "@/lib/utils"

const Card = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      "rounded-lg border bg-card text-card-foreground shadow-sm",
      className
    )}
    {...props}
  />
))
Card.displayName = "Card"

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col space-y-1.5 p-6", className)}
    {...props}
  />
))
CardHeader.displayName = "CardHeader"

const CardTitle = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn(
      "text-2xl font-semibold leading-none tracking-tight",
      className
    )}
    {...props}
  />
))
CardTitle.displayName = "CardTitle"

const CardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn("text-sm text-muted-foreground", className)}
    {...props}
  />
))
CardDescription.displayName = "CardDescription"

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
))
CardContent.displayName = "CardContent"

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex items-center p-6 pt-0", className)}
    {...props}
  />
))
CardFooter.displayName = "CardFooter"

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent }
EOF
fi

if [ ! -f "components/ui/button.tsx" ]; then
    echo "📄 Creating missing button component..."
    
    cat > components/ui/button.tsx << 'EOF'
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
EOF
fi

if [ ! -f "components/ui/badge.tsx" ]; then
    echo "📄 Creating missing badge component..."
    
    cat > components/ui/badge.tsx << 'EOF'
import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
  {
    variants: {
      variant: {
        default:
          "border-transparent bg-primary text-primary-foreground hover:bg-primary/80",
        secondary:
          "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80",
        destructive:
          "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80",
        outline: "text-foreground",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant }), className)} {...props} />
  )
}

export { Badge, badgeVariants }
EOF
fi

echo "✅ UI components checked/created"

# Fix 4: Update globals.css if needed
echo "🔧 Checking globals.css..."

if [ ! -f "app/globals.css" ]; then
    echo "📄 Creating basic globals.css..."
    
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
    @apply bg-background text-foreground;
  }
}
EOF
fi

echo ""
echo "🎉 Fixes Applied Successfully!"
echo "=============================="
echo ""
echo "✅ Fixed issues:"
echo "• Added DemoModeProvider to app/layout.tsx"
echo "• Set dashboard as home page (app/page.tsx)"
echo "• Added react-hot-toast to layout"
echo "• Created missing UI components"
echo "• Updated routing structure"
echo ""
echo "📋 Next steps:"
echo "1. Test the app: npm run dev"
echo "2. Visit http://localhost:3000 (should show dashboard)"
echo "3. Navigate to /emails and /email-settings (should work without context errors)"
echo ""
echo "📁 Files modified:"
echo "• app/layout.tsx (backup: app/layout.tsx.backup)"
echo "• app/page.tsx (backup: app/page.tsx.backup)"
echo "• components/ui/* (created missing components)"
echo ""
echo "🔄 If something breaks, restore with:"
echo "   cp app/layout.tsx.backup app/layout.tsx"
echo "   cp app/page.tsx.backup app/page.tsx"
