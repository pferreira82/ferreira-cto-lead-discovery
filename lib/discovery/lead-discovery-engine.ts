import { apolloService } from '../apollo'
import { supabaseAdmin, isSupabaseConfigured } from '../supabase'
import { aiLeadScorer } from './ai-lead-scorer'
import axios from 'axios'
import * as cheerio from 'cheerio'
import puppeteer from 'puppeteer-extra'
import StealthPlugin from 'puppeteer-extra-plugin-stealth'

puppeteer.use(StealthPlugin())

interface DiscoveryParams {
  industries?: string[]
  fundingStages?: string[]
  locations?: string[]
  technologies?: string[]
  companySize?: { min?: number; max?: number }
  fundingAmount?: { min?: number; max?: number }
  excludeExisting?: boolean
  aiScoring?: boolean
  maxResults?: number
}

interface DiscoveredLead {
  company: string
  website?: string
  industry: string
  fundingStage: string
  description: string
  location: string
  totalFunding?: number
  employeeCount?: number
  founded?: number
  contacts: Array<{
    name: string
    title: string
    email?: string
    linkedin?: string
    role_category: string
  }>
  technologies?: string[]
  recentNews?: string[]
  competitors?: string[]
  aiScore?: any
}

class LeadDiscoveryEngine {
  private newsApiKey = process.env.NEWS_API_KEY
  private crunchbaseApiKey = process.env.CRUNCHBASE_API_KEY

  async discoverLeads(params: DiscoveryParams): Promise<DiscoveredLead[]> {
    console.log('🔍 Starting comprehensive lead discovery...')
    
    const discoveredLeads: DiscoveredLead[] = []

    try {
      // 1. Apollo API Discovery
      console.log('📡 Searching Apollo API...')
      const apolloLeads = await this.searchApolloAPI(params)
      discoveredLeads.push(...apolloLeads)

      // 2. Crunchbase Discovery
      console.log('💰 Searching Crunchbase...')
      const crunchbaseLeads = await this.searchCrunchbase(params)
      discoveredLeads.push(...crunchbaseLeads)

      // 3. News-based Discovery
      console.log('📰 Analyzing recent biotech news...')
      const newsLeads = await this.discoverFromNews(params)
      discoveredLeads.push(...newsLeads)

      // 4. Web Scraping Discovery
      console.log('🕷️ Web scraping biotech directories...')
      const scrapedLeads = await this.scrapeLeadSources(params)
      discoveredLeads.push(...scrapedLeads)

      // 5. Deduplication
      console.log('🔄 Removing duplicates...')
      const uniqueLeads = await this.deduplicateLeads(discoveredLeads, params.excludeExisting)

      // 6. AI Scoring
      if (params.aiScoring) {
        console.log('🤖 AI scoring leads...')
        for (const lead of uniqueLeads) {
          lead.aiScore = await aiLeadScorer.scoreLeadRelevance({
            company: lead.company,
            industry: lead.industry,
            fundingStage: lead.fundingStage,
            description: lead.description,
            recentNews: lead.recentNews,
            technologies: lead.technologies,
            teamSize: lead.employeeCount,
            location: lead.location
          })
        }
      }

      // 7. Sort by AI score if available
      const sortedLeads = uniqueLeads.sort((a, b) => {
        if (a.aiScore && b.aiScore) {
          return b.aiScore.overallScore - a.aiScore.overallScore
        }
        return 0
      })

      return sortedLeads.slice(0, params.maxResults || 100)
    } catch (error) {
      console.error('Lead Discovery Error:', error)
      throw error
    }
  }

