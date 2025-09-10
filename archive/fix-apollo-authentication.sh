#!/bin/bash

echo "Fixing Apollo API Authentication"
echo "==============================="

# Fix Apollo service to use correct header authentication
echo "Updating Apollo service with correct authentication..."
cat > lib/services/apollo.ts << 'EOF'
interface ApolloCompany {
  id: string
  name: string
  website_url?: string
  industry?: string
  description?: string
  founded_year?: number
  estimated_num_employees?: number
  retail_location_count?: number
  total_funding?: number
  latest_funding_round_date?: string
  latest_funding_stage?: string
  headquarters_address?: {
    city?: string
    state?: string
    country?: string
  }
  phone?: string
  linkedin_url?: string
  twitter_url?: string
  facebook_url?: string
  primary_domain?: string
}

interface ApolloContact {
  id: string
  first_name: string
  last_name: string
  name: string
  title?: string
  email?: string
  linkedin_url?: string
  twitter_url?: string
  github_url?: string
  facebook_url?: string
  extrapolated_email_confidence?: number
  headline?: string
  photo_url?: string
  employment_history?: Array<{
    organization_name: string
    title: string
    start_date?: string
    end_date?: string
  }>
}

interface ApolloCompanySearchParams {
  organization_locations?: string[]
  organization_num_employees_ranges?: string[]
  revenue_range?: {
    min?: number
    max?: number
  }
  total_funding_range?: {
    min?: number
    max?: number
  }
  latest_funding_amount_range?: {
    min?: number
    max?: number
  }
  q_organization_keyword_tags?: string[]
  q_organization_name?: string
  page?: number
  per_page?: number
}

interface ApolloContactSearchParams {
  organization_ids?: string[]
  person_titles?: string[]
  person_seniorities?: string[]
  organization_locations?: string[]
  page?: number
  per_page?: number
}

interface ApolloSearchResponse {
  accounts: ApolloCompany[]
  breadcrumbs: any[]
  partial_results_only: boolean
  disable_eu_prospecting: boolean
  partial_results_limit: number
  pagination: {
    page: number
    per_page: number
    total_entries: number
    total_pages: number
  }
}

interface ApolloContactsResponse {
  people: ApolloContact[]
  pagination: {
    page: number
    per_page: number
    total_entries: number
    total_pages: number
  }
}

class ApolloService {
  private apiKey: string
  private baseUrl = 'https://api.apollo.io/api/v1'

  constructor() {
    const apiKey = process.env.APOLLO_API_KEY
    if (!apiKey) {
      throw new Error('APOLLO_API_KEY environment variable is required')
    }
    this.apiKey = apiKey
  }

