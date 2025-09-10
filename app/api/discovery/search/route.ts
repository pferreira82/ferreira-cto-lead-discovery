import { NextRequest, NextResponse } from 'next/server'
import { ApolloService, categorizeRole, formatLocation } from '@/lib/services/apollo'

// Demo companies
const DEMO_DISCOVERY_COMPANIES = [
  {
    id: 'discovery-1',
    company: 'Moderna',
    website: 'https://www.modernatx.com',
    industry: 'mRNA Therapeutics',
    description: 'mRNA therapeutics and vaccines company',
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
        role_category: 'Executive'
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
      return NextResponse.json({
        success: true,
        leads: DEMO_DISCOVERY_COMPANIES,
        totalCount: DEMO_DISCOVERY_COMPANIES.length,
        source: 'demo',
        message: 'Demo companies'
      })
    }

    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API not configured'
      })
    }

    try {
      const apollo = new ApolloService()
      const apolloParams = apollo.buildSearchParams(searchCriteria)
      
      console.log('Apollo search parameters:', apolloParams)
      
      const apolloResponse = await apollo.searchCompanies(apolloParams)
      
      // FIXED: Use organizations array instead of accounts
      const companies = apolloResponse.organizations || []
      console.log(`Apollo returned ${companies.length} organizations`)

      if (companies.length === 0) {
        return NextResponse.json({
          success: true,
          leads: [],
          totalCount: 0,
          source: 'apollo',
          message: `No companies found matching your criteria. Try broader search terms.`,
          apolloMeta: {
            totalAvailable: apolloResponse.pagination?.total_entries || 0
          }
        })
      }

      // Transform Apollo organizations to our format
      const leads = companies.map((company) => ({
        id: company.id,
        company: company.name,
        website: company.website_url,
        industry: 'Technology', // Apollo doesn't always have industry field
        description: `Founded ${company.founded_year || 'unknown'}. ${company.publicly_traded_symbol ? `Public company (${company.publicly_traded_symbol})` : 'Private company'}.`,
        fundingStage: company.publicly_traded_symbol ? 'Public' : 'Private',
        totalFunding: company.organization_revenue || 0,
        employeeCount: company.estimated_num_employees || 0,
        location: formatLocation(company.headquarters_address),
        foundedYear: company.founded_year || 2023,
        ai_score: Math.floor(Math.random() * 30) + 70,
        contacts: [] // Skip contacts for initial testing
      }))

      return NextResponse.json({
        success: true,
        leads,
        totalCount: leads.length,
        source: 'apollo',
        message: `Found ${leads.length} companies from Apollo (${apolloResponse.pagination?.total_entries} total available)`,
        apolloMeta: {
          totalAvailable: apolloResponse.pagination?.total_entries,
          currentPage: apolloResponse.pagination?.page
        }
      })

    } catch (apolloError) {
      console.error('Apollo API Error:', apolloError)
      return NextResponse.json({
        success: false,
        error: 'Apollo API request failed',
        message: apolloError instanceof Error ? apolloError.message : 'Unknown error'
      }, { status: 500 })
    }

  } catch (error) {
    console.error('Discovery Search Error:', error)
    return NextResponse.json({
      success: false,
      error: 'Search failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
