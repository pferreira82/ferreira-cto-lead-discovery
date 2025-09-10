export interface SaveableCompany {
  id: string
  company: string
  website?: string
  industry: string
  fundingStage?: string
  description: string
  location: string
  contacts?: SaveableContact[]
  [key: string]: any
}

export interface SaveableContact {
  name: string
  title: string
  email?: string
  role_category: string
  linkedin?: string
  company_id?: string
  company_name?: string
  company_domain?: string
  [key: string]: any
}

export interface SaveableVC {
  name: string
  title: string
  email?: string
  role_category: string
  linkedin?: string
  organization: string
  organization_domain?: string
  [key: string]: any
}

export class SaveManager {
  private baseUrl: string

  constructor(baseUrl?: string) {
    this.baseUrl = baseUrl || (typeof window !== 'undefined' ? window.location.origin : 'http://localhost:3000')
  }

  async saveCompanies(companies: SaveableCompany[]): Promise<{ success: boolean; message: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/saved-companies`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ companies })
      })
      
      const result = await response.json()
      return result
    } catch (error) {
      return { success: false, message: `Failed to save companies: ${error}` }
    }
  }

  async saveContacts(contacts: SaveableContact[]): Promise<{ success: boolean; message: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/saved-contacts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contacts })
      })
      
      const result = await response.json()
      return result
    } catch (error) {
      return { success: false, message: `Failed to save contacts: ${error}` }
    }
  }

  async saveVCs(vcs: SaveableVC[]): Promise<{ success: boolean; message: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/saved-vcs`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ vcs })
      })
      
      const result = await response.json()
      return result
    } catch (error) {
      return { success: false, message: `Failed to save VCs: ${error}` }
    }
  }

  async bulkSave(data: {
    companies?: SaveableCompany[]
    contacts?: SaveableContact[]
    vcs?: SaveableVC[]
  }): Promise<{ success: boolean; message: string; results?: any }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/bulk-save`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      })
      
      const result = await response.json()
      return result
    } catch (error) {
      return { success: false, message: `Bulk save failed: ${error}` }
    }
  }

  static extractCompaniesFromResults(searchResults: any[]): SaveableCompany[] {
    return searchResults.map(result => ({
      id: result.id,
      company: result.company,
      website: result.website,
      industry: result.industry,
      fundingStage: result.fundingStage,
      description: result.description,
      location: result.location,
      full_address: result.full_address,
      totalFunding: result.totalFunding,
      employeeCount: result.employeeCount,
      foundedYear: result.foundedYear,
      ai_score: result.ai_score,
      domain: result.domain,
      contacts: result.contacts || []
    }))
  }

  static extractContactsFromResults(searchResults: any[]): SaveableContact[] {
    const allContacts: SaveableContact[] = []
    
    searchResults.forEach(company => {
      if (company.contacts?.length > 0) {
        const companyContacts = company.contacts.map((contact: any) => ({
          ...contact,
          company_id: company.id,
          company_name: company.company,
          company_domain: company.domain
        }))
        allContacts.push(...companyContacts)
      }
    })
    
    return allContacts
  }

  static extractVCsFromResults(vcResults: any[]): SaveableVC[] {
    return vcResults.map(vc => ({
      name: vc.name,
      title: vc.title,
      email: vc.email,
      role_category: vc.role_category || 'Investor/VC',
      linkedin: vc.linkedin,
      organization: vc.organization,
      organization_domain: vc.organization_domain,
      seniority: vc.seniority,
      photo_url: vc.photo_url,
      location: vc.location
    }))
  }
}

export const saveManager = new SaveManager()