  private async makeRequest(endpoint: string, params: any = {}): Promise<any> {
    const url = `${this.baseUrl}${endpoint}`
    
    // Remove api_key from params since it goes in header
    const { api_key, ...cleanParams } = params
    
    console.log('Apollo API Request:', url, 'Params:', JSON.stringify(cleanParams, null, 2))

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'Accept': 'application/json',
          'X-Api-Key': this.apiKey  // CORRECT: API key in header
        },
        body: JSON.stringify(cleanParams)
      })

      if (!response.ok) {
        const errorText = await response.text()
        console.error('Apollo API Error:', response.status, errorText)
        throw new Error(`Apollo API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()
      console.log('Apollo API Response received:', {
        accounts: data.accounts?.length || 0,
        people: data.people?.length || 0,
        pagination: data.pagination
      })

      return data
    } catch (error) {
      console.error('Apollo API request failed:', error)
      throw error
    }
  }

  async searchCompanies(params: ApolloCompanySearchParams): Promise<ApolloSearchResponse> {
    return this.makeRequest('/mixed_companies/search', params)
  }

  async getCompanyContacts(organizationId: string, titles?: string[]): Promise<ApolloContactsResponse> {
    const contactParams: ApolloContactSearchParams = {
      organization_ids: [organizationId],
      per_page: 10
    }

    if (titles && titles.length > 0) {
      contactParams.person_titles = titles
    }

    return this.makeRequest('/mixed_people/search', contactParams)
  }

  // Map search criteria to Apollo parameters using correct parameter names
  buildSearchParams(searchCriteria: any): ApolloCompanySearchParams {
    const params: ApolloCompanySearchParams = {
      page: 1,
      per_page: Math.min(searchCriteria.maxResults || 25, 100)
    }

    // Map locations - Apollo expects exact location names
    if (searchCriteria.locations && searchCriteria.locations.length > 0) {
      params.organization_locations = searchCriteria.locations
    }

    // Map company size ranges
    if (searchCriteria.companySize) {
      const sizeRanges = []
      const min = searchCriteria.companySize.min || 1
      const max = searchCriteria.companySize.max || 10000

      if (min <= 10 && max >= 10) sizeRanges.push('1,10')
      if (min <= 50 && max >= 11) sizeRanges.push('11,50')  
      if (min <= 200 && max >= 51) sizeRanges.push('51,200')
      if (min <= 500 && max >= 201) sizeRanges.push('201,500')
      if (min <= 1000 && max >= 501) sizeRanges.push('501,1000')
      if (max > 1000) sizeRanges.push('1001,5000', '5001,10000', '10001+')

      if (sizeRanges.length > 0) {
        params.organization_num_employees_ranges = sizeRanges
      }
    }

    // Map funding ranges
    if (searchCriteria.fundingRange) {
      if (searchCriteria.fundingRange.min || searchCriteria.fundingRange.max) {
        params.total_funding_range = {
          min: searchCriteria.fundingRange.min,
          max: searchCriteria.fundingRange.max
        }
      }
    }

    // Use keyword tags for industry filtering since Apollo doesn't have direct industry filter
    if (searchCriteria.industries && searchCriteria.industries.length > 0) {
      // Convert industries to keywords that Apollo can search
      const industryKeywords = searchCriteria.industries.map((industry: string) => {
        return industry.toLowerCase().replace(/\s+/g, '')
      })
      params.q_organization_keyword_tags = industryKeywords
    }

    return params
  }
}

export { ApolloService, type ApolloCompany, type ApolloContact, type ApolloCompanySearchParams }

// Helper functions for the API route
export function categorizeRole(title?: string): string {
  if (!title) return 'Employee'
  const lowerTitle = title.toLowerCase()
  
  if (lowerTitle.includes('founder') || lowerTitle.includes('co-founder')) return 'Founder'
  if (lowerTitle.includes('ceo') || lowerTitle.includes('cto') || lowerTitle.includes('cfo') || lowerTitle.includes('chief')) return 'Executive'
  if (lowerTitle.includes('vp') || lowerTitle.includes('vice president')) return 'Executive'
  if (lowerTitle.includes('director') || lowerTitle.includes('head of')) return 'Management'
  if (lowerTitle.includes('manager')) return 'Management'
  return 'Employee'
}

export function formatLocation(address?: { city?: string; state?: string; country?: string }): string {
  if (!address) return 'Unknown'
  
  const parts = [address.city, address.state, address.country].filter(Boolean)
  return parts.length > 0 ? parts.join(', ') : 'Unknown'
}
EOF

# Update the Apollo test endpoint to use correct authentication
echo "Updating Apollo test endpoint..."
cat > app/api/test/apollo/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    console.log('Testing Apollo API connection...')
    
    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured',
        message: 'Set APOLLO_API_KEY in your environment variables'
      })
    }

    // Test with a simple search for biotech companies using correct API format
    const testParams = {
      q_organization_keyword_tags: ['biotech', 'biotechnology'],
      organization_locations: ['United States'],
      per_page: 5,
      page: 1
    }

    console.log('Testing Apollo with params:', testParams)
    
    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Accept': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY  // CORRECT: API key in header
      },
      body: JSON.stringify(testParams)
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Apollo API error: ${response.status} - ${errorText}`)
    }

    const data = await response.json()
    
    return NextResponse.json({
      success: true,
      message: 'Apollo API connection successful',
      results: {
        companiesFound: data.accounts?.length || 0,
        totalAvailable: data.pagination?.total_entries || 0,
        sampleCompanies: data.accounts?.slice(0, 3).map((company: any) => ({
          name: company.name,
          industry: company.industry,
          location: company.headquarters_address,
          website: company.website_url,
          employees: company.estimated_num_employees,
          funding: company.total_funding
        }))
      },
      pagination: data.pagination
    })

  } catch (error) {
    console.error('Apollo API test failed:', error)
    return NextResponse.json({
      success: false,
      error: 'Apollo API test failed',
      message: error instanceof Error ? error.message : 'Unknown error',
      details: error instanceof Error ? error.stack : undefined
    }, { status: 500 })
  }
}
EOF

