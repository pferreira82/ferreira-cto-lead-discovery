#!/bin/bash

echo "🔧 Quick Debug Fix for Dashboard Production Data..."
echo "================================================"

# 1. First, let's add debug info directly to your main dashboard
echo "📊 Adding debug info to main dashboard..."
cat > app/page.tsx << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { useDemoMode } from '@/lib/demo-context'
import { toast } from 'react-hot-toast'
import { 
  Users, 
  Building, 
  Mail, 
  TrendingUp, 
  Target,
  Activity,
  RefreshCw,
  Search,
  Send,
  Database,
  Play,
  Settings,
  AlertCircle,
  CheckCircle,
  XCircle
} from 'lucide-react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, BarChart, Bar } from 'recharts'

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

interface ChartData {
  emailActivity: Array<{ date: string; sent: number; opened: number; replied: number }>
  contactsByRole: Array<{ role: string; count: number; color: string }>
  companiesByStage: Array<{ stage: string; count: number }>
}

// Demo data - always available for demo mode
const DEMO_STATS: DashboardStats = {
  totalContacts: 1247,
  totalCompanies: 186,
  emailsSent: 892,
  responseRate: 23.5,
  contactedThisWeek: 47,
  notContactedCount: 723,
  pipeline_value: 2400000,
  active_campaigns: 5
}

const DEMO_CHARTS: ChartData = {
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
    { role: 'Founder', count: 45, color: '#8884d8' },
    { role: 'Executive', count: 67, color: '#82ca9d' },
    { role: 'VC', count: 23, color: '#ffc658' },
    { role: 'Board Member', count: 18, color: '#ff7300' },
  ],
  companiesByStage: [
    { stage: 'Series A', count: 75 },
    { stage: 'Series B', count: 64 },
    { stage: 'Series C', count: 47 },
  ]
}

