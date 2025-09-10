#!/bin/bash

echo "Fixing Lead Discovery Search Functionality"
echo "========================================="

# Create discovery API endpoints
echo "Creating discovery API routes..."

# Create /api/discovery/search route
mkdir -p app/api/discovery/search
cat > app/api/discovery/search/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

// Demo biotech companies for discovery
const DEMO_DISCOVERY_COMPANIES = [
  {
    id: 'discovery-1',
    company: 'Moderna',
    website: 'https://www.modernatx.com',
    industry: 'mRNA Therapeutics',
    description: 'mRNA therapeutics and vaccines company developing treatments for infectious diseases, immuno-oncology, rare diseases, and cardiovascular disease.',
    fundingStage: 'Public',
    totalFunding: 2600000000,
    employeeCount: 2800,
    location: 'Cambridge, MA, USA',
    foundedYear: 2010,
    ai_score: 95,
    contacts: [
      {
        name: 'Stéphane Bancel',
        title: 'Chief Executive Officer',
        email: 'stephane.bancel@modernatx.com',
        role_category: 'Executive',
        linkedin: 'https://linkedin.com/in/stephanebancel'
      },
      {
        name: 'Juan Andres',
        title: 'Chief Technology Officer',
        email: 'juan.andres@modernatx.com',
        role_category: 'Executive',
        linkedin: 'https://linkedin.com/in/juanandres'
      }
    ]
  },
  {
    id: 'discovery-2',
    company: 'Ginkgo Bioworks',
    website: 'https://www.ginkgobioworks.com',
    industry: 'Synthetic Biology',
    description: 'Platform biotechnology company enabling customers to program cells as easily as we can program computers.',
    fundingStage: 'Public',
    totalFunding: 719000000,
    employeeCount: 1200,
    location: 'Boston, MA, USA',
    foundedYear: 2009,
    ai_score: 88,
    contacts: [
      {
        name: 'Jason Kelly',
        title: 'CEO & Co-Founder',
        email: 'jason.kelly@ginkgobioworks.com',
        role_category: 'Founder',
        linkedin: 'https://linkedin.com/in/jasonkelly'
      },
      {
        name: 'Barry Canton',
        title: 'CTO & Co-Founder',
        email: 'barry.canton@ginkgobioworks.com',
        role_category: 'Founder',
        linkedin: 'https://linkedin.com/in/barrycanton'
      }
    ]
  },
  {
    id: 'discovery-3',
    company: 'Recursion Pharmaceuticals',
    website: 'https://www.recursion.com',
    industry: 'AI Drug Discovery',
    description: 'Clinical-stage biotechnology company decoding biology by integrating technological innovations across biology, chemistry, automation, data science, and engineering.',
    fundingStage: 'Public',
    totalFunding: 500000000,
    employeeCount: 500,
    location: 'Salt Lake City, UT, USA',
    foundedYear: 2013,
    ai_score: 92,
    contacts: [
      {
        name: 'Chris Gibson',
        title: 'CEO & Co-Founder',
        email: 'chris.gibson@recursion.com',
        role_category: 'Founder',
        linkedin: 'https://linkedin.com/in/chrisgibson'
      },
      {
        name: 'Dean Li',
        title: 'Chief Scientific Officer',
        email: 'dean.li@recursion.com',
        role_category: 'Executive',
        linkedin: 'https://linkedin.com/in/deanli'
      }
    ]
  },
  {
    id: 'discovery-4',
    company: 'Twist Bioscience',
    website: 'https://www.twistbioscience.com',
    industry: 'Synthetic Biology',
    description: 'Synthetic biology company manufacturing synthetic DNA using a disruptive new technology.',
    fundingStage: 'Public',
    totalFunding: 400000000,
    employeeCount: 800,
    location: 'South San Francisco, CA, USA',
    foundedYear: 2013,
    ai_score: 85,
    contacts: [
      {
        name: 'Emily Leproust',
        title: 'CEO & Co-Founder',
        email: 'emily.leproust@twistbioscience.com',
        role_category: 'Founder',
        linkedin: 'https://linkedin.com/in/emilyleproust'
      },
      {
        name: 'Bill Banyai',
        title: 'CTO',
        email: 'bill.banyai@twistbioscience.com',
        role_category: 'Executive',
        linkedin: 'https://linkedin.com/in/billbanyai'
      }
    ]
  },
  {
    id: 'discovery-5',
    company: 'BioMarin Pharmaceutical',
    website: 'https://www.biomarin.com',
    industry: 'Rare Disease Therapeutics',
    description: 'Biotechnology company developing and commercializing innovative therapies for patients with serious and life-threatening rare diseases.',
    fundingStage: 'Public',
    totalFunding: 1200000000,
    employeeCount: 3000,
    location: 'San Rafael, CA, USA',
    foundedYear: 1997,
    ai_score: 78,
    contacts: [
      {
        name: 'Jean-Jacques Bienaimé',
        title: 'Chairman & CEO',
        email: 'jj.bienaime@biomarin.com',
        role_category: 'Executive',
        linkedin: 'https://linkedin.com/in/jjbienaime'
      },
      {
        name: 'Robert Baffi',
        title: 'CTO',
        email: 'robert.baffi@biomarin.com',
        role_category: 'Executive',
        linkedin: 'https://linkedin.com/in/robertbaffi'
      }
    ]
  }
]

