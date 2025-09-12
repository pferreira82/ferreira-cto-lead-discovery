#!/bin/bash

echo "Creating Demo Service Files..."
echo "=============================="

# Create demo directory
mkdir -p lib/services/demo

# Create demo data generator
cat > lib/services/demo/demo-data.ts << 'EOF'
// Demo data that mimics real Apollo API responses without making actual calls

interface DemoCompany {
  id: string
  name: string
  website_url?: string
  primary_domain?: string
  industry: string
  location: string
  full_address: string
  description: string
  short_description: string
  ai_score: number
  founded_year?: number
  estimated_num_employees?: number
  total_funding?: number
  latest_funding_stage?: string
  latest_funding_round_date?: string
  contacts: DemoContact[]
  funding_info?: any
  revenue_info?: any
  domain?: string
  logo_url?: string
  latest_investors?: string
  all_investors?: string[]
}

interface DemoContact {
  id: string
  name: string
  first_name: string
  last_name: string
  title: string
  email?: string
  role_category: string
  linkedin_url?: string
  seniority?: string
  location?: string
  photo_url?: string
}

interface DemoVC {
  id: string
  name: string
  title: string
  email?: string
  role_category: string
  linkedin_url?: string
  organization: string
  organization_domain?: string
  location?: string
  photo_url?: string
  seniority?: string
}

export class DemoDataGenerator {
  private static companyNames = [
    'Nexus Therapeutics', 'Bioforge Labs', 'Quantum Biosciences', 'Meridian Health',
    'Catalyst Pharma', 'Genomic Innovations', 'Precision Therapeutics', 'Vitalis Bio',
    'Helix Diagnostics', 'BioVantage Corp', 'Zenith Medicines', 'Apex Biotechnology',
    'Innovate Health Systems', 'BioCatalyst Inc', 'Therapeutic Solutions Group',
    'MedTech Dynamics', 'Cellular Frontiers', 'Regenerative Sciences', 'BioSphere Labs',
    'Molecular Insights Corp', 'HealthTech Innovations', 'Biomedical Ventures',
    'Advanced Therapeutics', 'Precision Medicine Co', 'Genomics Research Institute'
  ]

  private static industries = [
    'Biotechnology', 'Pharmaceuticals', 'Medical Devices', 'Digital Health',
    'Diagnostics', 'Gene Therapy', 'Immunotherapy', 'Drug Discovery'
  ]

  private static locations = [
    'San Francisco, CA', 'Boston, MA', 'Cambridge, MA', 'New York, NY',
    'San Diego, CA', 'Seattle, WA', 'Research Triangle Park, NC', 'Austin, TX',
    'London, UK', 'Basel, Switzerland', 'Copenhagen, Denmark', 'Singapore'
  ]

  private static fundingStages = [
    'Seed', 'Series A', 'Series B', 'Series C', 'Growth'
  ]

  private static executiveTitles = [
    'Chief Executive Officer', 'Chief Technology Officer', 'Chief Scientific Officer',
    'Chief Medical Officer', 'Chief Operating Officer', 'Chief Financial Officer',
    'Vice President of Research', 'Vice President of Development', 'Head of Clinical Affairs',
    'Director of Business Development', 'Co-Founder', 'Founder and CEO'
  ]

  private static vcNames = [
    'Alexandra Chen', 'Michael Rodriguez', 'Sarah Kim', 'David Thompson',
    'Emily Wang', 'James Wilson', 'Lisa Patel', 'Robert Johnson',
    'Anna Kowalski', 'Christopher Lee', 'Maria Garcia', 'Thomas Anderson'
  ]

  private static vcFirms = [
    'Andreessen Horowitz', 'Sequoia Capital', 'Kleiner Perkins', 'Accel Partners',
    'General Catalyst', 'NEA', 'Greylock Partners', 'Bessemer Venture Partners',
    'First Round Capital', 'Insight Partners', 'Battery Ventures', 'Lightspeed Venture Partners'
  ]

  private static vcTitles = [
    'General Partner', 'Managing Partner', 'Venture Partner', 'Principal',
    'Senior Associate', 'Investment Partner', 'Partner'
  ]

