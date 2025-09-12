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