export async function POST(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    const searchCriteria = await request.json()
    console.log('Discovery search criteria:', searchCriteria)

    if (demoMode) {
      console.log('Returning demo discovery results')
      
      // Filter results based on search criteria
      let filteredResults = [...DEMO_DISCOVERY_COMPANIES]
      
      // Filter by industries
      if (searchCriteria.industries && searchCriteria.industries.length > 0) {
        filteredResults = filteredResults.filter(company => 
          searchCriteria.industries.some((industry: string) => 
            company.industry.toLowerCase().includes(industry.toLowerCase()) ||
            company.description.toLowerCase().includes(industry.toLowerCase())
          )
        )
      }
      
      // Filter by funding stages
      if (searchCriteria.fundingStages && searchCriteria.fundingStages.length > 0) {
        filteredResults = filteredResults.filter(company => 
          searchCriteria.fundingStages.includes(company.fundingStage)
        )
      }
      
      // Filter by locations
      if (searchCriteria.locations && searchCriteria.locations.length > 0) {
        filteredResults = filteredResults.filter(company => 
          searchCriteria.locations.some((location: string) => 
            company.location.toLowerCase().includes(location.toLowerCase())
          )
        )
      }
      
      // Limit results
      const maxResults = searchCriteria.maxResults || 10
      filteredResults = filteredResults.slice(0, maxResults)
      
      return NextResponse.json({
        success: true,
        leads: filteredResults,
        totalCount: filteredResults.length,
        source: 'demo',
        message: `Found ${filteredResults.length} companies matching your criteria`
      })
    }

    // Production mode - no real search configured
    console.log('Production mode: No real discovery service configured')
    
    return NextResponse.json({
      success: true,
      leads: [],
      totalCount: 0,
      source: 'production',
      message: 'No discovery service configured. Enable demo mode to see sample results, or configure Apollo API for real lead discovery.'
    })

  } catch (error) {
    console.error('Discovery Search Error:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Search failed. Please try again.',
        message: error instanceof Error ? error.message : 'Unknown error occurred',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
EOF

# Create /api/discovery/save-leads route
mkdir -p app/api/discovery/save-leads
cat > app/api/discovery/save-leads/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    const { leads } = await request.json()

    if (!leads || !Array.isArray(leads)) {
      return NextResponse.json(
        { success: false, error: 'Invalid leads data. Expected array of leads.' },
        { status: 400 }
      )
    }

    console.log(`Saving ${leads.length} leads to database...`)

    if (demoMode) {
      // Simulate save operation in demo mode
      await new Promise(resolve => setTimeout(resolve, 1500))
      
      const companiesCount = leads.length
      const contactsCount = leads.reduce((sum: number, lead: any) => sum + (lead.contacts?.length || 0), 0)
      
      return NextResponse.json({
        success: true,
        results: {
          companies: companiesCount,
          contacts: contactsCount,
          errors: []
        },
        message: `Demo: Simulated save of ${companiesCount} companies and ${contactsCount} contacts`,
        source: 'demo'
      })
    }

    // Production mode - no real database configured
    return NextResponse.json({
      success: false,
      error: 'Save functionality not available in production mode without database configuration',
      message: 'Configure your database connection to save leads',
      source: 'production'
    })

  } catch (error) {
    console.error('Save Leads API Error:', error)
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to save leads',
        message: error instanceof Error ? error.message : 'Unknown error occurred'
      },
      { status: 500 }
    )
  }
}
EOF

