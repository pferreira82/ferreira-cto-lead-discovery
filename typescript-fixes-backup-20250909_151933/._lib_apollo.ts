import axios from 'axios'

interface ApolloSearchParams {
  role_titles?: string[]
  company_names?: string[]
  organization_locations?: string[]
  industry?: string[]
  funding_stage?: string[]
}

interface ApolloContact {
  id: string
  first_name: string
  last_name: string
  email: string
  title: string
  linkedin_url: string
  organization: {
    name: string
    website_url: string
    industry: string
    funding_stage: string
    location: string
  }
}

class ApolloService {
  private apiKey: string
  private baseUrl = 'https://api.apollo.io/v1'

  constructor() {
    this.apiKey = process.env.APOLLO_API_KEY!
  }

  async searchContacts(params: ApolloSearchParams): Promise<ApolloContact[]> {
    try {
      const response = await axios.post(
        `${this.baseUrl}/mixed_people/search`,
        {
          api_key: this.apiKey,
          q_organization_domains: params.company_names,
          person_titles: params.role_titles || ['CEO', 'CTO', 'Founder', 'VP', 'Director'],
          organization_locations: params.organization_locations,
          organization_industries: params.industry || ['Biotechnology', 'Pharmaceuticals', 'Healthcare'],
          organization_funding_stage: params.funding_stage || ['Series A', 'Series B', 'Series C'],
          page: 1,
          per_page: 100
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Cache-Control': 'no-cache'
          }
        }
      )

      return response.data.people || []
    } catch (error) {
      console.error('Apollo API Error:', error)
      throw error
    }
  }

  async searchCompanies(params: { industry?: string[], funding_stage?: string[] }) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/organizations/search`,
        {
          api_key: this.apiKey,
          organization_industries: params.industry || ['Biotechnology', 'Pharmaceuticals', 'Healthcare'],
          organization_funding_stage: params.funding_stage || ['Series A', 'Series B', 'Series C'],
          page: 1,
          per_page: 100
        }
      )

      return response.data.organizations || []
    } catch (error) {
      console.error('Apollo Company Search Error:', error)
      throw error
    }
  }

  async enrichContact(email: string) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/people/match`,
        {
          api_key: this.apiKey,
          email: email
        }
      )

      return response.data.person
    } catch (error) {
      console.error('Apollo Contact Enrichment Error:', error)
      throw error
    }
  }
}

export const apolloService = new ApolloService()
