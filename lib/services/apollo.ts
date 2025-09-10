interface ApolloCompany {
  id: string
  name: string
  website_url?: string
  primary_domain?: string
  industry?: string
  description?: string
  founded_year?: number
  estimated_num_employees?: number
  organization_revenue?: number
  total_funding?: number
  latest_funding_round_date?: string
  latest_funding_stage?: string
  latest_funding_amount?: number
  headquarters_address?: {
    city?: string
    state?: string
    country?: string
  }
  // Alternative location fields that might exist
  location?: string
  city?: string
  state?: string
  country?: string
  formatted_location?: string
  address?: string
  phone?: string
  linkedin_url?: string
  twitter_url?: string
  facebook_url?: string
  publicly_traded_symbol?: string
  publicly_traded_exchange?: string
  organization_headcount?: number
}

interface ApolloPerson {
  id: string
  first_name: string
  last_name: string
  name: string
  title?: string
  email?: string
  linkedin_url?: string
  email_status?: string
  photo_url?: string
  seniority?: string
  departments?: string[]
  functions?: string[]
  city?: string
  state?: string
  country?: string
  formatted_address?: string
  organization: {
    id: string
    name: string
    primary_domain?: string
    website_url?: string
  }
}

interface ApolloCompanySearchParams {
  organization_locations?: string[]
  organization_num_employees_ranges?: string[]
  revenue_range?: {
    min?: number
    max?: number
  }
  latest_funding_amount_range?: {
    min?: number
    max?: number
  }
  total_funding_range?: {
    min?: number
    max?: number
  }
  q_organization_keyword_tags?: string[]
  page?: number
  per_page?: number
}

interface ApolloContactSearchParams {
  q_organization_domains_list?: string[]
  person_seniorities?: string[]
  person_titles?: string[]
  organization_locations?: string[]
  page?: number
  per_page?: number
}

interface ApolloSearchResponse {
  organizations: ApolloCompany[]
  pagination: {
    page: number
    per_page: number
    total_entries: number
    total_pages: number
  }
}

interface ApolloContactsResponse {
  people: ApolloPerson[]
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
    