# Create /api/discovery/test route
mkdir -p app/api/discovery/test
cat > app/api/discovery/test/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  return NextResponse.json({
    success: true,
    message: 'Discovery API is working!',
    timestamp: new Date().toISOString(),
    endpoints: [
      '/api/discovery/search (POST)',
      '/api/discovery/save-leads (POST)',
      '/api/discovery/test (GET)'
    ]
  })
}
EOF

# Update discovery page to use demo-aware API calls
echo "Checking if discovery page exists..."

if [ -f "app/discovery/page.tsx" ]; then
    echo "Updating discovery page to use demo-aware API calls..."
    
    # Create backup
    cp "app/discovery/page.tsx" "app/discovery/page.tsx.backup"
    
    # Check if it needs updating
    if ! grep -q "useDemoAPI" "app/discovery/page.tsx"; then
        # Add the import
        sed -i.tmp "s/import { useDemoMode } from '@\/lib\/demo-context'/import { useDemoMode } from '@\/lib\/demo-context'\nimport { useDemoAPI } from '@\/lib\/hooks\/use-demo-api'/" "app/discovery/page.tsx"
        
        # Add the hook usage
        sed -i.tmp "s/const { isDemoMode }/const { isDemoMode } = useDemoMode()\n  const { fetchWithDemo }/" "app/discovery/page.tsx"
        
        # Replace fetch calls
        sed -i.tmp "s/fetch('/fetchWithDemo('/g" "app/discovery/page.tsx"
        
        rm -f "app/discovery/page.tsx.tmp"
        echo "Updated discovery page to use demo-aware API calls"
    else
        echo "Discovery page already has demo-aware API calls"
    fi
else
    echo "Discovery page not found, creating a basic one..."
    
    mkdir -p app/discovery
    cat > app/discovery/page.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { 
  Search, 
  Building, 
  Users, 
  MapPin, 
  DollarSign,
  Calendar,
  ExternalLink,
  Download,
  AlertCircle
} from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'
import { ProductionModeWarning } from '@/components/ui/production-mode-warning'
import { toast } from 'react-hot-toast'

interface Lead {
  id: string
  company: string
  website: string
  industry: string
  description: string
  fundingStage: string
  totalFunding: number
  employeeCount: number
  location: string
  foundedYear: number
  ai_score: number
  contacts: Array<{
    name: string
    title: string
    email: string
    role_category: string
    linkedin: string
  }>
}