  private async searchApolloAPI(params: DiscoveryParams): Promise<DiscoveredLead[]> {
    try {
      const companies = await apolloService.searchCompanies({
        industry: params.industries || ['Biotechnology', 'Pharmaceuticals', 'Healthcare'],
        funding_stage: params.fundingStages || ['Series A', 'Series B', 'Series C']
      })

      const leads: DiscoveredLead[] = []

      for (const company of companies.slice(0, 50)) {
        try {
          // Get contacts for each company
          const contacts = await apolloService.searchContacts({
            company_names: [company.name],
            role_titles: ['CEO', 'CTO', 'Chief Technology Officer', 'VP Technology', 'Head of Technology']
          })

          const lead: DiscoveredLead = {
            company: company.name,
            website: company.website_url,
            industry: company.industry,
            fundingStage: company.funding_stage,
            description: company.short_description || '',
            location: company.location,
            totalFunding: company.total_funding,
            employeeCount: company.estimated_num_employees,
            founded: company.founded_year,
            contacts: contacts.map(contact => ({
              name: `${contact.first_name} ${contact.last_name}`,
              title: contact.title,
              email: contact.email,
              linkedin: contact.linkedin_url,
              role_category: this.categorizeRole(contact.title)
            }))
          }

          leads.push(lead)
        } catch (error) {
          console.error(`Error processing company ${company.name}:`, error)
        }
      }

      return leads
    } catch (error) {
      console.error('Apollo API Error:', error)
      return []
    }
  }

  private async searchCrunchbase(params: DiscoveryParams): Promise<DiscoveredLead[]> {
    if (!this.crunchbaseApiKey) return []

    try {
      const response = await axios.get('https://api.crunchbase.com/api/v4/searches/organizations', {
        headers: {
          'X-cb-user-key': this.crunchbaseApiKey
        },
        params: {
          field_ids: [
            'identifier',
            'name',
            'short_description',
            'website',
            'location_identifiers',
            'categories',
            'funding_stage',
            'funding_total',
            'num_employees_enum'
          ].join(','),
          query: 'biotechnology OR pharmaceutical OR biotech',
          limit: 50
        }
      })

      return response.data.entities.map((entity: any) => ({
        company: entity.properties.name,
        website: entity.properties.website?.value,
        industry: entity.properties.categories?.map((c: any) => c.value).join(', ') || 'Biotechnology',
        fundingStage: entity.properties.funding_stage?.value || 'Unknown',
        description: entity.properties.short_description || '',
        location: entity.properties.location_identifiers?.[0]?.value || '',
        totalFunding: entity.properties.funding_total?.value_usd,
        employeeCount: this.parseEmployeeRange(entity.properties.num_employees_enum?.value),
        contacts: [] // Will be populated later
      }))
    } catch (error) {
      console.error('Crunchbase API Error:', error)
      return []
    }
  }

  private async discoverFromNews(params: DiscoveryParams): Promise<DiscoveredLead[]> {
    if (!this.newsApiKey) return []

    try {
      const newsQueries = [
        'biotechnology funding',
        'biotech series A',
        'pharmaceutical startup',
        'biotech company raises',
        'biotech IPO'
      ]

      const leads: DiscoveredLead[] = []

      for (const query of newsQueries) {
        const response = await axios.get('https://newsapi.org/v2/everything', {
          params: {
            q: query,
            language: 'en',
            sortBy: 'publishedAt',
            pageSize: 20,
            apiKey: this.newsApiKey
          }
        })

        // Extract company names and funding info from news articles
        for (const article of response.data.articles) {
          const extractedLead = await this.extractLeadFromNews(article)
          if (extractedLead) {
            leads.push(extractedLead)
          }
        }
      }

      return leads
    } catch (error) {
      console.error('News API Error:', error)
      return []
    }
  }

  private async scrapeLeadSources(params: DiscoveryParams): Promise<DiscoveredLead[]> {
    const sources = [
      'https://www.crunchbase.com/lists/biotechnology-companies',
      'https://bioworld.com/companies',
      'https://www.biospace.com/companies'
    ]

    const leads: DiscoveredLead[] = []

    try {
      const browser = await puppeteer.launch({ headless: true })
      
      for (const source of sources) {
        try {
          console.log(`Scraping ${source}...`)
          const page = await browser.newPage()
          await page.goto(source, { waitUntil: 'networkidle2' })
          
          const scrapedData = await this.scrapePageForLeads(page)
          leads.push(...scrapedData)
          
          await page.close()
        } catch (error) {
          console.error(`Error scraping ${source}:`, error)
        }
      }

      await browser.close()
    } catch (error) {
      console.error('Web Scraping Error:', error)
    }

    return leads
  }

