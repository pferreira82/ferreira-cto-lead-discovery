#!/bin/bash

# Fix Discovery Route - Ensures the discovery page is created properly

echo "🔧 Fixing Discovery Route..."
echo "=========================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from your project root directory."
    exit 1
fi

# 1. Ensure app/discovery directory exists
echo "📁 Creating discovery directory..."
mkdir -p app/discovery

# 2. Create the discovery page with proper imports
echo "📄 Creating discovery page..."
cat > app/discovery/page.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import { 
  Search, 
  Zap, 
  Users, 
  Building, 
  TrendingUp,
  RefreshCw,
  Save,
  Filter,
  Download,
  Target,
  Brain,
  Globe
} from 'lucide-react'

interface SearchParams {
  industries: string[]
  fundingStages: string[]
  excludeExisting: boolean
  aiScoring: boolean
  maxResults: number
}

export default function LeadDiscoveryPage() {
  const [isSearching, setIsSearching] = useState(false)
  const [searchProgress, setSearchProgress] = useState(0)
  const [discoveredLeads, setDiscoveredLeads] = useState([])
  const [searchParams, setSearchParams] = useState<SearchParams>({
    industries: ['Biotechnology', 'Pharmaceuticals'],
    fundingStages: ['Series A', 'Series B', 'Series C'],
    excludeExisting: true,
    aiScoring: true,
    maxResults: 100
  })

  const handleSearch = async () => {
    setIsSearching(true)
    setSearchProgress(0)
    setDiscoveredLeads([])

    // Simulate search process
    const progressInterval = setInterval(() => {
      setSearchProgress(prev => {
        if (prev >= 100) {
          clearInterval(progressInterval)
          setIsSearching(false)
          return 100
        }
        return prev + 10
      })
    }, 500)

    // Mock results for now
    setTimeout(() => {
      setDiscoveredLeads([
        {
          id: '1',
          company: 'BioTech Innovations',
          industry: 'Biotechnology',
          fundingStage: 'Series B',
          location: 'Boston, MA',
          description: 'AI-powered drug discovery platform',
          contacts: 3,
          aiScore: 85,
          urgency: 'high'
        },
        {
          id: '2',
          company: 'GenomeTherapeutics',
          industry: 'Pharmaceuticals',
          fundingStage: 'Series A',
          location: 'San Francisco, CA',
          description: 'Gene therapy solutions for rare diseases',
          contacts: 2,
          aiScore: 78,
          urgency: 'medium'
        }
      ])
    }, 5000)
  }

  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600 dark:text-green-400'
    if (score >= 60) return 'text-yellow-600 dark:text-yellow-400'
    return 'text-red-600 dark:text-red-400'
  }

  const getUrgencyBadge = (urgency: string) => {
    const colors = {
      high: 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400',
      medium: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400',
      low: 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
    }
    return colors[urgency] || colors.medium
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">AI-Powered Lead Discovery</h1>
          <p className="text-gray-600 dark:text-gray-400">Discover and analyze new biotech leads automatically</p>
        </div>
        <div className="flex space-x-3">
          <Button variant="outline" className="flex items-center space-x-2">
            <Download className="w-4 h-4" />
            <span>Export Results</span>
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

      {/* Search Configuration */}
      <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
        <CardHeader>
          <CardTitle className="flex items-center text-gray-900 dark:text-white">
            <Filter className="mr-2 h-5 w-5" />
            Discovery Parameters
          </CardTitle>
          <CardDescription>Configure your lead discovery criteria</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Industries */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Industries</label>
              <div className="space-y-2">
                {['Biotechnology', 'Pharmaceuticals', 'Medical Devices', 'Digital Health'].map(industry => (
                  <div key={industry} className="flex items-center space-x-2">
                    <Checkbox
                      checked={searchParams.industries.includes(industry)}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setSearchParams(prev => ({
                            ...prev,
                            industries: [...prev.industries, industry]
                          }))
                        } else {
                          setSearchParams(prev => ({
                            ...prev,
                            industries: prev.industries.filter(i => i !== industry)
                          }))
                        }
                      }}
                    />
                    <span className="text-sm text-gray-700 dark:text-gray-300">{industry}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Funding Stages */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Funding Stages</label>
              <div className="space-y-2">
                {['Seed', 'Series A', 'Series B', 'Series C', 'Growth'].map(stage => (
                  <div key={stage} className="flex items-center space-x-2">
                    <Checkbox
                      checked={searchParams.fundingStages.includes(stage)}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setSearchParams(prev => ({
                            ...prev,
                            fundingStages: [...prev.fundingStages, stage]
                          }))
                        } else {
                          setSearchParams(prev => ({
                            ...prev,
                            fundingStages: prev.fundingStages.filter(s => s !== stage)
                          }))
                        }
                      }}
                    />
                    <span className="text-sm text-gray-700 dark:text-gray-300">{stage}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Options */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Options</label>
              <div className="space-y-2">
                <div className="flex items-center space-x-2">
                  <Checkbox
                    checked={searchParams.excludeExisting}
                    onCheckedChange={(checked) => 
                      setSearchParams(prev => ({ ...prev, excludeExisting: checked as boolean }))
                    }
                  />
                  <span className="text-sm text-gray-700 dark:text-gray-300">Exclude existing companies</span>
                </div>
                <div className="flex items-center space-x-2">
                  <Checkbox
                    checked={searchParams.aiScoring}
                    onCheckedChange={(checked) => 
                      setSearchParams(prev => ({ ...prev, aiScoring: checked as boolean }))
                    }
                  />
                  <span className="text-sm text-gray-700 dark:text-gray-300">AI relevance scoring</span>
                </div>
              </div>
              <div className="mt-4">
                <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Max Results</label>
                <Input
                  type="number"
                  value={searchParams.maxResults}
                  onChange={(e) => setSearchParams(prev => ({ 
                    ...prev, 
                    maxResults: parseInt(e.target.value) || 100 
                  }))}
                  min="10"
                  max="500"
                />
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Progress */}
      {isSearching && (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardContent className="p-6">
            <div className="flex items-center space-x-4">
              <RefreshCw className="w-5 h-5 animate-spin text-blue-500" />
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900 dark:text-white">Discovering leads...</p>
                <Progress value={searchProgress} className="mt-2" />
                <div className="mt-2 text-xs text-gray-500 dark:text-gray-400">
                  {searchProgress < 30 && "🔍 Searching Apollo API..."}
                  {searchProgress >= 30 && searchProgress < 60 && "💰 Analyzing Crunchbase data..."}
                  {searchProgress >= 60 && searchProgress < 90 && "🤖 AI scoring leads..."}
                  {searchProgress >= 90 && "✅ Finalizing results..."}
                </div>
              </div>
              <span className="text-sm text-gray-500 dark:text-gray-400">{searchProgress}%</span>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Results Summary */}
      {discoveredLeads.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
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
                {discoveredLeads.reduce((sum, lead) => sum + lead.contacts, 0)}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Contacts Found</p>
            </CardContent>
          </Card>

          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Brain className="w-8 h-8 mx-auto mb-2 text-purple-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {discoveredLeads.filter(lead => lead.aiScore >= 70).length}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">High-Quality Leads</p>
            </CardContent>
          </Card>

          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Target className="w-8 h-8 mx-auto mb-2 text-orange-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">0</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Selected to Save</p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Results */}
      {discoveredLeads.length > 0 && (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">Discovered Leads</CardTitle>
            <CardDescription>AI-analyzed biotech companies and contacts</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {discoveredLeads.map((lead) => (
                <div key={lead.id} className="p-4 border border-gray-200 dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-white">{lead.company}</h3>
                        <Badge variant="outline" className="text-gray-700 dark:text-gray-300">
                          {lead.industry}
                        </Badge>
                        <Badge className="bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400">
                          {lead.fundingStage}
                        </Badge>
                      </div>
                      <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">{lead.location}</p>
                      <p className="text-gray-700 dark:text-gray-300 mt-2">{lead.description}</p>
                      <div className="flex items-center space-x-4 mt-3">
                        <span className="text-sm text-gray-600 dark:text-gray-400">
                          {lead.contacts} contact{lead.contacts !== 1 ? 's' : ''}
                        </span>
                        <div className="flex items-center space-x-2">
                          <span className="text-sm text-gray-600 dark:text-gray-400">AI Score:</span>
                          <span className={`font-medium ${getScoreColor(lead.aiScore)}`}>
                            {lead.aiScore}/100
                          </span>
                        </div>
                        <Badge className={getUrgencyBadge(lead.urgency)}>
                          {lead.urgency} urgency
                        </Badge>
                      </div>
                    </div>
                    <div className="flex space-x-2">
                      <Button variant="outline" size="sm">
                        View Details
                      </Button>
                      <Button size="sm" className="bg-green-600 hover:bg-green-700">
                        <Save className="w-4 h-4 mr-2" />
                        Save Lead
                      </Button>
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
              Configure your search parameters and start discovering high-quality biotech leads
            </p>
            <Button onClick={handleSearch} className="bg-gradient-to-r from-blue-500 to-purple-600">
              <Search className="w-4 h-4 mr-2" />
              Start Your First Discovery
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
EOF

# 3. Create a simple API endpoint for testing
echo "🔌 Creating basic API endpoint..."
mkdir -p pages/api/discovery
cat > pages/api/discovery/test.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  res.status(200).json({
    success: true,
    message: 'Discovery API is working!',
    timestamp: new Date().toISOString()
  })
}
EOF

# 4. Update next.config.js to ensure proper routing
echo "⚙️ Updating Next.js config..."
cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: ['images.crunchbase.com', 'logo.clearbit.com'],
  },
  env: {
    COMPANY_NAME: process.env.COMPANY_NAME,
    COMPANY_EMAIL: process.env.COMPANY_EMAIL,
  },
  // Ensure app directory routing works properly
  experimental: {
    appDir: true,
  },
}

module.exports = nextConfig
EOF

# 5. Clear Next.js cache to ensure new routes are recognized
echo "🧹 Clearing Next.js cache..."
rm -rf .next

echo ""
echo "✅ Discovery Route Fixed!"
echo ""
echo "🔧 What was done:"
echo "  - Created app/discovery/page.tsx"
echo "  - Added proper imports and components"
echo "  - Created test API endpoint"
echo "  - Updated Next.js configuration"
echo "  - Cleared cache to recognize new routes"
echo ""
echo "🚀 Next steps:"
echo "  1. npm run dev"
echo "  2. Visit http://localhost:3000/discovery"
echo "  3. Test the lead discovery interface"
echo ""
echo "The discovery page should now load properly!"