    console.log(`Apollo ${endpoint} Request:`, JSON.stringify(params, null, 2))

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'Accept': 'application/json',
          'X-Api-Key': this.apiKey
        },
        body: JSON.stringify(params)
      })

      if (!response.ok) {
        const errorText = await response.text()
        console.error(`Apollo ${endpoint} Error:`, response.status, errorText)
        throw new Error(`Apollo API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()
      console.log(`Apollo ${endpoint} Response:`, {
        organizations: data.organizations?.length || 0,
        people: data.people?.length || 0,
        pagination: data.pagination
      })

      return data
    } catch (error) {
      console.error(`Apollo ${endpoint} request failed:`, error)
      throw error
    }
  }

  async searchCompanies(params: ApolloCompanySearchParams): Promise<ApolloSearchResponse> {
    return this.makeRequest('/mixed_companies/search', params)
  }

  // Enhanced contact search targeting executives and founders
  async getExecutiveContactsByDomain(domain: string, maxContacts: number = 5): Promise<ApolloContactsResponse> {
    const contactParams: ApolloContactSearchParams = {
      q_organization_domains_list: [domain],
      person_seniorities: ['founder', 'c_suite', 'owner', 'partner'], // Target top executives
      person_titles: [
        'founder', 'co-founder', 'ceo', 'chief executive officer',
        'president', 'chairman', 'board member', 'partner',
        'managing partner', 'general partner', 'venture partner'
      ],
      per_page: maxContacts,
      page: 1
    }

    return this.makeRequest('/mixed_people/search', contactParams)
  }

  // Search for VCs and investors by location
  async searchVCsByLocation(locations: string[], maxResults: number = 20): Promise<ApolloContactsResponse> {
    const contactParams: ApolloContactSearchParams = {
      person_titles: [
        'venture capitalist', 'vc', 'investor', 'partner',
        'managing partner', 'general partner', 'venture partner',
        'investment partner', 'principal', 'associate'
      ],
      person_seniorities: ['partner', 'c_suite', 'director', 'vp'],
      organization_locations: locations,
      per_page: maxResults,
      page: 1
    }

    return this.makeRequest('/mixed_people/search', contactParams)
  }

  // Enhanced company search with proper filtering
  async searchCompaniesWithExecutives(
    searchCriteria: any, 
    onProgress?: (step: string, current: number, total: number) => void
  ) {
    // Step 1: Search companies with proper filtering
    onProgress?.('🔍 Searching companies...', 0, 4)
    
    const apolloParams = this.buildSearchParams(searchCriteria)
    console.log('Company search params:', apolloParams)
    
    const companyResponse = await this.searchCompanies(apolloParams)
    const companies = companyResponse.organizations || []
    
    console.log(`Found ${companies.length} companies`)
    
    // DEBUG: Log the first company's structure to see available fields
    if (companies.length > 0) {
      console.log('=== DEBUGGING COMPANY LOCATION FIELDS ===')
      console.log('First company data structure:', JSON.stringify(companies[0], null, 2))
      console.log('Available fields:', Object.keys(companies[0]))
      console.log('=== END DEBUG ===')
    }
    
    if (companies.length === 0) {
      return {
        companies: [],
        totalCompanies: 0,
        totalContacts: 0,
        vcContacts: [],
        pagination: companyResponse.pagination
      }
    }

    onProgress?.('👥 Finding executive contacts...', 1, 4)

    // Step 2: Get executive contacts for each company
    const companiesWithContacts = []
    let totalContactsFound = 0
    
    for (let i = 0; i < companies.length; i++) {
      const company = companies[i]
      
      try {
        if (i % 3 === 0) {
          onProgress?.(`👥 Finding executives for ${company.name}... (${i + 1}/${companies.length})`, 1, 4)
        }

        // Extract domain
        let domain = company.primary_domain
        if (!domain && company.website_url) {
          try {
            const url = new URL(company.website_url.startsWith('http') ? company.website_url : `https://${company.website_url}`)
            domain = url.hostname.replace('www.', '')
          } catch (e) {
            console.warn(`Could not extract domain from ${company.website_url}`)
          }
        }

        let contacts = []
        if (domain) {
          console.log(`Searching executive contacts for ${company.name} using domain: ${domain}`)
          
          const contactResponse = await this.getExecutiveContactsByDomain(domain, 5)
          contacts = (contactResponse.people || []).map(person => ({
            name: person.name || `${person.first_name} ${person.last_name}`,
            title: person.title || 'Unknown Title',
            email: person.email?.includes('email_not_unlocked') ? undefined : person.email,
            role_category: this.categorizeExecutiveRole(person.title, person.seniority),
            linkedin: person.linkedin_url,
            seniority: person.seniority,
            departments: person.departments,
            functions: person.functions,
            photo_url: person.photo_url,
            location: person.formatted_address || `${person.city || ''}, ${person.state || ''}, ${person.country || ''}`.replace(/(^,|,$)/g, '').replace(/,+/g, ', ').trim()
          }))
          
          totalContactsFound += contacts.length
          console.log(`Found ${contacts.length} executive contacts for ${company.name}`)
        } else {
          console.warn(`No domain found for ${company.name}`)
        }

        // Enhanced company data with dual location formats
        const locationInfo = this.extractDualLocationFormats(company, searchCriteria.locations)
        console.log(`Location for ${company.name}:`, locationInfo)
        
        const enhancedCompany = {
          ...company,
          contacts: contacts,
          domain: domain,
          location: locationInfo.short, // For table display
          full_address: locationInfo.full, // For detail view
          funding_info: {
            stage: company.latest_funding_stage,
            amount: company.latest_funding_amount,
            total_funding: company.total_funding,
            date: company.latest_funding_round_date
          }
        }

        companiesWithContacts.push(enhancedCompany)

        // Rate limiting
        if (i < companies.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 150))
        }
        
      } catch (error) {
        console.error(`Failed to get contacts for ${company.name}:`, error)
        const locationInfo = this.extractDualLocationFormats(company, searchCriteria.locations)
        companiesWithContacts.push({
          ...company,
          contacts: [],
          domain: company.primary_domain || 'unknown',
          location: locationInfo.short,
          full_address: locationInfo.full
        })
      }
    }

    onProgress?.('💼 Finding VCs and investors...', 2, 4)

    // Step 3: Search for VCs in the same locations
    let vcContacts = []
    if (searchCriteria.includeVCs && searchCriteria.locations?.length > 0) {
      try {
        const vcResponse = await this.searchVCsByLocation(searchCriteria.locations, 15)
        vcContacts = (vcResponse.people || []).map(person => ({
          name: person.name || `${person.first_name} ${person.last_name}`,
          title: person.title || 'Unknown Title',
          email: person.email?.includes('email_not_unlocked') ? undefined : person.email,
          role_category: 'Investor/VC',
          linkedin: person.linkedin_url,
          seniority: person.seniority,
          photo_url: person.photo_url,
          location: person.formatted_address || `${person.city || ''}, ${person.state || ''}, ${person.country || ''}`.replace(/(^,|,$)/g, '').replace(/,+/g, ', ').trim(),
          organization: person.organization?.name || 'Unknown',
          organization_domain: person.organization?.primary_domain
        }))
        
        console.log(`Found ${vcContacts.length} VCs and investors`)
      } catch (error) {
        console.error('Failed to search VCs:', error)
      }
    }

    onProgress?.('🧠 Analyzing and scoring results...', 3, 4)

    // Step 4: Calculate AI scores
    const finalCompanies = companiesWithContacts.map(company => ({
      ...company,
      ai_score: this.calculateEnhancedAIScore(company, searchCriteria)
    }))

    onProgress?.('✅ Complete!', 4, 4)

    const result = {
      companies: finalCompanies,
      totalCompanies: finalCompanies.length,
      totalContacts: totalContactsFound,
      vcContacts: vcContacts,
      pagination: companyResponse.pagination
    }

    console.log('Final results:', {
      companies: result.totalCompanies,
      contacts: result.totalContacts,
      vcs: result.vcContacts.length
    })

    return result
  }

  // NEW: Extract both short and full location formats
  private extractDualLocationFormats(company: any, searchLocations?: string[]): { short: string, full: string } {
    console.log(`Extracting dual location formats for ${company.name}:`, {
      headquarters_address: company.headquarters_address,
      location: company.location,
      city: company.city,
      state: company.state,
      country: company.country,
      formatted_location: company.formatted_location,
      address: company.address
    })

    let city = ''
    let state = ''
    let country = ''
    let fullAddress = ''

    // Method 1: headquarters_address object
    if (company.headquarters_address) {
      const addr = company.headquarters_address
      city = addr.city || ''
      state = addr.state || ''
      country = addr.country || ''
      fullAddress = [addr.city, addr.state, addr.country].filter(Boolean).join(', ')
      console.log(`Using headquarters_address - City: ${city}, Country: ${country}, Full: ${fullAddress}`)
    }
    // Method 2: Individual fields
    else if (company.city || company.state || company.country) {
      city = company.city || ''
      state = company.state || ''
      country = company.country || ''
      fullAddress = [city, state, country].filter(Boolean).join(', ')
      console.log(`Using individual fields - City: ${city}, Country: ${country}, Full: ${fullAddress}`)
    }
    // Method 3: Parse from formatted location or direct location
    else if (company.formatted_location || company.location) {
      const locationStr = company.formatted_location || company.location
      fullAddress = locationStr
      
      // Try to extract city and country from full location string
      const parts = locationStr.split(',').map((s: string) => s.trim())
      if (parts.length >= 2) {
        city = parts[0] // First part is usually city
        country = parts[parts.length - 1] // Last part is usually country
      }
      console.log(`Using formatted location - City: ${city}, Country: ${country}, Full: ${fullAddress}`)
    }
    // Method 4: Address field
    else if (company.address) {
      fullAddress = company.address
      // Basic parsing attempt for city/country from address
      const parts = company.address.split(',').map((s: string) => s.trim())
      if (parts.length >= 2) {
        city = parts[0]
        country = parts[parts.length - 1]
      }
      console.log(`Using address field - City: ${city}, Country: ${country}, Full: ${fullAddress}`)
    }

    // Fallback methods if we still don't have location
    if (!city && !country && !fullAddress) {
      // Method 5: Domain inference
      const domain = company.primary_domain || company.website_url
      if (domain) {
        if (domain.includes('.uk') || domain.includes('co.uk')) {
          country = 'United Kingdom'
          fullAddress = 'United Kingdom'
        } else if (domain.includes('.de')) {
          country = 'Germany'
          fullAddress = 'Germany'
        } else if (domain.includes('.fr')) {
          country = 'France'
          fullAddress = 'France'
        } else if (domain.includes('.ca')) {
          country = 'Canada'
          fullAddress = 'Canada'
        }
        console.log(`Inferred from domain - Country: ${country}, Full: ${fullAddress}`)
      }
      
      // Method 6: Search location fallback
      if (!country && searchLocations && searchLocations.length > 0) {
        country = searchLocations[0]
        fullAddress = searchLocations[0]
        console.log(`Using search location fallback - Country: ${country}, Full: ${fullAddress}`)
      }
    }

    // Create short format (City, Country) and full format
    const shortLocation = [city, country].filter(Boolean).join(', ') || fullAddress || 'Unknown'
    const fullLocation = fullAddress || [city, state, country].filter(Boolean).join(', ') || 'Unknown'

    console.log(`Final formats - Short: "${shortLocation}", Full: "${fullLocation}"`)

    return {
      short: shortLocation,
      full: fullLocation
    }
  }

  private calculateEnhancedAIScore(company: any, searchCriteria: any): number {
    let score = 70 // Base score
    
    // Executive contacts boost
    if (company.contacts?.length > 0) score += 20
    if (company.contacts?.length >= 3) score += 10
    
    // Founder/C-suite boost
    const founderContacts = company.contacts?.filter((c: any) => 
      c.role_category === 'Founder' || c.role_category === 'C-Suite'
    ).length || 0
    if (founderContacts > 0) score += 15
    if (founderContacts >= 2) score += 10
    
    // Funding stage relevance
    if (company.latest_funding_stage && searchCriteria.fundingStages?.includes(company.latest_funding_stage)) {
      score += 15
    }
    
    // Recent funding boost
    if (company.latest_funding_round_date) {
      const fundingDate = new Date(company.latest_funding_round_date)
      const now = new Date()
      const monthsAgo = (now.getTime() - fundingDate.getTime()) / (1000 * 60 * 60 * 24 * 30)
      if (monthsAgo <= 12) score += 10 // Funded in last year
      if (monthsAgo <= 6) score += 5   // Funded in last 6 months
    }
    
    // Company maturity and scale
    if (company.founded_year && company.founded_year >= 2015) score += 5
    if (company.publicly_traded_symbol) score += 10
    if (company.total_funding && company.total_funding > 10000000) score += 8
    
    // Location boost for major tech hubs
    const majorHubs = ['san francisco', 'boston', 'new york', 'london', 'cambridge', 'palo alto', 'silicon valley']
    if (majorHubs.some(hub => company.location?.toLowerCase().includes(hub))) {
      score += 5
    }
    
    return Math.min(Math.max(score, 60), 100)
  }

  private categorizeExecutiveRole(title?: string, seniority?: string): string {
    if (!title && !seniority) return 'Executive'
    
    const lowerTitle = (title || '').toLowerCase()
    
    // Founders
    if (seniority === 'founder' || lowerTitle.includes('founder')) return 'Founder'
    
    // C-Suite
    if (seniority === 'c_suite' || 
        lowerTitle.includes('ceo') || lowerTitle.includes('chief') ||
        lowerTitle.includes('president') || lowerTitle.includes('chairman')) return 'C-Suite'
    
    // Board/Partners
    if (seniority === 'partner' || seniority === 'owner' ||
        lowerTitle.includes('board') || lowerTitle.includes('partner')) return 'Board/Partner'
    
    // VPs and Directors
    if (seniority === 'vp' || lowerTitle.includes('vp') || lowerTitle.includes('vice president')) return 'VP'
    if (seniority === 'director' || lowerTitle.includes('director')) return 'Director'
    
    return 'Executive'
  }

  buildSearchParams(searchCriteria: any): ApolloCompanySearchParams {
    const params: ApolloCompanySearchParams = {
      page: 1,
      per_page: Math.min(searchCriteria.maxResults || 25, 50)
    }

    // FIXED: Proper location filtering
    if (searchCriteria.locations && searchCriteria.locations.length > 0) {
      params.organization_locations = searchCriteria.locations
      console.log('Using locations:', searchCriteria.locations)
    }

    // Enhanced industry keywords
    if (searchCriteria.industries && searchCriteria.industries.length > 0) {
      const industryKeywords = []
      
      searchCriteria.industries.forEach((industry: string) => {
        switch (industry.toLowerCase()) {
          case 'biotechnology':
            industryKeywords.push('biotech', 'biotechnology', 'life sciences', 'therapeutics')
            break
          case 'pharmaceuticals':
            industryKeywords.push('pharma', 'pharmaceutical', 'drug development', 'biopharma')
            break
          case 'medical devices':
            industryKeywords.push('medtech', 'medical device', 'healthcare technology')
            break
          case 'digital health':
            industryKeywords.push('healthtech', 'digital health', 'telemedicine')
            break
          case 'venture capital':
            industryKeywords.push('venture capital', 'vc', 'investment', 'private equity')
            break
          default:
            industryKeywords.push(industry.toLowerCase())
        }
      })
      
      params.q_organization_keyword_tags = [...new Set(industryKeywords)].slice(0, 5)
      console.log('Using industry keywords:', params.q_organization_keyword_tags)
    }

    // FIXED: Funding stage filtering using funding amount ranges
    if (searchCriteria.fundingStages && searchCriteria.fundingStages.length > 0) {
      const hasEarly = searchCriteria.fundingStages.some((stage: string) => 
        ['Pre-Seed', 'Seed', 'Series A'].includes(stage))
      const hasGrowth = searchCriteria.fundingStages.some((stage: string) => 
        ['Series B', 'Series C', 'Series D+', 'Growth'].includes(stage))

      if (hasEarly && hasGrowth) {
        // Both early and growth stage
        params.total_funding_range = { min: 1000000, max: 500000000 }
      } else if (hasEarly) {
        // Early stage funding
        params.total_funding_range = { min: 100000, max: 50000000 }
      } else if (hasGrowth) {
        // Growth stage funding
        params.total_funding_range = { min: 10000000, max: 1000000000 }
      }
      
      console.log('Using funding range:', params.total_funding_range)
    }

    // Employee count filtering
    if (searchCriteria.employeeRanges && searchCriteria.employeeRanges.length > 0) {
      params.organization_num_employees_ranges = searchCriteria.employeeRanges
    }

    return params
  }
}

export { ApolloService }

export function formatLocation(address?: { city?: string; state?: string; country?: string }): string {
  if (!address) return 'Unknown'
  const parts = [address.city, address.state, address.country].filter(Boolean)
  return parts.length > 0 ? parts.join(', ') : 'Unknown'
}
