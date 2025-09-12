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

interface ApolloOrganizationDetail {
  id: string
  name: string
  website_url?: string
  linkedin_url?: string
  twitter_url?: string
  facebook_url?: string
  founded_year?: number
  logo_url?: string
  primary_domain?: string
  industry?: string
  estimated_num_employees?: number
  keywords?: string[]
  industries?: string[]
  raw_address?: string
  street_address?: string
  city?: string
  state?: string
  postal_code?: string
  country?: string
  short_description?: string
  annual_revenue?: number
  annual_revenue_printed?: string
  total_funding?: number
  total_funding_printed?: string
  latest_funding_round_date?: string
  latest_funding_stage?: string
  funding_events?: Array<{
    id: string
    date: string
    type: string
    investors: string
    amount: string
    currency: string
    news_url?: string
  }>
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

interface ApolloOrganizationDetailResponse {
  organization: ApolloOrganizationDetail
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

  private async makeRequest(endpoint: string, params: any = {}, method: string = 'POST'): Promise<any> {
    const url = `${this.baseUrl}${endpoint}`
    
    const options: RequestInit = {
      method,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Accept': 'application/json',
        'X-Api-Key': this.apiKey
      }
    }

    if (method === 'POST') {
      console.log(`Apollo ${endpoint} Request:`, JSON.stringify(params, null, 2))
      options.body = JSON.stringify(params)
    } else {
      console.log(`Apollo ${endpoint} Request (${method}):`, url)
    }

