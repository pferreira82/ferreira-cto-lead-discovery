#!/bin/bash

echo "Fixing Production Mode to Query Real Database"
echo "============================================"

# Create a debug endpoint to check database connection
echo "Creating database connection debug endpoint..."
mkdir -p app/api/debug/database
cat > app/api/debug/database/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'

export async function GET(request: NextRequest) {
  try {
    console.log('=== Database Debug Check ===')
    
    // Check environment variables
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY
    
    console.log('Supabase URL:', supabaseUrl ? `${supabaseUrl.substring(0, 30)}...` : 'NOT SET')
    console.log('Anon Key:', supabaseAnonKey ? `${supabaseAnonKey.substring(0, 20)}...` : 'NOT SET')
    console.log('Service Key:', supabaseServiceKey ? `${supabaseServiceKey.substring(0, 20)}...` : 'NOT SET')
    
    const envCheck = {
      hasUrl: !!supabaseUrl,
      hasAnonKey: !!supabaseAnonKey,
      hasServiceKey: !!supabaseServiceKey,
      isConfigured: isSupabaseConfigured(),
      adminClientExists: !!supabaseAdmin
    }
    
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return NextResponse.json({
        success: false,
        error: 'Supabase not properly configured',
        details: envCheck,
        message: 'Check your environment variables'
      })
    }
    
    // Test database connection
    console.log('Testing database connection...')
    const { data: testData, error: testError } = await supabaseAdmin
      .from('companies')
      .select('count(*)', { count: 'exact' })
      .limit(1)
    
    if (testError) {
      console.error('Database test error:', testError)
      return NextResponse.json({
        success: false,
        error: 'Database connection failed',
        details: {
          ...envCheck,
          databaseError: testError.message,
          errorCode: testError.code
        }
      })
    }
    
    // Get actual company count
    const { count: companyCount, error: countError } = await supabaseAdmin
      .from('companies')
      .select('*', { count: 'exact', head: true })
    
    // Get some sample companies
    const { data: sampleCompanies, error: sampleError } = await supabaseAdmin
      .from('companies')
      .select('id, name, industry, funding_stage, location')
      .limit(5)
    
    return NextResponse.json({
      success: true,
      message: 'Database connection successful',
      details: {
        ...envCheck,
        companyCount: companyCount || 0,
        hasCompanies: (companyCount || 0) > 0,
        sampleCompanies: sampleCompanies || [],
        errors: {
          countError: countError?.message,
          sampleError: sampleError?.message
        }
      }
    })
    
  } catch (error) {
    console.error('Database debug error:', error)
    return NextResponse.json({
      success: false,
      error: 'Database debug failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
EOF

# Update the discovery search to actually query the database in production
echo "Updating discovery search to query database in production mode..."
cat > app/api/discovery/search/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'

// Demo biotech companies for discovery (fallback)
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
    console.log('Demo mode:', demoMode)

    if (demoMode) {
      console.log('Returning demo discovery results')
      
      // Filter demo results based on search criteria
      let filteredResults = [...DEMO_DISCOVERY_COMPANIES]
      
      if (searchCriteria.industries && searchCriteria.industries.length > 0) {
        filteredResults = filteredResults.filter(company => 
          searchCriteria.industries.some((industry: string) => 
            company.industry.toLowerCase().includes(industry.toLowerCase()) ||
            company.description.toLowerCase().includes(industry.toLowerCase())
          )
        )
      }
      
      if (searchCriteria.fundingStages && searchCriteria.fundingStages.length > 0) {
        filteredResults = filteredResults.filter(company => 
          searchCriteria.fundingStages.includes(company.fundingStage)
        )
      }
      
      const maxResults = searchCriteria.maxResults || 10
      filteredResults = filteredResults.slice(0, maxResults)
      
      return NextResponse.json({
        success: true,
        leads: filteredResults,
        totalCount: filteredResults.length,
        source: 'demo',
        message: `Found ${filteredResults.length} demo companies matching your criteria`
      })
    }

    // Production mode - query real database
    console.log('Production mode: Querying real database...')
    
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      console.log('Supabase not configured, falling back to demo data')
      return NextResponse.json({
        success: true,
        leads: DEMO_DISCOVERY_COMPANIES.slice(0, searchCriteria.maxResults || 10),
        totalCount: DEMO_DISCOVERY_COMPANIES.length,
        source: 'fallback_demo',
        message: 'Database not configured, showing demo data. Configure Supabase to see real companies.'
      })
    }
    
    // Build query
    let query = supabaseAdmin
      .from('companies')
      .select(`
        id,
        name,
        website,
        industry,
        description,
        funding_stage,
        total_funding,
        employee_count,
        location,
        created_at,
        contacts (
          id,
          first_name,
          last_name,
          email,
          title,
          role_category,
          linkedin_url
        )
      `)
    
    // Apply filters
    if (searchCriteria.industries && searchCriteria.industries.length > 0) {
      query = query.in('industry', searchCriteria.industries)
    }
    
    if (searchCriteria.fundingStages && searchCriteria.fundingStages.length > 0) {
      query = query.in('funding_stage', searchCriteria.fundingStages)
    }
    
    if (searchCriteria.locations && searchCriteria.locations.length > 0) {
      // Use ilike for partial location matching
      const locationFilter = searchCriteria.locations
        .map((loc: string) => `location.ilike.%${loc}%`)
        .join(',')
      query = query.or(locationFilter)
    }
    
    // Limit results
    const maxResults = Math.min(searchCriteria.maxResults || 50, 100)
    query = query.limit(maxResults)
    
    const { data: companies, error } = await query
    
    if (error) {
      console.error('Database query error:', error)
      return NextResponse.json({
        success: false,
        error: 'Database query failed',
        message: error.message,
        source: 'production'
      }, { status: 500 })
    }
    
    // Transform data to match expected format
    const leads = (companies || []).map(company => ({
      id: company.id,
      company: company.name,
      website: company.website,
      industry: company.industry,
      description: company.description,
      fundingStage: company.funding_stage,
      totalFunding: company.total_funding,
      employeeCount: company.employee_count,
      location: company.location,
      foundedYear: new Date(company.created_at).getFullYear(),
      ai_score: Math.floor(Math.random() * 30) + 70, // Random score for demo
      contacts: (company.contacts || []).map(contact => ({
        name: `${contact.first_name} ${contact.last_name}`,
        title: contact.title,
        email: contact.email,
        role_category: contact.role_category,
        linkedin: contact.linkedin_url
      }))
    }))
    
    console.log(`Found ${leads.length} companies in production database`)
    
    return NextResponse.json({
      success: true,
      leads,
      totalCount: leads.length,
      source: 'production',
      message: `Found ${leads.length} companies in your database`
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

# Update the debug discovery page to include database test
echo "Adding database test to debug page..."
cat > app/discovery/page.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Search, AlertCircle, Database } from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'
import { toast } from 'react-hot-toast'

export default function DiscoveryPage() {
  const { isDemoMode } = useDemoMode()
  const { fetchWithDemo } = useDemoAPI()
  const [isTestingDatabase, setIsTestingDatabase] = useState(false)
  const [isTestingSearch, setIsTestingSearch] = useState(false)
  const [databaseResults, setDatabaseResults] = useState<any>(null)
  const [searchResults, setSearchResults] = useState<any>(null)

  const testDatabase = async () => {
    setIsTestingDatabase(true)
    setDatabaseResults(null)
    
    try {
      console.log('Testing database connection...')
      const response = await fetch('/api/debug/database')
      const data = await response.json()
      
      console.log('Database test response:', data)
      setDatabaseResults(data)
      
      if (data.success) {
        toast.success(`Database connected! Found ${data.details?.companyCount || 0} companies`)
      } else {
        toast.error('Database connection failed')
      }
    } catch (error) {
      console.error('Database test error:', error)
      setDatabaseResults({ error: error.message })
      toast.error('Database test failed')
    } finally {
      setIsTestingDatabase(false)
    }
  }

  const testSearch = async () => {
    setIsTestingSearch(true)
    setSearchResults(null)
    
    try {
      console.log('Testing search...')
      const searchResponse = await fetchWithDemo('/api/discovery/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          industries: ['Biotechnology'],
          fundingStages: ['Series A', 'Series B', 'Series C', 'Public'],
          maxResults: 10
        })
      })
      
      if (!searchResponse.ok) {
        const errorText = await searchResponse.text()
        throw new Error(`Search API returned ${searchResponse.status}: ${errorText}`)
      }
      
      const searchData = await searchResponse.json()
      console.log('Search response:', searchData)
      
      setSearchResults(searchData)
      
      if (searchData.success) {
        toast.success(`Search successful: ${searchData.leads?.length || 0} companies found (${searchData.source})`)
      } else {
        toast.error(searchData.error || 'Search failed')
      }
      
    } catch (error) {
      console.error('Search error:', error)
      setSearchResults({ error: error.message })
      toast.error(`Search failed: ${error.message}`)
    } finally {
      setIsTestingSearch(false)
    }
  }

  return (
    <div className="p-6">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Discovery Debug</h1>
            <p className="text-muted-foreground mt-1">Debug database connection and search functionality</p>
          </div>
          <div className="flex items-center space-x-2">
            {isDemoMode ? (
              <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
                Demo Mode ON
              </Badge>
            ) : (
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                Production Mode
              </Badge>
            )}
          </div>
        </div>
      </div>

      {/* Debug Tests */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Database className="w-5 h-5 mr-2" />
              1. Database Connection Test
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Test if your Supabase database is connected and has company data
            </p>
            <Button 
              onClick={testDatabase}
              disabled={isTestingDatabase}
              variant="outline"
              className="w-full"
            >
              {isTestingDatabase ? 'Testing Database...' : 'Test Database Connection'}
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Search className="w-5 h-5 mr-2" />
              2. Search Functionality Test
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Test the discovery search with current mode ({isDemoMode ? 'demo' : 'production'})
            </p>
            <Button 
              onClick={testSearch}
              disabled={isTestingSearch}
              className="w-full bg-gradient-to-r from-blue-500 to-purple-600"
            >
              {isTestingSearch ? 'Searching...' : 'Test Search'}
              <Search className="w-4 h-4 ml-2" />
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Database Test Results */}
      {databaseResults && (
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Database Test Results</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {databaseResults.success ? (
                <div className="p-4 bg-green-50 border border-green-200 rounded">
                  <div className="flex items-center">
                    <div className="w-4 h-4 bg-green-500 rounded-full mr-3"></div>
                    <span className="font-medium text-green-800">Database Connected Successfully</span>
                  </div>
                  <div className="mt-2 text-sm text-green-700">
                    <p>Companies in database: <strong>{databaseResults.details?.companyCount || 0}</strong></p>
                    {databaseResults.details?.sampleCompanies?.length > 0 && (
                      <div className="mt-2">
                        <p className="font-medium">Sample companies:</p>
                        <ul className="list-disc list-inside ml-4">
                          {databaseResults.details.sampleCompanies.map((company: any, idx: number) => (
                            <li key={idx}>{company.name} ({company.industry})</li>
                          ))}
                        </ul>
                      </div>
                    )}
                  </div>
                </div>
              ) : (
                <div className="p-4 bg-red-50 border border-red-200 rounded">
                  <div className="flex items-center">
                    <AlertCircle className="w-5 h-5 text-red-600 mr-2" />
                    <span className="font-medium text-red-800">Database Connection Failed</span>
                  </div>
                  <p className="text-sm text-red-700 mt-1">{databaseResults.error}</p>
                </div>
              )}
              
              <details className="mt-4">
                <summary className="cursor-pointer text-sm font-medium">View Raw Results</summary>
                <pre className="text-xs bg-muted p-4 rounded mt-2 overflow-auto">
                  {JSON.stringify(databaseResults, null, 2)}
                </pre>
              </details>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Search Test Results */}
      {searchResults && (
        <Card>
          <CardHeader>
            <CardTitle>Search Test Results</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {searchResults.success ? (
                <div className="p-4 bg-green-50 border border-green-200 rounded">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="w-4 h-4 bg-green-500 rounded-full mr-3"></div>
                      <span className="font-medium text-green-800">Search Successful</span>
                    </div>
                    <Badge variant="outline" className={
                      searchResults.source === 'demo' ? 'bg-blue-100 text-blue-800' :
                      searchResults.source === 'production' ? 'bg-green-100 text-green-800' :
                      'bg-orange-100 text-orange-800'
                    }>
                      {searchResults.source}
                    </Badge>
                  </div>
                  <p className="text-sm text-green-700 mt-2">
                    Found <strong>{searchResults.leads?.length || 0}</strong> companies
                  </p>
                  {searchResults.message && (
                    <p className="text-sm text-green-600 mt-1">{searchResults.message}</p>
                  )}
                </div>
              ) : (
                <div className="p-4 bg-red-50 border border-red-200 rounded">
                  <div className="flex items-center">
                    <AlertCircle className="w-5 h-5 text-red-600 mr-2" />
                    <span className="font-medium text-red-800">Search Failed</span>
                  </div>
                  <p className="text-sm text-red-700 mt-1">{searchResults.error}</p>
                </div>
              )}

              {searchResults.leads && searchResults.leads.length > 0 && (
                <div className="mt-4">
                  <h4 className="font-medium mb-2">Found Companies:</h4>
                  <div className="space-y-2">
                    {searchResults.leads.slice(0, 5).map((lead: any, idx: number) => (
                      <div key={idx} className="p-3 bg-muted/50 rounded">
                        <p className="font-medium">{lead.company}</p>
                        <p className="text-sm text-muted-foreground">
                          {lead.industry} • {lead.location} • {lead.contacts?.length || 0} contacts
                        </p>
                      </div>
                    ))}
                    {searchResults.leads.length > 5 && (
                      <p className="text-sm text-muted-foreground">
                        ...and {searchResults.leads.length - 5} more companies
                      </p>
                    )}
                  </div>
                </div>
              )}
              
              <details className="mt-4">
                <summary className="cursor-pointer text-sm font-medium">View Raw Results</summary>
                <pre className="text-xs bg-muted p-4 rounded mt-2 overflow-auto max-h-96">
                  {JSON.stringify(searchResults, null, 2)}
                </pre>
              </details>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
EOF

echo ""
echo "Production Database Query Fix Applied!"
echo "===================================="
echo ""
echo "Changes made:"
echo "• Created /api/debug/database to test your Supabase connection"
echo "• Updated discovery search to actually query your database in production"
echo "• Enhanced debug page with database connection test"
echo "• Discovery now uses real companies from your Supabase database"
echo ""
echo "To debug your production issue:"
echo "1. Restart your dev server: npm run dev"
echo "2. Visit /discovery"
echo "3. Click 'Test Database Connection' first"
echo "4. Then click 'Test Search' to see if it finds real companies"
echo ""
echo "The database test will show:"
echo "• If your environment variables are loaded correctly"
echo "• If Supabase connection is working"
echo "• How many companies are in your database"
echo "• Sample company names from your database"
echo ""
echo "If database test succeeds but shows 0 companies,"
echo "it means your Supabase tables are empty and need data."
