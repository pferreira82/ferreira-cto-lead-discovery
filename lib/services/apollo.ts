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
  headquarters_address?: {
    city?: string
    state?: string
    country?: string
  }
  phone?: string
  linkedin_url?: string
  twitter_url?: string
  facebook_url?: string
  publicly_traded_symbol?: string
  publicly_traded_exchange?: string
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
  organization: {
    id: string
    name: string
  }
}

interface ApolloCompanySearchParams {
  organization_locations?: string[]
  organization_num_employees_ranges?: string[]
  revenue_range?: {
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

  // FIXED: Use domain-based contact search like the example
  async getCompanyContactsByDomain(domain: string, maxContacts: number = 5): Promise<ApolloContactsResponse> {
    const contactParams: ApolloContactSearchParams = {
      q_organization_domains_list: [domain], // CORRECT: Use domain list
      person_seniorities: ['c_suite', 'founder', 'vp', 'director'], // Target key decision makers
      per_page: maxContacts,
      page: 1
    }

    return this.makeRequest('/mixed_people/search', contactParams)
  }

  // Enhanced company search with proper contact enrichment
  async searchCompaniesWithContacts(
    searchCriteria: any, 
    onProgress?: (step: string, current: number, total: number) => void
  ) {
    // Step 1: Search companies
    onProgress?.('🔍 Searching companies...', 0, 3)
    
    const apolloParams = this.buildSearchParams(searchCriteria)
    const companyResponse = await this.searchCompanies(apolloParams)
    const companies = companyResponse.organizations || []
    
    console.log(`Found ${companies.length} companies`)
    
    if (companies.length === 0) {
      return {
        companies: [],
        totalCompanies: 0,
        totalContacts: 0,
        pagination: companyResponse.pagination
      }
    }

    onProgress?.('👥 Finding key contacts...', 1, 3)

    // Step 2: Enrich with contacts using domain-based search
    const companiesWithContacts = []
    let totalContactsFound = 0
    
    for (let i = 0; i < companies.length; i++) {
      const company = companies[i]
      
      try {
        // Update progress every few companies
        if (i % 3 === 0) {
          onProgress?.(`👥 Finding contacts for ${company.name}... (${i + 1}/${companies.length})`, 1, 3)
        }

        // Extract domain from website_url or use primary_domain
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
          console.log(`Searching contacts for ${company.name} using domain: ${domain}`)
          
          const contactResponse = await this.getCompanyContactsByDomain(domain, 3)
          contacts = (contactResponse.people || []).map(person => ({
            name: person.name || `${person.first_name} ${person.last_name}`,
            title: person.title || 'Unknown Title',
            email: person.email?.includes('email_not_unlocked') ? undefined : person.email,
            role_category: this.categorizeRole(person.title, person.seniority),
            linkedin: person.linkedin_url,
            seniority: person.seniority,
            departments: person.departments,
            photo_url: person.photo_url
          }))
          
          totalContactsFound += contacts.length
          console.log(`Found ${contacts.length} contacts for ${company.name}`)
        } else {
          console.warn(`No domain found for ${company.name}`)
        }

        companiesWithContacts.push({
          ...company,
          contacts: contacts,
          domain: domain
        })

        // Add small delay to avoid rate limiting
        if (i < companies.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 100))
        }
        
      } catch (error) {
        console.error(`Failed to get contacts for ${company.name}:`, error)
        companiesWithContacts.push({
          ...company,
          contacts: [],
          domain: company.primary_domain || 'unknown'
        })
      }
    }

    onProgress?.('🧠 Analyzing and scoring results...', 2, 3)

    // Step 3: Calculate AI scores
    const finalCompanies = companiesWithContacts.map(company => ({
      ...company,
      ai_score: this.calculateAIScore(company, searchCriteria)
    }))

    onProgress?.('✅ Complete!', 3, 3)

    console.log(`Final results: ${finalCompanies.length} companies, ${totalContactsFound} total contacts`)

    return {
      companies: finalCompanies,
      totalCompanies: finalCompanies.length,
      totalContacts: totalContactsFound,
      pagination: companyResponse.pagination
    }
  }

  private calculateAIScore(company: any, searchCriteria: any): number {
    let score = 70 // Base score
    
    // Boost for having contacts
    if (company.contacts?.length > 0) score += 15
    if (company.contacts?.length >= 3) score += 5
    
    // Boost for C-suite contacts
    const execContacts = company.contacts?.filter((c: any) => c.role_category === 'Executive').length || 0
    if (execContacts > 0) score += 10
    
    // Boost for company maturity
    if (company.founded_year && company.founded_year < 2020) score += 5
    if (company.publicly_traded_symbol) score += 10
    
    // Boost for size indicators
    if (company.estimated_num_employees > 50) score += 5
    if (company.organization_revenue > 10000000) score += 5
    
    // Industry relevance boost
    if (searchCriteria.industries?.some((industry: string) => 
      company.name?.toLowerCase().includes(industry.toLowerCase())
    )) {
      score += 10
    }
    
    return Math.min(Math.max(score, 60), 100)
  }

  private categorizeRole(title?: string, seniority?: string): string {
    if (!title && !seniority) return 'Employee'
    
    if (seniority === 'founder' || seniority === 'c_suite') return 'Executive'
    if (seniority === 'vp') return 'Executive'
    if (seniority === 'director') return 'Management'
    
    const lowerTitle = (title || '').toLowerCase()
    if (lowerTitle.includes('founder') || lowerTitle.includes('ceo') || lowerTitle.includes('cto')) return 'Executive'
    if (lowerTitle.includes('vp') || lowerTitle.includes('chief')) return 'Executive'
    if (lowerTitle.includes('director') || lowerTitle.includes('head')) return 'Management'
    if (lowerTitle.includes('manager')) return 'Management'
    
    return 'Employee'
  }

  buildSearchParams(searchCriteria: any): ApolloCompanySearchParams {
    const params: ApolloCompanySearchParams = {
      page: 1,
      per_page: Math.min(searchCriteria.maxResults || 25, 50) // Limit for contact processing
    }

    if (searchCriteria.locations && searchCriteria.locations.length > 0) {
      params.organization_locations = searchCriteria.locations
    }

    if (searchCriteria.industries && searchCriteria.industries.length > 0) {
      const industryKeywords = []
      
      searchCriteria.industries.forEach((industry: string) => {
        switch (industry.toLowerCase()) {
          case 'biotechnology':
            industryKeywords.push('biotech', 'biotechnology', 'life sciences')
            break
          case 'pharmaceuticals':
            industryKeywords.push('pharma', 'pharmaceutical', 'drug development')
            break
          case 'medical devices':
            industryKeywords.push('medtech', 'medical device')
            break
          case 'digital health':
            industryKeywords.push('healthtech', 'digital health')
            break
          default:
            industryKeywords.push(industry.toLowerCase())
        }
      })
      
      params.q_organization_keyword_tags = [...new Set(industryKeywords)].slice(0, 3)
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