  static generateCompanies(count: number, searchCriteria: any): DemoCompany[] {
    const companies: DemoCompany[] = []
    
    for (let i = 0; i < count; i++) {
      const companyName = this.companyNames[i % this.companyNames.length]
      const id = `demo_company_${i + 1}`
      const domain = companyName.toLowerCase().replace(/\s+/g, '').replace(/[^a-z0-9]/g, '') + '.com'
      
      const company: DemoCompany = {
        id,
        name: companyName,
        website_url: `https://${domain}`,
        primary_domain: domain,
        domain,
        industry: this.industries[Math.floor(Math.random() * this.industries.length)],
        location: this.locations[Math.floor(Math.random() * this.locations.length)],
        full_address: this.locations[Math.floor(Math.random() * this.locations.length)],
        description: `${companyName} is a leading ${this.industries[Math.floor(Math.random() * this.industries.length)].toLowerCase()} company focused on developing innovative therapeutic solutions for patients worldwide.`,
        short_description: `Innovative ${this.industries[Math.floor(Math.random() * this.industries.length)].toLowerCase()} company`,
        ai_score: Math.floor(Math.random() * 30) + 70, // 70-100
        founded_year: 2015 + Math.floor(Math.random() * 8), // 2015-2023
        estimated_num_employees: Math.floor(Math.random() * 500) + 10, // 10-510
        total_funding: Math.floor(Math.random() * 100000000) + 5000000, // 5M-105M
        latest_funding_stage: this.fundingStages[Math.floor(Math.random() * this.fundingStages.length)],
        latest_funding_round_date: this.getRandomDate(2022, 2024),
        contacts: this.generateContacts(Math.floor(Math.random() * 4) + 1, id), // 1-4 contacts
        funding_info: {
          stage: this.fundingStages[Math.floor(Math.random() * this.fundingStages.length)],
          total_funding: Math.floor(Math.random() * 100000000) + 5000000,
          total_funding_printed: '$' + (Math.floor(Math.random() * 100) + 5) + 'M',
          latest_investors: 'Demo Venture Partners, Innovation Capital'
        },
        revenue_info: {
          annual_revenue: Math.floor(Math.random() * 50000000) + 1000000,
          annual_revenue_printed: '$' + (Math.floor(Math.random() * 50) + 1) + 'M'
        },
        latest_investors: 'Demo Venture Partners, Innovation Capital',
        all_investors: ['Demo Venture Partners', 'Innovation Capital', 'TechStart Fund'],
        logo_url: `https://ui-avatars.com/api/?name=${encodeURIComponent(companyName)}&background=0D8ABC&color=fff&size=64`
      }
      
      companies.push(company)
    }
    
    return companies
  }

  static generateContacts(count: number, companyId: string): DemoContact[] {
    const contacts: DemoContact[] = []
    const firstNames = ['John', 'Sarah', 'Michael', 'Emily', 'David', 'Lisa', 'Robert', 'Anna', 'James', 'Maria']
    const lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez']
    
    for (let i = 0; i < count; i++) {
      const firstName = firstNames[Math.floor(Math.random() * firstNames.length)]
      const lastName = lastNames[Math.floor(Math.random() * lastNames.length)]
      const fullName = `${firstName} ${lastName}`
      const email = `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${companyId.replace('demo_company_', 'company')}.com`
      const title = this.executiveTitles[Math.floor(Math.random() * this.executiveTitles.length)]
      
      const contact: DemoContact = {
        id: `demo_contact_${companyId}_${i + 1}`,
        name: fullName,
        first_name: firstName,
        last_name: lastName,
        title,
        email: Math.random() > 0.3 ? email : undefined, // 70% have emails
        role_category: this.categorizeRole(title),
        linkedin_url: `https://linkedin.com/in/${firstName.toLowerCase()}-${lastName.toLowerCase()}`,
        seniority: ['c_suite', 'founder', 'vp', 'director'][Math.floor(Math.random() * 4)],
        location: this.locations[Math.floor(Math.random() * this.locations.length)],
        photo_url: `https://ui-avatars.com/api/?name=${encodeURIComponent(fullName)}&background=random&size=64`
      }
      
      contacts.push(contact)
    }
    
    return contacts
  }

  static generateVCs(count: number): DemoVC[] {
    const vcs: DemoVC[] = []
    
    for (let i = 0; i < count; i++) {
      const name = this.vcNames[i % this.vcNames.length]
      const firm = this.vcFirms[Math.floor(Math.random() * this.vcFirms.length)]
      const title = this.vcTitles[Math.floor(Math.random() * this.vcTitles.length)]
      const domain = firm.toLowerCase().replace(/\s+/g, '').replace(/[^a-z0-9]/g, '') + '.com'
      
      const vc: DemoVC = {
        id: `demo_vc_${i + 1}`,
        name,
        title: `${title} at ${firm}`,
        email: Math.random() > 0.4 ? `${name.toLowerCase().replace(' ', '.')}@${domain}` : undefined,
        role_category: 'Investor/VC',
        linkedin_url: `https://linkedin.com/in/${name.toLowerCase().replace(' ', '-')}`,
        organization: firm,
        organization_domain: domain,
        location: this.locations[Math.floor(Math.random() * this.locations.length)],
        photo_url: `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=random&size=64`,
        seniority: 'partner'
      }
      
      vcs.push(vc)
    }
    
    return vcs
  }