export default function Dashboard() {
  const { isDemoMode, isLoaded } = useDemoMode()
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [chartData, setChartData] = useState<ChartData | null>(null)
  const [loading, setLoading] = useState(true)
  const [refreshing, setRefreshing] = useState(false)
  const [debugInfo, setDebugInfo] = useState<any>(null)
  const [showDebug, setShowDebug] = useState(false)

  useEffect(() => {
    if (isLoaded) {
      fetchDashboardData()
    }
  }, [isDemoMode, isLoaded])

  const fetchDashboardData = async () => {
    try {
      setLoading(true)
      
      if (isDemoMode) {
        // Demo mode - use mock data
        await new Promise(resolve => setTimeout(resolve, 500))
        setStats(DEMO_STATS)
        setChartData(DEMO_CHARTS)
        setDebugInfo({
          mode: 'demo',
          source: 'hardcoded_data',
          timestamp: new Date().toISOString()
        })
        toast.success('Demo data loaded')
      } else {
        // Production mode - fetch from API
        console.log('🔄 Fetching production data...')
        const response = await fetch('/api/analytics/dashboard')
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }
        
        const data = await response.json()
        console.log('📊 API Response:', data)
        
        setStats(data.stats)
        setChartData(data.charts)
        setDebugInfo({
          mode: 'production',
          source: data.debug?.reason || 'unknown',
          apiStatus: response.status,
          hasData: !!data.stats,
          timestamp: new Date().toISOString(),
          rawDebug: data.debug
        })
        
        if (data.debug?.reason === 'production_data') {
          toast.success('Production data loaded successfully!')
        } else {
          toast.error(`Production mode but using fallback data: ${data.debug?.reason || 'unknown'}`)
        }
      }
    } catch (error) {
      console.error('❌ Failed to fetch dashboard data:', error)
      
      // Always fall back to demo data on error
      setStats(DEMO_STATS)
      setChartData(DEMO_CHARTS)
      setDebugInfo({
        mode: isDemoMode ? 'demo' : 'production',
        source: 'error_fallback',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      })
      
      toast.error(`Failed to load ${isDemoMode ? 'demo' : 'production'} data: ${error instanceof Error ? error.message : 'Unknown error'}`)
    } finally {
      setLoading(false)
    }
  }

  const testSupabaseConnection = async () => {
    try {
      const response = await fetch('/api/test/supabase')
      const result = await response.json()
      
      if (response.ok) {
        toast.success('Supabase connection test passed!')
        console.log('✅ Supabase test result:', result)
      } else {
        toast.error(`Supabase test failed: ${result.error || 'Unknown error'}`)
        console.error('❌ Supabase test failed:', result)
      }
    } catch (error) {
      toast.error('Failed to test Supabase connection')
      console.error('❌ Supabase test error:', error)
    }
  }

  const handleRefreshData = async () => {
    setRefreshing(true)
    try {
      if (isDemoMode) {
        await new Promise(resolve => setTimeout(resolve, 1000))
        toast.success('Demo data refreshed')
      } else {
        const response = await fetch('/api/integrations/refresh-data', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' }
        })
        
        if (response.ok) {
          await fetchDashboardData()
          toast.success('Production data refreshed from Apollo/Crunchbase')
        } else {
          const error = await response.json()
          throw new Error(error.message || 'Refresh failed')
        }
      }
    } catch (error) {
      console.error('Failed to refresh data:', error)
      toast.error(`Failed to refresh ${isDemoMode ? 'demo' : 'production'} data`)
    } finally {
      setRefreshing(false)
    }
  }

  // Show loading while context loads
  if (!isLoaded) {
    return (
      <div className="space-y-6">
        <div className="bg-gradient-to-r from-blue-600 to-purple-700 rounded-2xl p-8 text-white">
          <h1 className="text-2xl font-bold mb-2">Loading Dashboard...</h1>
          <p className="text-blue-100">Initializing system...</p>
        </div>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="bg-gradient-to-r from-blue-600 to-purple-700 rounded-2xl p-8 text-white">
          <h1 className="text-2xl font-bold mb-2">Loading Dashboard...</h1>
          <p className="text-blue-100">
            Fetching {isDemoMode ? 'demo' : 'production'} data...
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Debug Panel */}
      <Card className="border-orange-200 bg-orange-50 dark:bg-orange-900/20">
        <CardContent className="p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <AlertCircle className="w-5 h-5 text-orange-600" />
              <div>
                <p className="font-medium text-orange-800 dark:text-orange-400">
                  Debug Info: {debugInfo?.source || 'unknown'}
                </p>
                <p className="text-sm text-orange-600 dark:text-orange-300">
                  Mode: {isDemoMode ? 'Demo' : 'Production'} | 
                  Source: {debugInfo?.source} | 
                  Time: {debugInfo?.timestamp ? new Date(debugInfo.timestamp).toLocaleTimeString() : 'N/A'}
                </p>
              </div>
            </div>
            <div className="flex space-x-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowDebug(!showDebug)}
              >
                {showDebug ? 'Hide' : 'Show'} Debug
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={testSupabaseConnection}
              >
                Test Supabase
              </Button>
            </div>
          </div>
          
          {showDebug && debugInfo && (
            <div className="mt-4 p-3 bg-white dark:bg-gray-800 rounded border">
              <pre className="text-xs overflow-auto">
                {JSON.stringify(debugInfo, null, 2)}
              </pre>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Mode Info Banner */}
      <Card className={`border-0 shadow-sm ${isDemoMode ? 'bg-blue-50 dark:bg-blue-900/20' : 'bg-green-50 dark:bg-green-900/20'}`}>
        <CardContent className="p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              {isDemoMode ? (
                <Play className="w-5 h-5 text-blue-600 dark:text-blue-400" />
              ) : (
                <Database className="w-5 h-5 text-green-600 dark:text-green-400" />
              )}
              <div>
                <p className={`font-medium ${isDemoMode ? 'text-blue-800 dark:text-blue-300' : 'text-green-800 dark:text-green-300'}`}>
                  {isDemoMode ? 'Demo Data Active' : 'Production Mode Active'}
                </p>
                <p className={`text-sm ${isDemoMode ? 'text-blue-600 dark:text-blue-400' : 'text-green-600 dark:text-green-400'}`}>
                  {isDemoMode 
                    ? 'Showing sample data for testing and exploration'
                    : debugInfo?.source === 'production_data' 
                      ? 'Live data from Supabase database'
                      : `Using fallback data (${debugInfo?.source || 'unknown reason'})`
                  }
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-2">
              {debugInfo?.source === 'production_data' ? (
                <CheckCircle className="w-5 h-5 text-green-500" />
              ) : debugInfo?.source === 'error_fallback' ? (
                <XCircle className="w-5 h-5 text-red-500" />
              ) : (
                <AlertCircle className="w-5 h-5 text-yellow-500" />
              )}
              <Badge className={
                isDemoMode ? 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400' : 
                debugInfo?.source === 'production_data' ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400' :
                'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'
              }>
                {isDemoMode ? 'Demo Mode' : debugInfo?.source === 'production_data' ? 'Production Data' : 'Fallback Data'}
              </Badge>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-700 rounded-2xl p-8 text-white">
        <h1 className="text-2xl font-bold mb-2">Welcome back, Peter</h1>
        <p className="text-blue-100">
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
          {!isDemoMode && (
            <Badge className="bg-white/20 text-white border-white/30">
              ${((stats?.pipeline_value || 0) / 1000000).toFixed(1)}M Pipeline
            </Badge>
          )}
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="border-0 shadow-lg bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-blue-600 dark:text-blue-400">Total Contacts</p>
                <p className="text-3xl font-bold text-blue-900 dark:text-blue-100">{stats?.totalContacts.toLocaleString()}</p>
                <p className="text-xs text-blue-600 dark:text-blue-400 mt-1">
                  {stats?.notContactedCount} not contacted
                </p>
              </div>
              <div className="w-12 h-12 bg-blue-500 rounded-xl flex items-center justify-center">
                <Users className="w-6 h-6 text-white" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg bg-gradient-to-br from-purple-50 to-purple-100 dark:from-purple-900/20 dark:to-purple-800/20">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-purple-600 dark:text-purple-400">Companies</p>
                <p className="text-3xl font-bold text-purple-900 dark:text-purple-100">{stats?.totalCompanies}</p>
                <p className="text-xs text-purple-600 dark:text-purple-400 mt-1">Biotech Series A-C</p>
              </div>
              <div className="w-12 h-12 bg-purple-500 rounded-xl flex items-center justify-center">
                <Building className="w-6 h-6 text-white" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-green-600 dark:text-green-400">Emails Sent</p>
                <p className="text-3xl font-bold text-green-900 dark:text-green-100">{stats?.emailsSent}</p>
                <p className="text-xs text-green-600 dark:text-green-400 mt-1">
                  {stats?.contactedThisWeek} this week
                </p>
              </div>
              <div className="w-12 h-12 bg-green-500 rounded-xl flex items-center justify-center">
                <Mail className="w-6 h-6 text-white" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg bg-gradient-to-br from-orange-50 to-orange-100 dark:from-orange-900/20 dark:to-orange-800/20">
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-orange-600 dark:text-orange-400">Response Rate</p>
                <p className="text-3xl font-bold text-orange-900 dark:text-orange-100">{stats?.responseRate}%</p>
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
        <Card className="border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">Lead Generation Activity</CardTitle>
            <CardDescription>Daily performance over the last 7 days</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={chartData?.emailActivity || []}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="date" stroke="#64748b" />
                <YAxis stroke="#64748b" />
                <Tooltip />
                <Line type="monotone" dataKey="sent" stroke="#3B82F6" strokeWidth={3} name="Sent" />
                <Line type="monotone" dataKey="opened" stroke="#8B5CF6" strokeWidth={3} name="Opened" />
                <Line type="monotone" dataKey="replied" stroke="#10B981" strokeWidth={3} name="Replied" />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">Companies by Funding Stage</CardTitle>
            <CardDescription>Distribution of biotech companies in pipeline</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={chartData?.companiesByStage || []}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="stage" stroke="#64748b" />
                <YAxis stroke="#64748b" />
                <Tooltip />
                <Bar dataKey="count" fill="#3B82F6" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <Card className="border-0 shadow-lg">
        <CardHeader>
          <CardTitle className="text-gray-900 dark:text-white">Quick Actions</CardTitle>
          <CardDescription>Common tasks and workflows</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <Button 
              onClick={() => window.location.href = '/discovery'}
              className="h-20 flex-col space-y-2 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700"
            >
              <Target className="w-6 h-6" />
              <span>Discover New Leads</span>
            </Button>
            
            <Button 
              onClick={handleRefreshData}
              disabled={refreshing}
              className="h-20 flex-col space-y-2 bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700"
            >
              <RefreshCw className={`w-6 h-6 ${refreshing ? 'animate-spin' : ''}`} />
              <span>{refreshing ? 'Refreshing...' : 'Refresh Data'}</span>
            </Button>
            
            <Button className="h-20 flex-col space-y-2 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700">
              <Send className="w-6 h-6" />
              <span>Send Campaign</span>
            </Button>
            
            <Button className="h-20 flex-col space-y-2 bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700">
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

