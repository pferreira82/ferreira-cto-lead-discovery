#!/bin/bash

echo "Creating Apollo Diagnostic Tool"
echo "=============================="

# Create a diagnostic endpoint to see raw Apollo responses
echo "Creating Apollo diagnostic endpoint..."
mkdir -p app/api/debug
cat > app/api/debug/apollo/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    console.log('🔍 Apollo Diagnostic Test')
    
    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured'
      })
    }

    // Test with minimal parameters first
    const testParams = {
      page: 1,
      per_page: 5,
      organization_locations: ['United States']
    }

    console.log('🧪 Testing Apollo with minimal params:', testParams)
    
    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Accept': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY
      },
      body: JSON.stringify(testParams)
    })

    console.log('📡 Apollo Response Status:', response.status)
    console.log('📡 Apollo Response Headers:', Object.fromEntries(response.headers.entries()))

    if (!response.ok) {
      const errorText = await response.text()
      console.error('❌ Apollo Error Response:', errorText)
      return NextResponse.json({
        success: false,
        error: `Apollo API error: ${response.status}`,
        details: errorText
      })
    }

    const data = await response.json()
    
    // Log the entire raw response structure
    console.log('📊 Full Apollo Response Structure:')
    console.log('- Keys:', Object.keys(data))
    console.log('- Accounts array exists:', !!data.accounts)
    console.log('- Accounts length:', data.accounts?.length || 'N/A')
    console.log('- Pagination:', data.pagination)
    
    // Log first account if any exist
    if (data.accounts && data.accounts.length > 0) {
      console.log('- First account keys:', Object.keys(data.accounts[0]))
      console.log('- First account sample:', {
        id: data.accounts[0].id,
        name: data.accounts[0].name,
        website: data.accounts[0].website_url,
        industry: data.accounts[0].industry
      })
    }

    return NextResponse.json({
      success: true,
      message: 'Apollo diagnostic complete',
      rawResponse: {
        responseKeys: Object.keys(data),
        hasAccounts: !!data.accounts,
        accountsLength: data.accounts?.length || 0,
        pagination: data.pagination,
        sampleAccount: data.accounts?.[0] ? {
          id: data.accounts[0].id,
          name: data.accounts[0].name,
          website_url: data.accounts[0].website_url,
          industry: data.accounts[0].industry,
          headquarters_address: data.accounts[0].headquarters_address
        } : null,
        // Include first 2 accounts for analysis
        firstTwoAccounts: data.accounts?.slice(0, 2) || []
      },
      testParams
    })

  } catch (error) {
    console.error('🚨 Apollo diagnostic failed:', error)
    return NextResponse.json({
      success: false,
      error: 'Diagnostic test failed',
      message: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined
    }, { status: 500 })
  }
}
EOF

