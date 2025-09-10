#!/bin/bash

echo "Manually Creating Apollo Diagnostic Endpoints"
echo "============================================"

# Create the debug directory structure
mkdir -p app/api/debug/apollo

# Create diagnostic endpoint manually
echo "Creating diagnostic endpoint manually..."
cat > app/api/debug/apollo/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET() {
  try {
    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured'
      })
    }

    // Test with minimal parameters
    const testParams = {
      page: 1,
      per_page: 5,
      organization_locations: ['United States']
    }

    console.log('Testing Apollo with minimal params')
    
    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY
      },
      body: JSON.stringify(testParams)
    })

    const data = await response.json()
    
    console.log('Apollo Response Keys:', Object.keys(data))
    console.log('Accounts array exists:', !!data.accounts)
    console.log('Accounts length:', data.accounts?.length || 0)
    console.log('Total entries:', data.pagination?.total_entries || 0)

    return NextResponse.json({
      success: true,
      results: {
        accountsFound: data.accounts?.length || 0,
        totalAvailable: data.pagination?.total_entries || 0,
        responseKeys: Object.keys(data),
        hasAccountsArray: !!data.accounts,
        pagination: data.pagination,
        firstCompany: data.accounts?.[0] ? {
          name: data.accounts[0].name,
          website: data.accounts[0].website_url,
          industry: data.accounts[0].industry
        } : null
      },
      rawResponse: data
    })

  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
EOF

# Create simple test endpoint
mkdir -p app/api/test/apollo-simple
cat > app/api/test/apollo-simple/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET() {
  try {
    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured'
      })
    }

    // Absolutely minimal test - no filters at all
    const simpleParams = {
      page: 1,
      per_page: 3
    }

    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY
      },
      body: JSON.stringify(simpleParams)
    })

    const data = await response.json()
    
    return NextResponse.json({
      success: response.ok,
      results: {
        companiesReturned: data.accounts?.length || 0,
        totalAvailable: data.pagination?.total_entries || 0,
        companies: data.accounts?.slice(0, 3).map((c: any) => ({
          name: c.name,
          website: c.website_url,
          location: c.headquarters_address
        })) || []
      }
    })

  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
EOF

# Create a simplified discovery search that bypasses complex logic
echo "Creating simplified discovery search for testing..."
cat > app/api/discovery/search-simple/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const demoMode = searchParams.get('demo') === 'true'

    if (demoMode) {
      return NextResponse.json({
        success: true,
        leads: [
          {
            id: 'demo-1',
            company: 'Demo Biotech Corp',
            website: 'https://demo.example.com',
            industry: 'Biotechnology',
            description: 'Demo biotech company',
            fundingStage: 'Series A',
            totalFunding: 10000000,
            employeeCount: 50,
            location: 'Boston, MA, USA',
            foundedYear: 2020,
            ai_score: 85,
            contacts: [{
              name: 'Demo CEO',
              title: 'Chief Executive Officer',
              email: 'ceo@demo.example.com',
              role_category: 'Executive'
            }]
          }
        ],
        totalCount: 1,
        source: 'demo'
      })
    }

    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured'
      })
    }

    // Try the absolute simplest Apollo search
    const apolloParams = {
      page: 1,
      per_page: 10,
      organization_locations: ['United States'],
      q_organization_keyword_tags: ['biotech']
    }

    console.log('Simple Apollo search params:', apolloParams)

    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY
      },
      body: JSON.stringify(apolloParams)
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Apollo error: ${response.status} - ${errorText}`)
    }

    const data = await response.json()
    
    console.log('Simple search - Apollo returned:', {
      totalEntries: data.pagination?.total_entries,
      accountsLength: data.accounts?.length,
      hasAccounts: !!data.accounts
    })

    if (!data.accounts || data.accounts.length === 0) {
      return NextResponse.json({
        success: true,
        leads: [],
        totalCount: 0,
        source: 'apollo',
        message: `Apollo found ${data.pagination?.total_entries || 0} companies but returned 0. This may indicate an Apollo account limitation.`,
        debug: {
          apolloResponse: {
            totalEntries: data.pagination?.total_entries,
            accountsReturned: data.accounts?.length || 0,
            responseKeys: Object.keys(data)
          }
        }
      })
    }

    // Convert Apollo companies to our format
    const leads = data.accounts.map((company: any) => ({
      id: company.id,
      company: company.name,
      website: company.website_url,
      industry: company.industry || 'Unknown',
      description: company.description || 'No description available',
      fundingStage: company.latest_funding_stage || 'Unknown',
      totalFunding: company.total_funding || 0,
      employeeCount: company.estimated_num_employees || 0,
      location: company.headquarters_address ? 
        [company.headquarters_address.city, company.headquarters_address.state, company.headquarters_address.country]
          .filter(Boolean).join(', ') : 'Unknown',
      foundedYear: company.founded_year || 2023,
      ai_score: Math.floor(Math.random() * 30) + 70,
      contacts: [] // Skip contacts for now
    }))

    return NextResponse.json({
      success: true,
      leads,
      totalCount: leads.length,
      source: 'apollo',
      message: `Found ${leads.length} companies from Apollo`,
      apolloMeta: {
        totalAvailable: data.pagination?.total_entries,
        currentPage: data.pagination?.page
      }
    })

  } catch (error) {
    console.error('Simple discovery error:', error)
    return NextResponse.json({
      success: false,
      error: 'Search failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
EOF

echo ""
echo "Manual Apollo Diagnostic Endpoints Created!"
echo "==========================================="
echo ""
echo "Now restart your server and test these endpoints:"
echo ""
echo "1. Basic diagnostic:"
echo "   http://localhost:3000/api/debug/apollo"
echo ""
echo "2. Minimal parameters test:"
echo "   http://localhost:3000/api/test/apollo-simple"
echo ""
echo "3. Test simplified discovery:"
echo "   POST to http://localhost:3000/api/discovery/search-simple"
echo "   (or modify your discovery page to use this endpoint temporarily)"
echo ""
echo "The diagnostic will show us exactly what Apollo is returning"
echo "and whether it's an account limitation or API issue."
echo ""
