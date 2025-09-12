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