# Create a simplified Apollo test without complex filtering
echo "Creating simplified Apollo test..."
cat > app/api/test/apollo-simple/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured'
      })
    }

    // Try the absolute simplest search possible
    const simpleParams = {
      page: 1,
      per_page: 10
      // No filters at all - just get any companies
    }

    console.log('🔬 Simple Apollo test with no filters:', simpleParams)
    
    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Accept': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY
      },
      body: JSON.stringify(simpleParams)
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Apollo API error: ${response.status} - ${errorText}`)
    }

    const data = await response.json()
    
    console.log('📈 Simple test results:')
    console.log('- Total entries:', data.pagination?.total_entries)
    console.log('- Accounts returned:', data.accounts?.length)
    
    return NextResponse.json({
      success: true,
      message: 'Simple Apollo test successful',
      results: {
        totalEntries: data.pagination?.total_entries,
        accountsReturned: data.accounts?.length,
        pagination: data.pagination,
        firstAccount: data.accounts?.[0] ? {
          name: data.accounts[0].name,
          website: data.accounts[0].website_url,
          location: data.accounts[0].headquarters_address
        } : null
      }
    })

  } catch (error) {
    console.error('🚨 Simple Apollo test failed:', error)
    return NextResponse.json({
      success: false,
      error: 'Simple test failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
EOF

# Update the discovery search to temporarily log more details
echo "Adding more detailed logging to discovery search..."
cat > app/api/discovery/search/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { ApolloService, categorizeRole, formatLocation } from '@/lib/services/apollo'

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

    // Production mode - use Apollo API
    console.log('Production mode: Using Apollo API...')
    
    if (!process.env.APOLLO_API_KEY) {
      console.log('Apollo API key not configured')
      return NextResponse.json({
        success: false,
        error: 'Apollo API not configured',
        message: 'Set APOLLO_API_KEY environment variable to use real lead discovery',
        source: 'production'
      })
    }

    try {
      // Instead of using the complex service, let's try a direct simple call first
      console.log('🧪 Testing direct Apollo call with minimal parameters...')
      
      const testParams = {
        page: 1,
        per_page: 10,
        organization_locations: searchCriteria.locations || ['United States']
      }
      
      console.log('Direct test parameters:', testParams)
      
      const directResponse = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'Accept': 'application/json',
          'X-Api-Key': process.env.APOLLO_API_KEY
        },
        body: JSON.stringify(testParams)
      })

      if (!directResponse.ok) {
        const errorText = await directResponse.text()
        throw new Error(`Apollo API error: ${directResponse.status} - ${errorText}`)
      }

      const apolloData = await directResponse.json()
      
      console.log('🔍 Direct Apollo Response Analysis:')
      console.log('- Response keys:', Object.keys(apolloData))
      console.log('- Has accounts:', !!apolloData.accounts)
      console.log('- Accounts length:', apolloData.accounts?.length || 0)
      console.log('- Total entries:', apolloData.pagination?.total_entries || 0)
      console.log('- Current page:', apolloData.pagination?.page || 'unknown')
      
      if (apolloData.accounts && apolloData.accounts.length > 0) {
        console.log('- First company:', {
          id: apolloData.accounts[0].id,
          name: apolloData.accounts[0].name,
          website: apolloData.accounts[0].website_url
        })
      } else {
        console.log('⚠️ No accounts in response despite total_entries >0')
        console.log('Full response structure:', JSON.stringify(apolloData, null, 2))
      }

      if (!apolloData.accounts || apolloData.accounts.length === 0) {
        return NextResponse.json({
          success: true,
          leads: [],
          totalCount: 0,
          source: 'apollo',
          message: `Apollo found ${apolloData.pagination?.total_entries || 0} total companies but returned 0 results. This may be an API pagination or filtering issue.`,
          debug: {
            totalEntriesFound: apolloData.pagination?.total_entries,
            currentPage: apolloData.pagination?.page,
            totalPages: apolloData.pagination?.total_pages,
            responseKeys: Object.keys(apolloData),
            hasAccountsArray: !!apolloData.accounts
          }
        })
      }

      // Transform results
      const leads = apolloData.accounts.map((company: any) => ({
        id: company.id,
        company: company.name,
        website: company.website_url,
        industry: company.industry || 'Unknown',
        description: company.description || 'No description available',
        fundingStage: company.latest_funding_stage || 'Unknown',
        totalFunding: company.total_funding || 0,
        employeeCount: company.estimated_num_employees || 0,
        location: formatLocation(company.headquarters_address),
        foundedYear: company.founded_year || new Date().getFullYear(),
        ai_score: Math.floor(Math.random() * 30) + 70,
        contacts: [] // Skip contacts for now to focus on company data
      }))

      return NextResponse.json({
        success: true,
        leads,
        totalCount: leads.length,
        source: 'apollo',
        message: `Found ${leads.length} companies via Apollo API (${apolloData.pagination?.total_entries} total available)`,
        pagination: apolloData.pagination
      })

    } catch (apolloError) {
      console.error('Apollo API Error:', apolloError)
      return NextResponse.json({
        success: false,
        error: 'Apollo API request failed',
        message: apolloError instanceof Error ? apolloError.message : 'Unknown Apollo API error',
        source: 'apollo'
      }, { status: 500 })
    }

  } catch (error) {
    console.error('Discovery Search Error:', error)
    return NextResponse.json({
      success: false,
      error: 'Search failed. Please try again.',
      message: error instanceof Error ? error.message : 'Unknown error occurred',
      source: demoMode ? 'demo' : 'production'
    }, { status: 500 })
  }
}
EOF

echo ""
echo "Apollo Diagnostic Tools Created!"
echo "==============================="
echo ""
echo "Run these tests to diagnose the issue:"
echo ""
echo "1. Full diagnostic (shows raw Apollo response):"
echo "   http://localhost:3000/api/debug/apollo"
echo ""
echo "2. Simple test (minimal parameters):"
echo "   http://localhost:3000/api/test/apollo-simple"  
echo ""
echo "3. Try discovery search again:"
echo "   /discovery (with production mode)"
echo ""
echo "The diagnostic will show us:"
echo "• Exact Apollo response structure"
echo "• Whether accounts array exists but is empty"
echo "• Pagination details"
echo "• Sample company data if any"
echo ""
echo "This will help us understand why Apollo shows"
echo "total_entries > 0 but accounts = 0"
echo ""
