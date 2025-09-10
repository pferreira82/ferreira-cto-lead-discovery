#!/bin/bash

echo "🔧 Fixing Demo Mode Logic and Adding Companies API"
echo "================================================="

# Create backup
backup_dir="demo-mode-fix-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Create missing /api/companies route
echo "📁 Creating /api/companies/route.ts..."
mkdir -p app/api/companies

cat > app/api/companies/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

const DEMO_COMPANIES = [
  {
    id: 'demo-comp-1',
    name: 'BioTech Innovations Inc.',
    website: 'https://biotechinnovations.com',
    industry: 'Biotechnology',
    funding_stage: 'Series B',
    location: 'Boston, MA, USA',
    description: 'AI-powered drug discovery platform leveraging machine learning to accelerate pharmaceutical development.',
    total_funding: 45000000,
    last_funding_date: '2024-06-15',
    employee_count: 125,
    crunchbase_url: 'https://crunchbase.com/organization/biotech-innovations',
    linkedin_url: 'https://linkedin.com/company/biotech-innovations',
    created_at: '2024-01-15T10:00:00Z',
    updated_at: '2024-09-07T15:30:00Z'
  },
  {
    id: 'demo-comp-2',
    name: 'GenomeTherapeutics',
    website: 'https://genometherapeutics.com',
    industry: 'Gene Therapy',
    funding_stage: 'Series A',
    location: 'San Francisco, CA, USA',
    description: 'Revolutionary gene therapy platform developing treatments for rare genetic diseases using CRISPR.',
    total_funding: 28000000,
    last_funding_date: '2024-03-20',
    employee_count: 67,
    created_at: '2024-02-20T14:00:00Z',
    updated_at: '2024-09-07T15:30:00Z'
  },
  {
    id: 'demo-comp-3',
    name: 'NeuralBio Systems',
    website: 'https://neuralbio.com',
    industry: 'Neurotechnology',
    funding_stage: 'Series C',
    location: 'Cambridge, MA, USA',
    description: 'Brain-computer interface technology for treating neurological disorders.',
    total_funding: 125000000,
    last_funding_date: '2024-01-10',
    employee_count: 245,
    created_at: '2024-03-10T09:00:00Z',
    updated_at: '2024-09-07T15:30:00Z'
  }
]

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('📊 Returning demo companies data')
      return NextResponse.json({
        success: true,
        companies: DEMO_COMPANIES,
        count: DEMO_COMPANIES.length,
        source: 'demo'
      })
    }

    // In production mode, try to fetch real data
    // For now, return empty since no real database is configured
    console.log('🔍 Production mode: No real database configured')
    
    return NextResponse.json({
      success: true,
      companies: [],
      count: 0,
      source: 'production',
      message: 'No companies found. Configure your database connection to see real data.'
    })

  } catch (error) {
    console.error('Companies API Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch companies',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
EOF

# Update analytics dashboard to respect demo mode
echo "🔧 Updating analytics dashboard to respect demo mode..."
cat > app/api/analytics/dashboard/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('📊 Returning demo dashboard data')
      
      const stats = {
        totalContacts: 1247,
        totalCompanies: 186,
        emailsSent: 892,
        responseRate: 23.5,
        contactedThisWeek: 47,
        notContactedCount: 723,
        pipeline_value: 2400000,
        active_campaigns: 5
      }

      const charts = {
        emailActivity: [
          { date: 'Sep 1', sent: 45, opened: 25, replied: 6 },
          { date: 'Sep 2', sent: 52, opened: 30, replied: 8 },
          { date: 'Sep 3', sent: 48, opened: 22, replied: 5 },
          { date: 'Sep 4', sent: 61, opened: 35, replied: 12 },
          { date: 'Sep 5', sent: 55, opened: 28, replied: 9 },
          { date: 'Sep 6', sent: 47, opened: 20, replied: 4 },
          { date: 'Sep 7', sent: 38, opened: 15, replied: 3 },
        ],
        contactsByRole: [
          { role: 'Founder', count: 45, color: '#3B82F6' },
          { role: 'Executive', count: 67, color: '#8B5CF6' },
          { role: 'VC', count: 23, color: '#10B981' },
          { role: 'Board Member', count: 18, color: '#F59E0B' },
        ],
        companiesByStage: [
          { stage: 'Series A', count: 75 },
          { stage: 'Series B', count: 64 },
          { stage: 'Series C', count: 47 },
        ]
      }

      return NextResponse.json({ 
        success: true,
        stats, 
        charts,
        source: 'demo'
      })
    }

    // Production mode - try to fetch real data
    console.log('🔍 Production mode: fetching real dashboard data')
    
    // Return minimal stats since no real database is configured
    const stats = {
      totalContacts: 0,
      totalCompanies: 0,
      emailsSent: 0,
      responseRate: 0,
      contactedThisWeek: 0,
      notContactedCount: 0,
      pipeline_value: 0,
      active_campaigns: 0
    }

    const charts = {
      emailActivity: [],
      contactsByRole: [],
      companiesByStage: []
    }

    return NextResponse.json({ 
      success: true,
      stats, 
      charts,
      source: 'production',
      message: 'Configure your database to see real analytics data'
    })

  } catch (error) {
    console.error('Dashboard API Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch dashboard data',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
EOF

# Update contacts API to respect demo mode
echo "🔧 Updating contacts API to respect demo mode..."
cat > app/api/contacts/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

const DEMO_CONTACTS = [
  {
    id: 'demo-contact-1',
    company_id: 'demo-comp-1',
    first_name: 'Sarah',
    last_name: 'Chen',
    email: 'sarah.chen@biotechinnovations.com',
    title: 'CEO & Co-Founder',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/sarahchen-biotech',
    contact_status: 'not_contacted',
    created_at: '2024-01-15T10:30:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-2',
    company_id: 'demo-comp-1',
    first_name: 'Michael',
    last_name: 'Rodriguez',
    email: 'm.rodriguez@biotechinnovations.com',
    title: 'Chief Technology Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/mrodriguez-cto',
    contact_status: 'contacted',
    last_contacted_at: '2024-09-05T10:30:00Z',
    created_at: '2024-01-15T11:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-3',
    company_id: 'demo-comp-2',
    first_name: 'James',
    last_name: 'Liu',
    email: 'james.liu@genometherapeutics.com',
    title: 'CEO',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/jamesliu-genomics',
    contact_status: 'responded',
    last_contacted_at: '2024-09-04T14:22:00Z',
    created_at: '2024-02-20T14:30:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  }
]

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('📊 Returning demo contacts data')
      return NextResponse.json({
        success: true,
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo'
      })
    }

    // Production mode - try to fetch real data
    console.log('🔍 Production mode: No real database configured')
    
    return NextResponse.json({
      success: true,
      contacts: [],
      count: 0,
      source: 'production',
      message: 'No contacts found. Configure your database connection to see real data.'
    })

  } catch (error) {
    console.error('Contacts API Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch contacts',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
EOF

# Create a hook to properly handle demo mode API calls
echo "🔧 Creating demo-aware API hook..."
mkdir -p lib/hooks

cat > lib/hooks/use-demo-api.ts << 'EOF'
'use client'

import { useDemoMode } from '@/lib/demo-context'
import { useCallback } from 'react'

export function useDemoAPI() {
  const { isDemoMode } = useDemoMode()

  const fetchWithDemo = useCallback(async (url: string, options?: RequestInit) => {
    // Add demo parameter to URL if in demo mode
    const urlWithDemo = new URL(url, window.location.origin)
    if (isDemoMode) {
      urlWithDemo.searchParams.set('demo', 'true')
    }

    console.log(`🔗 API Call: ${urlWithDemo.toString()} (demo: ${isDemoMode})`)

    return fetch(urlWithDemo.toString(), options)
  }, [isDemoMode])

  return { fetchWithDemo, isDemoMode }
}
EOF

# Update dashboard page to use demo-aware API calls
echo "🔧 Updating dashboard page to respect demo mode..."
[ -f "app/page.tsx" ] && cp "app/page.tsx" "$backup_dir/page.tsx.backup"

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
  ArrowUpRight,
  AlertCircle
} from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'
import Link from 'next/link'

export default function DashboardPage() {
  const { isDemoMode } = useDemoMode()
  const { fetchWithDemo } = useDemoAPI()
  const [stats, setStats] = useState({
    totalContacts: 0,
    totalCompanies: 0,
    emailsSent: 0,
    responseRate: 0
  })
  const [loading, setLoading] = useState(true)
  const [dataSource, setDataSource] = useState<'demo' | 'production' | 'error'>('production')

  useEffect(() => {
    const loadStats = async () => {
      try {
        setLoading(true)
        const response = await fetchWithDemo('/api/analytics/dashboard')
        
        if (response.ok) {
          const data = await response.json()
          setStats({
            totalContacts: data.stats?.totalContacts || 0,
            totalCompanies: data.stats?.totalCompanies || 0,
            emailsSent: data.stats?.emailsSent || 0,
            responseRate: data.stats?.responseRate || 0
          })
          setDataSource(data.source || 'production')
        } else {
          console.warn('Failed to load dashboard stats')
          setDataSource('error')
        }
      } catch (error) {
        console.error('Failed to load dashboard stats:', error)
        setDataSource('error')
      } finally {
        setLoading(false)
      }
    }

    loadStats()
  }, [isDemoMode, fetchWithDemo]) // Reload when demo mode changes

  const getDataSourceBadge = () => {
    if (loading) return null
    
    switch (dataSource) {
      case 'demo':
        return (
          <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-900/20 dark:text-blue-400 dark:border-blue-800">
            Demo Data
          </Badge>
        )
      case 'production':
        return (
          <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200 dark:bg-green-900/20 dark:text-green-400 dark:border-green-800">
            Production Data
          </Badge>
        )
      case 'error':
        return (
          <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200 dark:bg-red-900/20 dark:text-red-400 dark:border-red-800">
            <AlertCircle className="w-3 h-3 mr-1" />
            Data Error
          </Badge>
        )
      default:
        return null
    }
  }

  return (
    <div className="p-6">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Dashboard</h1>
            <p className="text-muted-foreground mt-1">Welcome to your biotech lead generation system</p>
          </div>
          <div className="flex items-center space-x-2">
            {getDataSourceBadge()}
            {isDemoMode && (
              <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200 dark:bg-yellow-900/20 dark:text-yellow-400 dark:border-yellow-800">
                Demo Mode Active
              </Badge>
            )}
          </div>
        </div>
      </div>

      {/* No Data Warning for Production Mode */}
      {!isDemoMode && dataSource === 'production' && stats.totalContacts === 0 && (
        <Card className="mb-6 border-orange-200 bg-orange-50 dark:border-orange-800 dark:bg-orange-900/20">
          <CardContent className="p-4">
            <div className="flex items-center">
              <AlertCircle className="h-5 w-5 text-orange-600 mr-3" />
              <div>
                <p className="text-sm text-orange-800 dark:text-orange-200">
                  <strong>No data available.</strong> You're in production mode but no database is configured. 
                  Enable demo mode to see sample data, or configure your database connection.
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground mb-1">Total Contacts</p>
                <p className="text-3xl font-bold text-foreground">
                  {loading ? "..." : stats.totalContacts.toLocaleString()}
                </p>
                {isDemoMode && stats.totalContacts > 0 && (
                  <p className="text-xs text-green-600 mt-1">+12% from last month</p>
                )}
              </div>
              <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900/20 rounded-lg flex items-center justify-center">
                <Users className="h-6 w-6 text-blue-600 dark:text-blue-400" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground mb-1">Companies</p>
                <p className="text-3xl font-bold text-foreground">
                  {loading ? "..." : stats.totalCompanies}
                </p>
                {isDemoMode && stats.totalCompanies > 0 && (
                  <p className="text-xs text-green-600 mt-1">+8% from last month</p>
                )}
              </div>
              <div className="w-12 h-12 bg-green-100 dark:bg-green-900/20 rounded-lg flex items-center justify-center">
                <Building className="h-6 w-6 text-green-600 dark:text-green-400" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground mb-1">Emails Sent</p>
                <p className="text-3xl font-bold text-foreground">
                  {loading ? "..." : stats.emailsSent}
                </p>
                {isDemoMode && stats.emailsSent > 0 && (
                  <p className="text-xs text-green-600 mt-1">+23% from last month</p>
                )}
              </div>
              <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900/20 rounded-lg flex items-center justify-center">
                <Mail className="h-6 w-6 text-purple-600 dark:text-purple-400" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground mb-1">Response Rate</p>
                <p className="text-3xl font-bold text-foreground">
                  {loading ? "..." : `${stats.responseRate}%`}
                </p>
                {isDemoMode && stats.responseRate > 0 && (
                  <p className="text-xs text-green-600 mt-1">+2.1% from last month</p>
                )}
              </div>
              <div className="w-12 h-12 bg-orange-100 dark:bg-orange-900/20 rounded-lg flex items-center justify-center">
                <TrendingUp className="h-6 w-6 text-orange-600 dark:text-orange-400" />
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

      {/* Recent Activity - only show in demo mode */}
      {isDemoMode && (
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
                <div className="flex items-center justify-between py-2 border-b border-border">
                  <div className="flex items-center">
                    <div className="w-2 h-2 bg-green-500 rounded-full mr-3"></div>
                    <span className="text-sm text-muted-foreground">Email campaign "Q4 Biotech CTO Outreach" completed</span>
                  </div>
                  <span className="text-xs text-muted-foreground">2h ago</span>
                </div>
                <div className="flex items-center justify-between py-2 border-b border-border">
                  <div className="flex items-center">
                    <div className="w-2 h-2 bg-blue-500 rounded-full mr-3"></div>
                    <span className="text-sm text-muted-foreground">25 new biotech companies discovered</span>
                  </div>
                  <span className="text-xs text-muted-foreground">1d ago</span>
                </div>
                <div className="flex items-center justify-between py-2">
                  <div className="flex items-center">
                    <div className="w-2 h-2 bg-purple-500 rounded-full mr-3"></div>
                    <span className="text-sm text-muted-foreground">47 contacts updated with enriched data</span>
                  </div>
                  <span className="text-xs text-muted-foreground">2d ago</span>
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
                  <span className="text-sm text-muted-foreground">Email Open Rate</span>
                  <span className="text-sm font-medium">42.3%</span>
                </div>
                <div className="w-full bg-muted rounded-full h-2">
                  <div className="bg-blue-500 h-2 rounded-full" style={{ width: '42.3%' }}></div>
                </div>
                
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Click-through Rate</span>
                  <span className="text-sm font-medium">8.7%</span>
                </div>
                <div className="w-full bg-muted rounded-full h-2">
                  <div className="bg-green-500 h-2 rounded-full" style={{ width: '8.7%' }}></div>
                </div>
                
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Response Rate</span>
                  <span className="text-sm font-medium">{stats.responseRate}%</span>
                </div>
                <div className="w-full bg-muted rounded-full h-2">
                  <div className="bg-purple-500 h-2 rounded-full" style={{ width: `${stats.responseRate}%` }}></div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  )
}
EOF

echo ""
echo "✅ Demo Mode Logic and Companies API Fixed!"
echo "=========================================="
echo ""
echo "Changes made:"
echo "• Created /api/companies route with demo mode support"
echo "• Updated all API routes to respect demo mode setting"
echo "• Created useDemoAPI hook for consistent API calls"
echo "• Updated dashboard to show data source badges"
echo "• Added production mode warnings when no data available"
echo "• Demo data now only shows when demo mode is ON"
echo ""
echo "📦 Backup saved to: $backup_dir"
echo ""
echo "🚀 Restart your dev server:"
echo "   npm run dev"
echo ""
echo "🧪 Test the demo mode toggle:"
echo "   • Turn demo mode OFF - should show empty data or warnings"
echo "   • Turn demo mode ON - should show sample data"
echo "   • /api/companies should now work (no more 404s)"