# Update the discovery search endpoint to use new Apollo service
echo "Updating discovery search endpoint..."
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
      const apollo = new ApolloService()
      
      // Build Apollo search parameters using the correct API format
      const apolloParams = apollo.buildSearchParams(searchCriteria)

      console.log('Apollo search parameters:', apolloParams)
      
      // Search companies with Apollo
      const apolloResponse = await apollo.searchCompanies(apolloParams)
      
      console.log(`Apollo returned ${apolloResponse.accounts?.length || 0} companies`)

      // Transform Apollo data to our format and get contacts
      const leads = await Promise.all(
        (apolloResponse.accounts || []).map(async (company) => {
          // Get key contacts for each company
          let contacts: any[] = []
          try {
            const contactsResponse = await apollo.getCompanyContacts(
              company.id,
              ['CEO', 'CTO', 'Founder', 'VP', 'Director', 'Manager']
            )
            
            contacts = (contactsResponse.people || []).slice(0, 5).map(person => ({
              name: person.name || `${person.first_name} ${person.last_name}`,
              title: person.title || 'Unknown Title',
              email: person.email,
              role_category: categorizeRole(person.title),
              linkedin: person.linkedin_url
            }))
          } catch (error) {
            console.error(`Failed to get contacts for ${company.name}:`, error)
          }

          const location = formatLocation(company.headquarters_address)

          return {
            id: company.id,
            company: company.name,
            website: company.website_url,
            industry: company.industry || 'Unknown',
            description: company.description || 'No description available',
            fundingStage: company.latest_funding_stage || 'Unknown',
            totalFunding: company.total_funding || 0,
            employeeCount: company.estimated_num_employees || 0,
            location: location,
            foundedYear: company.founded_year || new Date().getFullYear(),
            ai_score: Math.floor(Math.random() * 30) + 70, // Random score for now
            contacts: contacts
          }
        })
      )

      return NextResponse.json({
        success: true,
        leads,
        totalCount: leads.length,
        source: 'apollo',
        message: `Found ${leads.length} companies via Apollo API`,
        pagination: apolloResponse.pagination
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
echo "Apollo API Authentication Fixed!"
echo "==============================="
echo ""
echo "Key fixes:"
echo "• ✅ API key now sent in X-Api-Key header (not request body)"
echo "• ✅ Correct base URL: https://api.apollo.io/api/v1"
echo "• ✅ Removed api_key from request body parameters"
echo "• ✅ Updated both test endpoint and discovery search"
echo "• ✅ Simplified parameter handling"
echo ""
echo "Now test:"
echo "1. Restart your server: npm run dev"
echo "2. Test Apollo API: http://localhost:3000/api/test/apollo"
echo "3. Test discovery: Turn demo mode OFF and search"
echo ""
echo "The Apollo authentication should now work correctly!"
echo ""