  private static categorizeRole(title: string): string {
    const lowerTitle = title.toLowerCase()
    
    if (lowerTitle.includes('founder') || lowerTitle.includes('ceo')) return 'Founder'
    if (lowerTitle.includes('chief') || lowerTitle.includes('president')) return 'C-Suite'
    if (lowerTitle.includes('vp') || lowerTitle.includes('vice president')) return 'VP'
    if (lowerTitle.includes('director') || lowerTitle.includes('head')) return 'Director'
    
    return 'Executive'
  }

  private static getRandomDate(startYear: number, endYear: number): string {
    const start = new Date(startYear, 0, 1)
    const end = new Date(endYear, 11, 31)
    const date = new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()))
    return date.toISOString().split('T')[0]
  }
}
EOF

# Create demo Apollo service
cat > lib/services/demo/demo-apollo-service.ts << 'EOF'
import { DemoDataGenerator } from './demo-data'

export class DemoApolloService {
  private isDemoMode: boolean

  constructor(isDemoMode: boolean = false) {
    this.isDemoMode = isDemoMode
  }

  private async simulateApiDelay(minMs: number = 800, maxMs: number = 2000): Promise<void> {
    const delay = Math.floor(Math.random() * (maxMs - minMs)) + minMs
    await new Promise(resolve => setTimeout(resolve, delay))
  }

  async searchCompaniesWithExecutives(
    searchCriteria: any, 
    onProgress?: (step: string, current: number, total: number) => void
  ) {
    if (!this.isDemoMode) {
      throw new Error('DemoApolloService should only be used in demo mode')
    }

    console.log('🎭 DEMO MODE: Generating mock company data instead of calling Apollo API')
    
    const maxResults = Math.min(searchCriteria.maxResults || 25, 25) // Demo limit
    const maxVCs = Math.min(searchCriteria.maxVCs || 50, 50) // Demo VC limit
    
    // Simulate the search process with progress updates
    onProgress?.('🎭 [DEMO] Generating mock companies...', 0, 6)
    await this.simulateApiDelay(500, 1000)
    
    onProgress?.('🎭 [DEMO] Creating fake company details...', 2, 6)
    await this.simulateApiDelay(1000, 1500)
    
    onProgress?.('🎭 [DEMO] Generating mock contacts...', 3, 6)
    await this.simulateApiDelay(800, 1200)
    
    const companies = DemoDataGenerator.generateCompanies(maxResults, searchCriteria)
    
    // Generate VCs if requested
    let vcContacts = []
    if (searchCriteria.includeVCs) {
      onProgress?.('🎭 [DEMO] Creating mock VCs and investors...', 4, 6)
      await this.simulateApiDelay(600, 1000)
      
      vcContacts = DemoDataGenerator.generateVCs(maxVCs)
    }
    
    onProgress?.('🎭 [DEMO] Finalizing mock results...', 5, 6)
    await this.simulateApiDelay(300, 500)
    
    onProgress?.('✅ [DEMO] Complete!', 6, 6)
    
    const totalContacts = companies.reduce((sum, company) => sum + company.contacts.length, 0) + vcContacts.length
    
    const result = {
      companies,
      totalCompanies: companies.length,
      totalContacts,
      vcContacts,
      pagination: {
        page: 1,
        per_page: companies.length,
        total_entries: companies.length,
        total_pages: 1
      }
    }

    console.log('🎭 DEMO MODE: Generated mock results:', {
      companies: result.totalCompanies,
      contacts: result.totalContacts,
      vcs: result.vcContacts.length,
      note: 'This is fake data for demo purposes'
    })

    return result
  }

  async getExistingDataForDuplicateDetection() {
    if (!this.isDemoMode) {
      throw new Error('DemoApolloService should only be used in demo mode')
    }

    console.log('🎭 DEMO MODE: Returning empty duplicate detection data')
    
    return {
      existingCompanyIds: new Set(),
      existingContactIds: new Set(),
      existingCompanyNames: new Set(),
      existingContactEmails: new Set()
    }
  }
}
EOF

# Create main apollo-with-demo service
cat > lib/services/apollo-with-demo.ts << 'EOF'
import { DemoApolloService } from './demo/demo-apollo-service'

// Import the real Apollo service if it exists, otherwise create a placeholder
let ApolloService: any
try {
  const apolloModule = require('./apollo')
  ApolloService = apolloModule.ApolloService
} catch (error) {
  console.warn('Real Apollo service not found, demo mode will be enforced')
  ApolloService = null
}

