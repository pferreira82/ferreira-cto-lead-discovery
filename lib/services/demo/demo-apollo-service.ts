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
