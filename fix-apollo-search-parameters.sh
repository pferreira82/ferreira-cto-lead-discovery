#!/bin/bash

echo "Fixing Apollo Search Parameters for Better Results"
echo "==============================================="

# Update Apollo service to use less restrictive and more effective search parameters
echo "Updating Apollo service with optimized search parameters..."
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
          'X-Api-Key': this.apiKey
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

  // Build optimized search parameters that are less restrictive
  buildSearchParams(searchCriteria: any): ApolloCompanySearchParams {
    const params: ApolloCompanySearchParams = {
      page: 1,
      per_page: Math.min(searchCriteria.maxResults || 25, 100)
    }

    // Prioritize locations first (most important filter)
    if (searchCriteria.locations && searchCriteria.locations.length > 0) {
      params.organization_locations = searchCriteria.locations
    }

    // Build industry keywords - make them broader and more flexible
    if (searchCriteria.industries && searchCriteria.industries.length > 0) {
      const industryKeywords = []
      
      searchCriteria.industries.forEach((industry: string) => {
        // Add the industry itself
        industryKeywords.push(industry.toLowerCase())
        
        // Add common variations and related terms
        switch (industry.toLowerCase()) {
          case 'biotechnology':
            industryKeywords.push('biotech', 'life sciences', 'biopharma')
            break
          case 'pharmaceuticals':
            industryKeywords.push('pharma', 'pharmaceutical', 'drug development')
            break
          case 'medical devices':
            industryKeywords.push('medtech', 'medical technology', 'healthcare devices')
            break
          case 'digital health':
            industryKeywords.push('healthtech', 'health tech', 'digital healthcare')
            break
          case 'genomics':
            industryKeywords.push('genetic', 'dna', 'sequencing')
            break
          case 'synthetic biology':
            industryKeywords.push('synbio', 'synthetic bio')
            break
          case 'diagnostics':
            industryKeywords.push('diagnostic', 'testing', 'assays')
            break
        }
      })
      
      // Remove duplicates and use only the most relevant ones
      const uniqueKeywords = [...new Set(industryKeywords)].slice(0, 5)
      params.q_organization_keyword_tags = uniqueKeywords
    }

    // Only add company size if it's not too broad (avoid overly restrictive filters)
    if (searchCriteria.companySize) {
      const min = searchCriteria.companySize.min || 1
      const max = searchCriteria.companySize.max || 10000
      
      // Only apply size filter if it's meaningful (not 1-10000 which is basically everything)
      if (min > 1 || max < 5000) {
        const sizeRanges = []
        
        if (min <= 10 && max >= 10) sizeRanges.push('1,10')
        if (min <= 50 && max >= 11) sizeRanges.push('11,50')  
        if (min <= 200 && max >= 51) sizeRanges.push('51,200')
        if (min <= 500 && max >= 201) sizeRanges.push('201,500')
        if (min <= 1000 && max >= 501) sizeRanges.push('501,1000')
        if (max > 1000) sizeRanges.push('1001,5000')

        if (sizeRanges.length > 0 && sizeRanges.length < 6) {
          params.organization_num_employees_ranges = sizeRanges
        }
      }
    }

    // Only add funding range if it's meaningful and not too restrictive
    if (searchCriteria.fundingRange && 
        searchCriteria.fundingRange.min && 
        searchCriteria.fundingRange.min > 100000) {  // Only if minimum is meaningful
      params.total_funding_range = {
        min: searchCriteria.fundingRange.min,
        max: searchCriteria.fundingRange.max
      }
    }

    return params
  }

  // Try a simplified search if the main search returns no results
  async searchWithFallback(searchCriteria: any): Promise<ApolloSearchResponse> {
    console.log('Attempting primary Apollo search...')
    
    // Try primary search
    const primaryParams = this.buildSearchParams(searchCriteria)
    let response = await this.searchCompanies(primaryParams)
    
    // If no results, try a simplified search
    if (!response.accounts || response.accounts.length === 0) {
      console.log('Primary search returned no results, trying simplified search...')
      
      const fallbackParams: ApolloCompanySearchParams = {
        page: 1,
        per_page: Math.min(searchCriteria.maxResults || 25, 100)
      }

      // Only use the most essential filters
      if (searchCriteria.locations && searchCriteria.locations.length > 0) {
        fallbackParams.organization_locations = searchCriteria.locations
      }

      // Use broader industry keywords
      if (searchCriteria.industries && searchCriteria.industries.length > 0) {
        const hasLowerCase = searchCriteria.industries.some((i: string) => 
          i.toLowerCase().includes('bio') || i.toLowerCase().includes('pharma') || i.toLowerCase().includes('health')
        )
        
        if (hasLowerCase) {
          fallbackParams.q_organization_keyword_tags = ['biotech', 'healthcare', 'life sciences']
        }
      }

      console.log('Fallback search parameters:', fallbackParams)
      response = await this.searchCompanies(fallbackParams)
    }

    return response
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

# Update the discovery search to use the new fallback method
echo "Updating discovery search to use optimized Apollo search..."
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
      
      // Use the new fallback search method
      const apolloResponse = await apollo.searchWithFallback(searchCriteria)
      
      console.log(`Apollo returned ${apolloResponse.accounts?.length || 0} companies`)

      if (!apolloResponse.accounts || apolloResponse.accounts.length === 0) {
        return NextResponse.json({
          success: true,
          leads: [],
          totalCount: 0,
          source: 'apollo',
          message: `No companies found matching your criteria. Try broader search terms or different locations.`,
          pagination: apolloResponse.pagination,
          suggestion: 'Try selecting fewer industries or removing funding filters'
        })
      }

      // Transform Apollo data to our format and get contacts
      const leads = await Promise.all(
        (apolloResponse.accounts || []).map(async (company) => {
          // Get key contacts for each company (but don't fail if contacts fail)
          let contacts: any[] = []
          try {
            const contactsResponse = await apollo.getCompanyContacts(
              company.id,
              ['CEO', 'CTO', 'Founder', 'VP', 'Director']
            )
            
            contacts = (contactsResponse.people || []).slice(0, 5).map(person => ({
              name: person.name || `${person.first_name} ${person.last_name}`,
              title: person.title || 'Unknown Title',
              email: person.email,
              role_category: categorizeRole(person.title),
              linkedin: person.linkedin_url
            }))
          } catch (error) {
            console.warn(`Failed to get contacts for ${company.name}:`, error)
            // Continue without contacts rather than failing
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
echo "Apollo Search Parameters Optimized!"
echo "==================================="
echo ""
echo "Key improvements:"
echo "• ✅ Broader industry keyword matching (biotech, pharma, life sciences)"
echo "• ✅ Less restrictive parameter combinations"
echo "• ✅ Fallback search if primary search returns 0 results"
echo "• ✅ Smarter filtering logic (only apply restrictive filters when meaningful)"
echo "• ✅ Better error handling for contact enrichment"
echo ""
echo "Changes made:"
echo "1. Industry keywords now include variations (biotech, pharma, life sciences)"
echo "2. Size ranges only applied if meaningful (not 1-10000 which is everything)"
echo "3. Funding ranges only applied if minimum is substantial"
echo "4. Automatic fallback to simpler search if no results"
echo "5. Graceful handling when contacts can't be fetched"
echo ""
echo "Now test:"
echo "1. Restart your server: npm run dev"
echo "2. Try discovery search with production mode OFF"
echo ""
echo "You should now get actual company results!"
echo ""