  private async scrapePageForLeads(page: any): Promise<DiscoveredLead[]> {
    // Generic scraping logic - adapt based on source
    try {
      const companies = await page.evaluate(() => {
        const companyElements = document.querySelectorAll('[data-company], .company-item, .company-card')
        return Array.from(companyElements).map(el => ({
          name: el.querySelector('.company-name, h3, h4')?.textContent?.trim(),
          description: el.querySelector('.description, .summary')?.textContent?.trim(),
          website: el.querySelector('a[href*="http"]')?.href
        })).filter(c => c.name)
      })

      return companies.map(company => ({
        company: company.name,
        website: company.website,
        industry: 'Biotechnology',
        fundingStage: 'Unknown',
        description: company.description || '',
        location: 'Unknown',
        contacts: []
      }))
    } catch (error) {
      console.error('Page Scraping Error:', error)
      return []
    }
  }

  private async extractLeadFromNews(article: any): Promise<DiscoveredLead | null> {
    try {
      const text = `${article.title} ${article.description} ${article.content || ''}`
      
      // Use regex to extract company funding information
      const fundingRegex = /(\w+(?:\s+\w+)*)\s+(?:raised|raises|receives?|secures?)\s+\$?([\d.]+(?:M|million|B|billion))/gi
      const seriesRegex = /(Series\s+[A-Z]|Seed|IPO)/gi
      
      const fundingMatch = fundingRegex.exec(text)
      const seriesMatch = seriesRegex.exec(text)
      
      if (fundingMatch) {
        return {
          company: fundingMatch[1].trim(),
          industry: 'Biotechnology',
          fundingStage: seriesMatch?.[0] || 'Unknown',
          description: article.description || article.title,
          location: 'Unknown',
          recentNews: [article.title],
          contacts: []
        }
      }
      
      return null
    } catch (error) {
      console.error('News Extraction Error:', error)
      return null
    }
  }

  private async deduplicateLeads(leads: DiscoveredLead[], excludeExisting = true): Promise<DiscoveredLead[]> {
    // Remove duplicates by company name
    const uniqueLeads = leads.filter((lead, index, self) =>
      index === self.findIndex(l => l.company.toLowerCase() === lead.company.toLowerCase())
    )

    if (!excludeExisting) return uniqueLeads

    // Check against existing companies in database
    const { data: existingCompanies } = await supabaseAdmin
      .from('companies')
      .select('name')

    const existingNames = new Set(
      existingCompanies?.map(c => c.name.toLowerCase()) || []
    )

    return uniqueLeads.filter(lead => 
      !existingNames.has(lead.company.toLowerCase())
    )
  }

  private categorizeRole(title: string): string {
    const titleLower = title.toLowerCase()
    
    if (titleLower.includes('ceo') || titleLower.includes('founder')) return 'Founder'
    if (titleLower.includes('cto') || titleLower.includes('technology')) return 'Executive'
    if (titleLower.includes('board') || titleLower.includes('director')) return 'Board Member'
    if (titleLower.includes('vp') || titleLower.includes('head')) return 'Executive'
    
    return 'Executive'
  }

  private parseEmployeeRange(range: string): number | undefined {
    if (!range) return undefined
    
    const matches = range.match(/(\d+)-(\d+)/)
    if (matches) {
      return Math.floor((parseInt(matches[1]) + parseInt(matches[2])) / 2)
    }
    
    const single = range.match(/(\d+)/)
    return single ? parseInt(single[1]) : undefined
  }
}

export const leadDiscoveryEngine = new LeadDiscoveryEngine()