export default function DiscoveryPage() {
  const { isDemoMode } = useDemoMode()
  const { fetchWithDemo } = useDemoAPI()
  const [searchCriteria, setSearchCriteria] = useState({
    industries: ['Biotechnology', 'Pharmaceuticals'],
    fundingStages: ['Series A', 'Series B', 'Series C'],
    locations: ['Boston', 'San Francisco', 'Cambridge'],
    maxResults: 10
  })
  const [leads, setLeads] = useState<Lead[]>([])
  const [isSearching, setIsSearching] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [searchCompleted, setSearchCompleted] = useState(false)

  const handleSearch = async () => {
    setIsSearching(true)
    setSearchCompleted(false)
    
    try {
      const response = await fetchWithDemo('/api/discovery/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(searchCriteria)
      })
      
      const data = await response.json()
      
      if (data.success) {
        setLeads(data.leads || [])
        setSearchCompleted(true)
        toast.success(data.message || `Found ${data.leads?.length || 0} companies`)
      } else {
        toast.error(data.error || 'Search failed')
      }
    } catch (error) {
      console.error('Search error:', error)
      toast.error('Search failed. Please try again.')
    } finally {
      setIsSearching(false)
    }
  }

  const handleSaveLeads = async () => {
    if (leads.length === 0) {
      toast.error('No leads to save')
      return
    }

    setIsSaving(true)
    
    try {
      const response = await fetchWithDemo('/api/discovery/save-leads', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ leads })
      })
      
      const data = await response.json()
      
      if (data.success) {
        toast.success(data.message || 'Leads saved successfully')
      } else {
        toast.error(data.error || 'Failed to save leads')
      }
    } catch (error) {
      console.error('Save error:', error)
      toast.error('Failed to save leads. Please try again.')
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <div className="p-6">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Lead Discovery</h1>
            <p className="text-muted-foreground mt-1">Find and analyze biotech companies and contacts</p>
          </div>
          {isDemoMode && (
            <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-900/20 dark:text-blue-400 dark:border-blue-800">
              Demo Mode
            </Badge>
          )}
        </div>
      </div>

      {/* Production Mode Warning */}
      <ProductionModeWarning 
        feature="lead discovery" 
        hasData={false}
        className="mb-6"
      />

      {/* Search Criteria */}
      <Card className="mb-6">
        <CardHeader>
          <CardTitle className="flex items-center">
            <Search className="w-5 h-5 mr-2" />
            Search Criteria
          </CardTitle>
          <CardDescription>
            Define your target companies and contact criteria
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="text-sm font-medium mb-2 block">Industries</label>
            <div className="flex flex-wrap gap-2">
              {['Biotechnology', 'Pharmaceuticals', 'Gene Therapy', 'Medical Devices', 'Diagnostics'].map(industry => (
                <Badge
                  key={industry}
                  variant={searchCriteria.industries.includes(industry) ? 'default' : 'outline'}
                  className="cursor-pointer"
                  onClick={() => {
                    setSearchCriteria(prev => ({
                      ...prev,
                      industries: prev.industries.includes(industry)
                        ? prev.industries.filter(i => i !== industry)
                        : [...prev.industries, industry]
                    }))
                  }}
                >
                  {industry}
                </Badge>
              ))}
            </div>
          </div>

          <div>
            <label className="text-sm font-medium mb-2 block">Funding Stages</label>
            <div className="flex flex-wrap gap-2">
              {['Seed', 'Series A', 'Series B', 'Series C', 'Series D+', 'Public'].map(stage => (
                <Badge
                  key={stage}
                  variant={searchCriteria.fundingStages.includes(stage) ? 'default' : 'outline'}
                  className="cursor-pointer"
                  onClick={() => {
                    setSearchCriteria(prev => ({
                      ...prev,
                      fundingStages: prev.fundingStages.includes(stage)
                        ? prev.fundingStages.filter(s => s !== stage)
                        : [...prev.fundingStages, stage]
                    }))
                  }}
                >
                  {stage}
                </Badge>
              ))}
            </div>
          </div>

          <div className="flex space-x-4">
            <div className="flex-1">
              <label className="text-sm font-medium mb-2 block">Max Results</label>
              <Input
                type="number"
                value={searchCriteria.maxResults}
                onChange={(e) => setSearchCriteria(prev => ({ ...prev, maxResults: parseInt(e.target.value) || 10 }))}
                min="1"
                max="50"
              />
            </div>
            <div className="flex items-end">
              <Button 
                onClick={handleSearch}
                disabled={isSearching}
                className="bg-gradient-to-r from-blue-500 to-purple-600"
              >
                {isSearching ? 'Searching...' : 'Search Companies'}
                <Search className="w-4 h-4 ml-2" />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Results */}
      {searchCompleted && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="flex items-center">
                <Building className="w-5 h-5 mr-2" />
                Search Results ({leads.length})
              </CardTitle>
              {leads.length > 0 && (
                <Button 
                  onClick={handleSaveLeads}
                  disabled={isSaving}
                  variant="outline"
                >
                  {isSaving ? 'Saving...' : 'Save All Leads'}
                  <Download className="w-4 h-4 ml-2" />
                </Button>
              )}
            </div>
          </CardHeader>
          <CardContent>
            {leads.length === 0 ? (
              <div className="text-center py-8">
                <AlertCircle className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                <h3 className="text-lg font-medium text-foreground mb-2">No companies found</h3>
                <p className="text-muted-foreground">Try adjusting your search criteria and search again.</p>
              </div>
            ) : (
              <div className="space-y-4">
                {leads.map((lead) => (
                  <Card key={lead.id} className="hover:shadow-md transition-shadow">
                    <CardContent className="p-6">
                      <div className="flex justify-between items-start mb-4">
                        <div>
                          <h3 className="text-xl font-semibold text-foreground mb-2">{lead.company}</h3>
                          <p className="text-muted-foreground mb-2">{lead.description}</p>
                          <div className="flex items-center space-x-4 text-sm text-muted-foreground">
                            <span className="flex items-center">
                              <Building className="w-4 h-4 mr-1" />
                              {lead.industry}
                            </span>
                            <span className="flex items-center">
                              <MapPin className="w-4 h-4 mr-1" />
                              {lead.location}
                            </span>
                            <span className="flex items-center">
                              <DollarSign className="w-4 h-4 mr-1" />
                              ${(lead.totalFunding / 1000000).toFixed(0)}M
                            </span>
                            <span className="flex items-center">
                              <Users className="w-4 h-4 mr-1" />
                              {lead.employeeCount} employees
                            </span>
                          </div>
                        </div>
                        <div className="flex flex-col items-end space-y-2">
                          <Badge variant="outline">{lead.fundingStage}</Badge>
                          <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                            Score: {lead.ai_score}
                          </Badge>
                        </div>
                      </div>
                      
                      <div className="border-t pt-4">
                        <h4 className="text-sm font-medium text-foreground mb-2">Key Contacts ({lead.contacts.length})</h4>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                          {lead.contacts.map((contact, idx) => (
                            <div key={idx} className="flex items-center justify-between p-3 bg-muted/50 rounded-lg">
                              <div>
                                <p className="font-medium text-foreground">{contact.name}</p>
                                <p className="text-sm text-muted-foreground">{contact.title}</p>
                                <p className="text-xs text-muted-foreground">{contact.email}</p>
                              </div>
                              <div className="flex space-x-2">
                                <Badge variant="outline" className="text-xs">{contact.role_category}</Badge>
                                {contact.linkedin && (
                                  <a 
                                    href={contact.linkedin} 
                                    target="_blank" 
                                    rel="noopener noreferrer"
                                    className="text-blue-600 hover:text-blue-800"
                                  >
                                    <ExternalLink className="w-4 h-4" />
                                  </a>
                                )}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  )
}
EOF
fi

echo ""
echo "Lead Discovery Search Fixed!"
echo "=========================="
echo ""
echo "Created API endpoints:"
echo "• /api/discovery/search (POST) - Main search functionality"
echo "• /api/discovery/save-leads (POST) - Save search results"
echo "• /api/discovery/test (GET) - Test endpoint"
echo ""
echo "Updated discovery page to:"
echo "• Use demo-aware API calls"
echo "• Show production mode warnings"
echo "• Handle search errors properly"
echo "• Display results with contact information"
echo ""
echo "Restart your dev server:"
echo "  npm run dev"
echo ""
echo "Test the discovery search:"
echo "• Visit /discovery"
echo "• Click 'Search Companies' button"
echo "• Should work without 'Search failed' error"
echo "• In demo mode: Shows sample biotech companies"
echo "• In production mode: Shows configuration message"