export class ApolloServiceWithDemo {
  private realService: any = null
  private demoService: DemoApolloService
  private isDemoMode: boolean

  constructor() {
    // Check for demo mode from environment variables or other indicators
    this.isDemoMode = this.checkDemoMode()
    
    if (this.isDemoMode || !ApolloService) {
      console.log('🎭 DEMO MODE ENABLED: Using mock data instead of real Apollo API')
      this.demoService = new DemoApolloService(true)
    } else {
      console.log('🔴 PRODUCTION MODE: Using real Apollo API')
      this.realService = new ApolloService()
    }
  }

  private checkDemoMode(): boolean {
    // Check various indicators for demo mode
    const envDemo = process.env.DEMO_MODE === 'true'
    const envNoApollo = !process.env.APOLLO_API_KEY || process.env.APOLLO_API_KEY === 'demo'
    const urlDemo = typeof window !== 'undefined' && window.location.search.includes('demo=true')
    const localStorageDemo = typeof window !== 'undefined' && localStorage.getItem('demoMode') === 'true'
    
    const isDemo = envDemo || envNoApollo || urlDemo || localStorageDemo || !ApolloService
    
    if (isDemo) {
      console.log('🎭 Demo mode detected via:', {
        envDemo,
        envNoApollo,
        urlDemo,
        localStorageDemo,
        noApolloService: !ApolloService
      })
    }
    
    return isDemo
  }

  getDemoStatus() {
    return {
      isDemoMode: this.isDemoMode,
      reason: this.isDemoMode ? 'Using mock data for demonstration' : 'Using real Apollo API',
      apiKeyStatus: process.env.APOLLO_API_KEY ? 'Present' : 'Missing',
      apolloServiceAvailable: !!ApolloService
    }
  }

  async searchCompaniesWithExecutives(searchCriteria: any, onProgress?: (step: string, current: number, total: number) => void) {
    if (this.isDemoMode || !this.realService) {
      return this.demoService.searchCompaniesWithExecutives(searchCriteria, onProgress)
    } else {
      return this.realService.searchCompaniesWithExecutives(searchCriteria, onProgress)
    }
  }

  async getExistingDataForDuplicateDetection() {
    if (this.isDemoMode || !this.realService) {
      return this.demoService.getExistingDataForDuplicateDetection()
    } else {
      return this.realService.getExistingDataForDuplicateDetection()
    }
  }

  // Proxy other methods to the appropriate service
  async searchCompanies(params: any) {
    if (this.isDemoMode || !this.realService) {
      throw new Error('searchCompanies not available in demo mode')
    }
    return this.realService.searchCompanies(params)
  }

  async getOrganizationDetail(organizationId: string) {
    if (this.isDemoMode || !this.realService) {
      throw new Error('getOrganizationDetail not available in demo mode')
    }
    return this.realService.getOrganizationDetail(organizationId)
  }

  async getExecutiveContactsByDomain(domain: string, maxContacts: number = 5) {
    if (this.isDemoMode || !this.realService) {
      throw new Error('getExecutiveContactsByDomain not available in demo mode')
    }
    return this.realService.getExecutiveContactsByDomain(domain, maxContacts)
  }

  async searchVCsByLocation(locations: string[], maxResults: number = 100) {
    if (this.isDemoMode || !this.realService) {
      throw new Error('searchVCsByLocation not available in demo mode')
    }
    return this.realService.searchVCsByLocation(locations, maxResults)
  }

  buildSearchParams(searchCriteria: any) {
    if (this.isDemoMode || !this.realService) {
      throw new Error('buildSearchParams not available in demo mode')
    }
    return this.realService.buildSearchParams(searchCriteria)
  }
}

// Export singleton instance
export const apolloService = new ApolloServiceWithDemo()

// Also export the demo status for debugging
export const getDemoStatus = () => apolloService.getDemoStatus()
EOF

echo ""
echo "Demo Service Files Created Successfully!"
echo "======================================"
echo ""
echo "Created files:"
echo "✅ lib/services/demo/demo-data.ts"
echo "✅ lib/services/demo/demo-apollo-service.ts" 
echo "✅ lib/services/apollo-with-demo.ts"
echo ""
echo "The import error should now be resolved."
echo "Your discovery page can now import:"
echo "import { apolloService, getDemoStatus } from '@/lib/services/apollo-with-demo'"
echo ""
echo "Next steps:"
echo "1. The files are ready to use"
echo "2. Demo mode will auto-detect if no Apollo API key is present"
echo "3. Your existing demo toggle should continue to work"
echo ""