# 2. Quick environment check
echo "🔍 Creating simple environment check..."
cat > check-env-simple.js << 'EOF'
const fs = require('fs')
const path = require('path')

console.log('\n🔍 Quick Environment Check')
console.log('========================')

const envPath = path.join(process.cwd(), '.env.local')
const envExists = fs.existsSync(envPath)

console.log('📁 .env.local file:', envExists ? '✅ EXISTS' : '❌ MISSING')

if (envExists) {
  const envContent = fs.readFileSync(envPath, 'utf8')
  const requiredVars = [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY', 
    'SUPABASE_SERVICE_ROLE_KEY'
  ]
  
  console.log('\n🔑 Required Variables:')
  requiredVars.forEach(varName => {
    const hasVar = envContent.includes(varName + '=')
    console.log(`   ${hasVar ? '✅' : '❌'} ${varName}`)
  })
} else {
  console.log('\n❌ Please create .env.local with your Supabase credentials')
}

console.log('\n🚀 Next steps:')
console.log('   1. Create/check .env.local file')
console.log('   2. Restart: npm run dev')
console.log('   3. Check the orange debug panel on dashboard')
console.log('   4. Click "Test Supabase" button')
EOF

echo ""
echo "✅ Simple Debug Fix Applied!"
echo ""
echo "🔧 What I Changed:"
echo "   - Added debug panel directly to main dashboard (orange banner)"
echo "   - Shows data source and connection status"
echo "   - Added 'Test Supabase' button for quick testing"
echo "   - More detailed error handling and logging"
echo ""
echo "🎯 Immediate Actions:"
echo "   1. Run: node check-env-simple.js"
echo "   2. Restart your dev server: npm run dev"
echo "   3. Look for the orange debug panel on your dashboard"
echo "   4. Click 'Test Supabase' button to test connection"
echo ""
echo "🔍 What the Debug Panel Shows:"
echo "   - Current mode (Demo/Production)"
echo "   - Data source (production_data/error_fallback/missing_credentials)"
echo "   - Connection status and error details"
echo "   - Raw debug information when expanded"
echo ""
echo "The debug info is now built into your main dashboard - no separate routes needed!"