    try {
      const response = await fetch(url, options)

      if (!response.ok) {
        const errorText = await response.text()
        console.error(`Apollo ${endpoint} Error:`, response.status, errorText)
        throw new Error(`Apollo API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()
      console.log(`Apollo ${endpoint} Response:`, {
        organizations: data.organizations?.length || 0,
        people: data.people?.length || 0,
        organization: data.organization ? 'Found' : 'Not found',
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

  async getOrganizationDetail(organizationId: string): Promise<ApolloOrganizationDetailResponse> {
    return this.makeRequest(`/organizations/${organizationId}`, {}, 'GET')
  }

  async getExecutiveContactsByDomain(domain: string, maxContacts: number = 5): Promise<ApolloContactsResponse> {
    const contactParams: ApolloContactSearchParams = {
      q_organization_domains_list: [domain],
      person_seniorities: ['founder', 'c_suite', 'owner', 'partner'],
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

  // NEW: Pagination method for VCs and investors
  private async getAllVCsWithPagination(
    baseParams: ApolloContactSearchParams,
    maxResults: number,
    onProgress?: (step: string, current: number, total: number) => void
  ): Promise<ApolloPerson[]> {
    const allVCs: ApolloPerson[] = []
    let currentPage = 1
    const resultsPerPage = Math.min(50, maxResults) // Use 50 as max per page to avoid crashes
    
    console.log(`Planning to fetch ${maxResults} VCs using ${resultsPerPage} per page`)

    while (allVCs.length < maxResults) {
      const remainingResults = maxResults - allVCs.length
      const currentPageSize = Math.min(resultsPerPage, remainingResults)
      
      const pageParams = {
        ...baseParams,
        page: currentPage,
        per_page: currentPageSize
      }

      try {
        console.log(`Fetching VC page ${currentPage} with ${currentPageSize} results...`)
        onProgress?.(`💼 Fetching VC page ${currentPage}... (${allVCs.length}/${maxResults} collected)`, 4, 6)
        
        const response = await this.makeRequest('/mixed_people/search', pageParams)
        const pageVCs = response.people || []
        
        console.log(`VC Page ${currentPage}: Got ${pageVCs.length} contacts`)
        
        if (pageVCs.length === 0) {
          console.log(`No more VCs available at page ${currentPage}`)
          break
        }
        
        // Add VCs from this page
        allVCs.push(...pageVCs)
        
        console.log(`Total VCs collected so far: ${allVCs.length}/${maxResults}`)
        
        // Check if we've reached our target or if there are no more pages
        if (allVCs.length >= maxResults) {
          console.log(`Reached VC target of ${maxResults} contacts`)
          break
        }
        
        if (currentPage >= response.pagination.total_pages) {
          console.log(`Reached last VC page (${response.pagination.total_pages})`)
          break
        }
        
        // Move to next page
        currentPage++
        
        // Add delay between page requests to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 300))
        
      } catch (error) {
        console.error(`Error fetching VC page ${currentPage}:`, error)
        
        // If we got some results, continue with what we have
        if (allVCs.length > 0) {
          console.log(`Continuing with ${allVCs.length} VCs despite page ${currentPage} error`)
          break
        } else {
          // If this was the first page and it failed, re-throw the error
          throw error
        }
      }
    }
    
    // Trim to exact number requested
    const finalVCs = allVCs.slice(0, maxResults)
    console.log(`VC pagination complete: Collected ${finalVCs.length} VCs across ${currentPage} pages`)
    
    return finalVCs
  }

  // UPDATED: VC search with pagination and configurable limits
  async searchVCsByLocation(locations: string[], maxResults: number = 100): Promise<ApolloContactsResponse> {
    const contactParams: ApolloContactSearchParams = {
      person_titles: [
        'venture capitalist', 'vc', 'investor', 'partner',
        'managing partner', 'general partner', 'venture partner',
        'investment partner', 'principal', 'associate'
      ],
      person_seniorities: ['partner', 'c_suite', 'director', 'vp'],
      organization_locations: locations,
      per_page: Math.min(50, maxResults), // Will be overridden by pagination
      page: 1
    }

    console.log(`Searching for VCs with pagination - target: ${maxResults} results`)

    // Use pagination for VCs just like companies
    const allVCs = await this.getAllVCsWithPagination(contactParams, maxResults)
    
    return {
      people: allVCs,
      pagination: {
        page: 1,
        per_page: allVCs.length,
        total_entries: allVCs.length,
        total_pages: 1
      }
    }
  }

  // Company pagination method (same as before)
  private async getAllCompaniesWithPagination(
    baseParams: ApolloCompanySearchParams, 
    maxResults: number,
    onProgress?: (step: string, current: number, total: number) => void
  ): Promise<ApolloCompany[]> {
    const allCompanies: ApolloCompany[] = []
    let currentPage = 1
    const resultsPerPage = Math.min(50, maxResults)
    
    console.log(`Planning to fetch ${maxResults} results using ${resultsPerPage} per page across multiple pages`)

    while (allCompanies.length < maxResults) {
      const remainingResults = maxResults - allCompanies.length
      const currentPageSize = Math.min(resultsPerPage, remainingResults)
      
      const pageParams = {
        ...baseParams,
        page: currentPage,
        per_page: currentPageSize
      }

      try {
        console.log(`Fetching page ${currentPage} with ${currentPageSize} results...`)
        onProgress?.(`📥 Fetching page ${currentPage}... (${allCompanies.length}/${maxResults} collected)`, 0, 6)
        
        const response = await this.searchCompanies(pageParams)
        const pageCompanies = response.organizations || []
        
        console.log(`Page ${currentPage}: Got ${pageCompanies.length} companies`)
        
        if (pageCompanies.length === 0) {
          console.log(`No more companies available at page ${currentPage}`)
          break
        }
        
        allCompanies.push(...pageCompanies)
        console.log(`Total collected so far: ${allCompanies.length}/${maxResults}`)
        
        if (allCompanies.length >= maxResults) {
          console.log(`Reached target of ${maxResults} companies`)
          break
        }
        
        if (currentPage >= response.pagination.total_pages) {
          console.log(`Reached last page (${response.pagination.total_pages})`)
          break
        }
        
        currentPage++
        await new Promise(resolve => setTimeout(resolve, 300))
        
      } catch (error) {
        console.error(`Error fetching page ${currentPage}:`, error)
        
        if (allCompanies.length > 0) {
          console.log(`Continuing with ${allCompanies.length} companies despite page ${currentPage} error`)
          break
        } else {
          throw error
        }
      }
    }
    
    const finalCompanies = allCompanies.slice(0, maxResults)
    console.log(`Pagination complete: Collected ${finalCompanies.length} companies across ${currentPage} pages`)
    
    return finalCompanies
  }

  // Get existing data from database for duplicate detection
  async getExistingDataForDuplicateDetection() {
    try {
      const response = await fetch('/api/discovery/get-existing-data', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      })

      if (response.ok) {
        const data = await response.json()
        return {
          existingCompanyIds: new Set(data.companies.map((c: any) => c.apollo_id).filter(Boolean)),
          existingContactIds: new Set(data.contacts.map((c: any) => c.apollo_id).filter(Boolean)),
          existingCompanyNames: new Set(data.companies.map((c: any) => c.name.toLowerCase())),
          existingContactEmails: new Set(data.contacts.map((c: any) => c.email).filter(Boolean))
        }
      } else {
        console.warn('Could not fetch existing data, proceeding without duplicate detection')
        return {
          existingCompanyIds: new Set(),
          existingContactIds: new Set(),
          existingCompanyNames: new Set(),
          existingContactEmails: new Set()
        }
      }
    } catch (error) {
      console.warn('Error fetching existing data for duplicate detection:', error)
      return {
        existingCompanyIds: new Set(),
        existingContactIds: new Set(),
        existingCompanyNames: new Set(),
        existingContactEmails: new Set()
      }
    }
  }

  // Main search method with both company and VC pagination
  async searchCompaniesWithExecutives(
    searchCriteria: any, 
    onProgress?: (step: string, current: number, total: number) => void
  ) {
    onProgress?.('🔍 Searching companies with pagination...', 0, 6)
    
    const apolloParams = this.buildSearchParams(searchCriteria)
    console.log('Company search params:', apolloParams)
    
    // Get all companies using pagination
    const allCompanies = await this.getAllCompaniesWithPagination(apolloParams, searchCriteria.maxResults || 25, onProgress)
    
    console.log(`Found ${allCompanies.length} companies total`)
    
    if (allCompanies.length === 0) {
      return {
        companies: [],
        totalCompanies: 0,
        totalContacts: 0,
        vcContacts: [],
        pagination: { page: 1, per_page: 0, total_entries: 0, total_pages: 0 }
      }
    }

    // Get existing data for duplicate detection
    onProgress?.('🔍 Checking for duplicates...', 1, 6)
    let existingData = {
      existingCompanyIds: new Set(),
      existingContactIds: new Set(), 
      existingCompanyNames: new Set(),
      existingContactEmails: new Set()
    }

    if (searchCriteria.excludeExistingCompanies || searchCriteria.excludeExistingContacts) {
      console.log('Duplicate detection enabled, fetching existing data...')
    }

    onProgress?.('📋 Getting complete company details...', 2, 6)
    
    const detailedCompanies = []
    const processedCompanyIds = new Set()
    
    for (let i = 0; i < allCompanies.length; i++) {
      const basicCompany = allCompanies[i]
      
      if (processedCompanyIds.has(basicCompany.id)) {
        console.log(`Skipping duplicate company ID: ${basicCompany.id} (${basicCompany.name})`)
        continue
      }

      if (searchCriteria.excludeExistingCompanies && 
          existingData.existingCompanyNames.has(basicCompany.name.toLowerCase())) {
        console.log(`Skipping existing company: ${basicCompany.name}`)
        continue
      }

      try {
        if (i % 5 === 0) {
          onProgress?.(`📋 Getting details for ${basicCompany.name}... (${i + 1}/${allCompanies.length})`, 2, 6)
        }

        console.log(`Getting complete details for ${basicCompany.name} (ID: ${basicCompany.id})`)
        const detailResponse = await this.getOrganizationDetail(basicCompany.id)
        const detailedOrg = detailResponse.organization

        const enhancedCompany = {
          ...basicCompany,
          ...detailedOrg,
          original_basic_data: basicCompany
        }

        detailedCompanies.push(enhancedCompany)
        processedCompanyIds.add(basicCompany.id)

        if (i < allCompanies.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 200))
        }

      } catch (error) {
        console.error(`Failed to get details for ${basicCompany.name}:`, error)
        detailedCompanies.push(basicCompany)
        processedCompanyIds.add(basicCompany.id)
      }
    }

    onProgress?.('👥 Finding executive contacts...', 3, 6)

    const companiesWithContacts = []
    let totalContactsFound = 0
    const processedContactIds = new Set()
    
    for (let i = 0; i < detailedCompanies.length; i++) {
      const company = detailedCompanies[i]
      
      try {
        if (i % 3 === 0) {
          onProgress?.(`👥 Finding executives for ${company.name}... (${i + 1}/${detailedCompanies.length})`, 3, 6)
        }

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
          
          const contactResponse = await this.getExecutiveContactsByDomain(domain, 10)
          const rawContacts = contactResponse.people || []
          
          for (const person of rawContacts) {
            if (processedContactIds.has(person.id)) {
              console.log(`Skipping duplicate contact ID: ${person.id} (${person.name})`)
              continue
            }

            if (searchCriteria.excludeExistingContacts && 
                person.email && 
                existingData.existingContactEmails.has(person.email)) {
              console.log(`Skipping existing contact: ${person.email}`)
              continue
            }

            const contact = {
              id: person.id,
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
            }

            contacts.push(contact)
            processedContactIds.add(person.id)
          }
          
          totalContactsFound += contacts.length
          console.log(`Found ${contacts.length} unique executive contacts for ${company.name}`)
        } else {
          console.warn(`No domain found for ${company.name}`)
        }

        const locationInfo = this.extractLocationFromDetailedData(company)
        const fundingInfo = this.extractFundingInfo(company)
        
        const enhancedCompany = {
          ...company,
          contacts: contacts,
          domain: domain,
          location: locationInfo.short,
          full_address: locationInfo.full,
          funding_info: fundingInfo,
          short_description: company.short_description || company.description,
          revenue_info: {
            annual_revenue: company.annual_revenue,
            annual_revenue_printed: company.annual_revenue_printed
          },
          latest_investors: fundingInfo.latest_investors,
          all_investors: this.extractAllInvestors(company.funding_events || [])
        }

        companiesWithContacts.push(enhancedCompany)

        if (i < detailedCompanies.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 150))
        }
        
      } catch (error) {
        console.error(`Failed to get contacts for ${company.name}:`, error)
        const locationInfo = this.extractLocationFromDetailedData(company)
        companiesWithContacts.push({
          ...company,
          contacts: [],
          domain: company.primary_domain || 'unknown',
          location: locationInfo.short,
          full_address: locationInfo.full
        })
      }
    }

    onProgress?.('💼 Finding VCs and investors with pagination...', 4, 6)

    let vcContacts = []
    const processedVCIds = new Set()
    
    if (searchCriteria.includeVCs && searchCriteria.locations?.length > 0) {
      try {
        // FIXED: Make VC limit configurable and use pagination
        const vcLimit = searchCriteria.maxVCs || searchCriteria.maxResults || 100
        console.log(`Searching for up to ${vcLimit} VCs using pagination...`)
        
        const vcResponse = await this.searchVCsByLocation(searchCriteria.locations, vcLimit)
        const rawVCs = vcResponse.people || []
        
        for (const person of rawVCs) {
          if (processedVCIds.has(person.id)) {
            console.log(`Skipping duplicate VC ID: ${person.id} (${person.name})`)
            continue
          }

          if (searchCriteria.excludeExistingContacts && 
              person.email && 
              existingData.existingContactEmails.has(person.email)) {
            console.log(`Skipping existing VC: ${person.email}`)
            continue
          }

          const vc = {
            id: person.id,
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
          }

          vcContacts.push(vc)
          processedVCIds.add(person.id)
        }
        
        console.log(`Found ${vcContacts.length} unique VCs and investors using pagination`)
      } catch (error) {
        console.error('Failed to search VCs:', error)
      }
    }

    onProgress?.('🧠 Analyzing and scoring results...', 5, 6)

    const finalCompanies = companiesWithContacts.map(company => ({
      ...company,
      ai_score: this.calculateEnhancedAIScore(company, searchCriteria)
    }))

    onProgress?.('✅ Complete!', 6, 6)

    const result = {
      companies: finalCompanies,
      totalCompanies: finalCompanies.length,
      totalContacts: totalContactsFound,
      vcContacts: vcContacts,
      pagination: { 
        page: 1, 
        per_page: finalCompanies.length, 
        total_entries: finalCompanies.length, 
        total_pages: 1 
      }
    }

    console.log('Final enhanced results with VC pagination:', {
      companies: result.totalCompanies,
      contacts: result.totalContacts,
      vcs: result.vcContacts.length,
      duplicatesSkipped: {
        companies: processedCompanyIds.size - result.totalCompanies,
        contacts: processedContactIds.size - result.totalContacts,
        vcs: processedVCIds.size - result.vcContacts.length
      }
    })

    return result
  }

  private extractLocationFromDetailedData(company: any): { short: string, full: string } {
    console.log(`\n=== EXTRACTING LOCATION from detailed data for ${company.name} ===`)
    console.log('Detailed location fields:', {
      raw_address: company.raw_address,
      street_address: company.street_address,
      city: company.city,
      state: company.state,
      postal_code: company.postal_code,
      country: company.country
    })

    let shortLocation = 'Unknown'
    let fullLocation = 'Unknown'

    if (company.city || company.state || company.country) {
      const city = company.city || ''
      const state = company.state || ''
      const country = company.country || ''

      if (city && country) {
        shortLocation = `${city}, ${country}`
      } else if (city) {
        shortLocation = city
      } else if (country) {
        shortLocation = country
      }

      if (company.raw_address) {
        fullLocation = company.raw_address
      } else if (company.street_address) {
        const parts = [
          company.street_address,
          city,
          state,
          company.postal_code,
          country
        ].filter(Boolean)
        fullLocation = parts.join(', ')
      } else {
        const parts = [city, state, country].filter(Boolean)
        fullLocation = parts.join(', ')
      }

      console.log(`✅ Using detailed location data - Short: "${shortLocation}", Full: "${fullLocation}"`)
    } else {
      console.log('❌ No detailed location data available, using fallback')
      shortLocation = 'Unknown'
      fullLocation = 'Unknown'
    }

    return { short: shortLocation, full: fullLocation }
  }

  private extractFundingInfo(company: any) {
    const latestEvent = company.funding_events?.[0]
    
    return {
      stage: company.latest_funding_stage,
      amount: company.latest_funding_amount,
      total_funding: company.total_funding,
      total_funding_printed: company.total_funding_printed,
      date: company.latest_funding_round_date,
      latest_investors: latestEvent?.investors || '',
      latest_amount_printed: latestEvent?.amount ? `${latestEvent.currency}${latestEvent.amount}` : undefined
    }
  }

  private extractAllInvestors(fundingEvents: any[]): string[] {
    const allInvestors = new Set<string>()
    
    fundingEvents.forEach(event => {
      if (event.investors) {
        const investors = event.investors.split(',').map((inv: string) => inv.trim())
        investors.forEach(investor => allInvestors.add(investor))
      }
    })
    
    return Array.from(allInvestors)
  }

  private calculateEnhancedAIScore(company: any, searchCriteria: any): number {
    let score = 70

    if (company.contacts?.length > 0) score += 20
    if (company.contacts?.length >= 3) score += 10
    
    const founderContacts = company.contacts?.filter((c: any) => 
      c.role_category === 'Founder' || c.role_category === 'C-Suite'
    ).length || 0
    if (founderContacts > 0) score += 15
    if (founderContacts >= 2) score += 10
    
    if (company.latest_funding_stage && searchCriteria.fundingStages?.includes(company.latest_funding_stage)) {
      score += 15
    }
    
    if (company.latest_funding_round_date) {
      const fundingDate = new Date(company.latest_funding_round_date)
      const now = new Date()
      const monthsAgo = (now.getTime() - fundingDate.getTime()) / (1000 * 60 * 60 * 24 * 30)
      if (monthsAgo <= 12) score += 10
      if (monthsAgo <= 6) score += 5
    }
    
    if (company.founded_year && company.founded_year >= 2015) score += 5
    if (company.publicly_traded_symbol) score += 10
    if (company.total_funding && company.total_funding > 10000000) score += 8
    
    if (company.annual_revenue && company.annual_revenue > 50000000) score += 5
    
    if (company.short_description && company.short_description.length > 200) score += 3
    
    const majorHubs = ['san francisco', 'boston', 'new york', 'london', 'cambridge', 'palo alto', 'silicon valley']
    if (majorHubs.some(hub => company.location?.toLowerCase().includes(hub))) {
      score += 5
    }
    
    return Math.min(Math.max(score, 60), 100)
  }

  private categorizeExecutiveRole(title?: string, seniority?: string): string {
    if (!title && !seniority) return 'Executive'
    
    const lowerTitle = (title || '').toLowerCase()
    
    if (seniority === 'founder' || lowerTitle.includes('founder')) return 'Founder'
    
    if (seniority === 'c_suite' || 
        lowerTitle.includes('ceo') || lowerTitle.includes('chief') ||
        lowerTitle.includes('president') || lowerTitle.includes('chairman')) return 'C-Suite'
    
    if (seniority === 'partner' || seniority === 'owner' ||
        lowerTitle.includes('board') || lowerTitle.includes('partner')) return 'Board/Partner'
    
    if (seniority === 'vp' || lowerTitle.includes('vp') || lowerTitle.includes('vice president')) return 'VP'
    if (seniority === 'director' || lowerTitle.includes('director')) return 'Director'
    
    return 'Executive'
  }

  buildSearchParams(searchCriteria: any): ApolloCompanySearchParams {
    const params: ApolloCompanySearchParams = {
      page: 1,
      per_page: 50
    }

    if (searchCriteria.locations && searchCriteria.locations.length > 0) {
      params.organization_locations = searchCriteria.locations
      console.log('Using locations:', searchCriteria.locations)
    }

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

    if (searchCriteria.fundingStages && searchCriteria.fundingStages.length > 0) {
      const hasEarly = searchCriteria.fundingStages.some((stage: string) => 
        ['Pre-Seed', 'Seed', 'Series A'].includes(stage))
      const hasGrowth = searchCriteria.fundingStages.some((stage: string) => 
        ['Series B', 'Series C', 'Series D+', 'Growth'].includes(stage))

      if (hasEarly && hasGrowth) {
        params.total_funding_range = { min: 1000000, max: 500000000 }
      } else if (hasEarly) {
        params.total_funding_range = { min: 100000, max: 50000000 }
      } else if (hasGrowth) {
        params.total_funding_range = { min: 10000000, max: 1000000000 }
      }
      
      console.log('Using funding range:', params.total_funding_range)
    }

    if (searchCriteria.employeeRanges && searchCriteria.employeeRanges.length > 0) {
      params.organization_num_employees_ranges = searchCriteria.employeeRanges
    }

    console.log(`Apollo search params - using pagination with 50 per page`)
    return params
  }
}

export { ApolloService }

export function formatLocation(address?: { city?: string; state?: string; country?: string }): string {
  if (!address) return 'Unknown'
  const parts = [address.city, address.state, address.country].filter(Boolean)
  return parts.length > 0 ? parts.join(', ') : 'Unknown'
}
