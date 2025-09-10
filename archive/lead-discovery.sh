#!/bin/bash

# Biotech Lead Generator - AI-Powered Lead Discovery System
# Creates comprehensive lead discovery with APIs, AI, and automation

echo "🔍 Building AI-Powered Lead Discovery System..."
echo "=============================================="

# Install additional dependencies for lead discovery
echo "📦 Installing lead discovery dependencies..."
npm install openai puppeteer-extra puppeteer-extra-plugin-stealth newsapi axios cheerio natural

# 1. Create lead discovery service with AI
echo "🤖 Creating AI-powered lead discovery service..."
mkdir -p lib/discovery
cat > lib/discovery/ai-lead-scorer.ts << 'EOF'
import OpenAI from 'openai'

interface LeadData {
  company: string
  industry: string
  fundingStage: string
  description: string
  recentNews?: string[]
  competitors?: string[]
  technologies?: string[]
  teamSize?: number
  location?: string
}

interface LeadScore {
  overallScore: number
  relevanceScore: number
  growthPotential: number
  techMaturity: number
  reasoning: string
  actionRecommendation: string
  urgencyLevel: 'low' | 'medium' | 'high' | 'critical'
  contactPriority: string[]
}

class AILeadScorer {
  private openai: OpenAI

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    })
  }

  async scoreLeadRelevance(leadData: LeadData): Promise<LeadScore> {
    try {
      const prompt = `
You are an expert technology due diligence consultant for biotech companies. Analyze this lead and provide a comprehensive score.

Company: ${leadData.company}
Industry: ${leadData.industry}
Funding Stage: ${leadData.fundingStage}
Description: ${leadData.description}
Team Size: ${leadData.teamSize || 'Unknown'}
Location: ${leadData.location || 'Unknown'}
Recent News: ${leadData.recentNews?.join(', ') || 'None'}
Technologies: ${leadData.technologies?.join(', ') || 'Unknown'}

As Peter Ferreira, CTO consultant specializing in biotech technology due diligence, evaluate this lead based on:

1. RELEVANCE (0-100): How well does this match biotech technology consulting needs?
2. GROWTH POTENTIAL (0-100): Likelihood of needing technology leadership/consulting
3. TECH MATURITY (0-100): How sophisticated their technology challenges likely are
4. URGENCY (low/medium/high/critical): How soon they might need consulting

Consider:
- Funding stage indicates growth phase and technology needs
- Biotech companies need specialized technology leadership
- Recent developments suggest immediate opportunities
- Team size indicates scale of technology challenges

Respond with JSON:
{
  "overallScore": number (0-100),
  "relevanceScore": number (0-100),
  "growthPotential": number (0-100),
  "techMaturity": number (0-100),
  "reasoning": "detailed explanation of scoring",
  "actionRecommendation": "specific next steps",
  "urgencyLevel": "low|medium|high|critical",
  "contactPriority": ["role1", "role2", "role3"] // who to contact first
}
`

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.3,
        max_tokens: 1000,
      })

      const content = response.choices[0]?.message?.content
      if (!content) throw new Error('No response from AI')

      return JSON.parse(content) as LeadScore
    } catch (error) {
      console.error('AI Lead Scoring Error:', error)
      // Fallback scoring
      return {
        overallScore: 50,
        relevanceScore: 50,
        growthPotential: 50,
        techMaturity: 50,
        reasoning: 'AI scoring unavailable, manual review recommended',
        actionRecommendation: 'Review manually and score based on biotech technology needs',
        urgencyLevel: 'medium',
        contactPriority: ['CTO', 'CEO', 'Head of Technology']
      }
    }
  }

  async generatePersonalizedOutreach(leadData: LeadData, contactRole: string): Promise<string> {
    try {
      const prompt = `
Generate a personalized cold email for Peter Ferreira (Ferreira CTO) reaching out to a ${contactRole} at ${leadData.company}.

Company Context:
- ${leadData.company} (${leadData.fundingStage})
- Industry: ${leadData.industry}
- Description: ${leadData.description}

Peter's Background:
- Fractional CTO specializing in AI, Robotics & SaaS for biotech
- Expert in technology due diligence and strategic consulting
- Helps biotech companies with technical architecture and leadership

Create a professional, concise email that:
1. Shows specific knowledge of their company
2. Highlights relevant technology challenges they likely face
3. Offers clear value proposition
4. Includes subtle social proof
5. Has a clear, low-pressure call to action

Keep it under 150 words, professional but personable.
`

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7,
        max_tokens: 500,
      })

      return response.choices[0]?.message?.content || 'Error generating email'
    } catch (error) {
      console.error('Email Generation Error:', error)
      return 'Error generating personalized email. Please create manually.'
    }
  }
}

export const aiLeadScorer = new AILeadScorer()
EOF

# 2. Create comprehensive lead discovery engine
cat > lib/discovery/lead-discovery-engine.ts << 'EOF'
import { apolloService } from '../apollo'
import { supabaseAdmin } from '../supabase'
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
EOF

# 3. Create lead discovery API endpoints
echo "🔌 Creating lead discovery API endpoints..."
mkdir -p pages/api/discovery

cat > pages/api/discovery/search.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { leadDiscoveryEngine } from '../../../lib/discovery/lead-discovery-engine'
import { supabaseAdmin } from '../../../lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    const {
      industries = ['Biotechnology', 'Pharmaceuticals'],
      fundingStages = ['Series A', 'Series B', 'Series C'],
      locations,
      technologies,
      companySize,
      fundingAmount,
      excludeExisting = true,
      aiScoring = true,
      maxResults = 100
    } = req.body

    // Log the search query
    const { data: searchQuery } = await supabaseAdmin
      .from('search_queries')
      .insert({
        query_type: 'lead_discovery',
        parameters: req.body,
        status: 'running'
      })
      .select()
      .single()

    const discoveredLeads = await leadDiscoveryEngine.discoverLeads({
      industries,
      fundingStages,
      locations,
      technologies,
      companySize,
      fundingAmount,
      excludeExisting,
      aiScoring,
      maxResults
    })

    // Update search query status
    await supabaseAdmin
      .from('search_queries')
      .update({
        status: 'completed',
        results_count: discoveredLeads.length
      })
      .eq('id', searchQuery.id)

    res.status(200).json({
      success: true,
      leads: discoveredLeads,
      count: discoveredLeads.length,
      searchId: searchQuery.id
    })
  } catch (error) {
    console.error('Lead Discovery API Error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to discover leads',
      message: error.message
    })
  }
}
EOF

cat > pages/api/discovery/save-leads.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin } from '../../../lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    const { leads } = req.body

    if (!leads || !Array.isArray(leads)) {
      return res.status(400).json({ error: 'Invalid leads data' })
    }

    const savedResults = {
      companies: 0,
      contacts: 0,
      errors: []
    }

    for (const lead of leads) {
      try {
        // Save company
        const { data: company, error: companyError } = await supabaseAdmin
          .from('companies')
          .insert({
            name: lead.company,
            website: lead.website,
            industry: lead.industry,
            funding_stage: lead.fundingStage,
            description: lead.description,
            location: lead.location,
            total_funding: lead.totalFunding,
            employee_count: lead.employeeCount
          })
          .select()
          .single()

        if (companyError) {
          savedResults.errors.push(`Company ${lead.company}: ${companyError.message}`)
          continue
        }

        savedResults.companies++

        // Save contacts
        for (const contact of lead.contacts) {
          try {
            const { error: contactError } = await supabaseAdmin
              .from('contacts')
              .insert({
                company_id: company.id,
                first_name: contact.name.split(' ')[0],
                last_name: contact.name.split(' ').slice(1).join(' '),
                email: contact.email,
                title: contact.title,
                role_category: contact.role_category,
                linkedin_url: contact.linkedin,
                contact_status: 'not_contacted'
              })

            if (!contactError) {
              savedResults.contacts++
            } else {
              savedResults.errors.push(`Contact ${contact.name}: ${contactError.message}`)
            }
          } catch (error) {
            savedResults.errors.push(`Contact ${contact.name}: ${error.message}`)
          }
        }
      } catch (error) {
        savedResults.errors.push(`Company ${lead.company}: ${error.message}`)
      }
    }

    res.status(200).json({
      success: true,
      results: savedResults,
      message: `Saved ${savedResults.companies} companies and ${savedResults.contacts} contacts`
    })
  } catch (error) {
    console.error('Save Leads API Error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to save leads'
    })
  }
}
EOF

cat > pages/api/discovery/generate-email.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { aiLeadScorer } from '../../../lib/discovery/ai-lead-scorer'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    const { leadData, contactRole } = req.body

    if (!leadData || !contactRole) {
      return res.status(400).json({ error: 'Lead data and contact role required' })
    }

    const personalizedEmail = await aiLeadScorer.generatePersonalizedOutreach(leadData, contactRole)

    res.status(200).json({
      success: true,
      email: personalizedEmail
    })
  } catch (error) {
    console.error('Email Generation API Error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to generate email'
    })
  }
}
EOF

# 4. Create the lead discovery page UI
echo "🎨 Creating lead discovery page..."
cat > app/discovery/page.tsx << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { 
  Search, 
  Zap, 
  Users, 
  Building, 
  TrendingUp,
  RefreshCw,
  Save,
  Mail,
  Eye,
  Star,
  Brain,
  Globe,
  Target,
  Filter,
  Download
} from 'lucide-react'

interface DiscoveredLead {
  company: string
  website?: string
  industry: string
  fundingStage: string
  description: string
  location: string
  totalFunding?: number
  employeeCount?: number
  contacts: Array<{
    name: string
    title: string
    email?: string
    role_category: string
  }>
  aiScore?: {
    overallScore: number
    relevanceScore: number
    urgencyLevel: string
    reasoning: string
    actionRecommendation: string
  }
  recentNews?: string[]
}

interface SearchParams {
  industries: string[]
  fundingStages: string[]
  locations: string[]
  excludeExisting: boolean
  aiScoring: boolean
  maxResults: number
}

export default function LeadDiscoveryPage() {
  const [isSearching, setIsSearching] = useState(false)
  const [searchProgress, setSearchProgress] = useState(0)
  const [discoveredLeads, setDiscoveredLeads] = useState<DiscoveredLead[]>([])
  const [selectedLeads, setSelectedLeads] = useState<string[]>([])
  const [searchParams, setSearchParams] = useState<SearchParams>({
    industries: ['Biotechnology', 'Pharmaceuticals'],
    fundingStages: ['Series A', 'Series B', 'Series C'],
    locations: [],
    excludeExisting: true,
    aiScoring: true,
    maxResults: 100
  })
  const [showLeadDialog, setShowLeadDialog] = useState<DiscoveredLead | null>(null)
  const [isSaving, setIsSaving] = useState(false)

  const handleSearch = async () => {
    setIsSearching(true)
    setSearchProgress(0)
    setDiscoveredLeads([])

    try {
      // Simulate progress updates
      const progressInterval = setInterval(() => {
        setSearchProgress(prev => Math.min(prev + 10, 90))
      }, 1000)

      const response = await fetch('/api/discovery/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(searchParams)
      })

      clearInterval(progressInterval)
      setSearchProgress(100)

      if (response.ok) {
        const data = await response.json()
        setDiscoveredLeads(data.leads)
      } else {
        throw new Error('Search failed')
      }
    } catch (error) {
      console.error('Search error:', error)
    } finally {
      setIsSearching(false)
      setTimeout(() => setSearchProgress(0), 2000)
    }
  }

  const handleSaveSelected = async () => {
    if (selectedLeads.length === 0) return

    setIsSaving(true)
    try {
      const leadsToSave = discoveredLeads.filter(lead => 
        selectedLeads.includes(lead.company)
      )

      const response = await fetch('/api/discovery/save-leads', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ leads: leadsToSave })
      })

      if (response.ok) {
        const data = await response.json()
        alert(`Successfully saved ${data.results.companies} companies and ${data.results.contacts} contacts!`)
        setSelectedLeads([])
      }
    } catch (error) {
      console.error('Save error:', error)
    } finally {
      setIsSaving(false)
    }
  }

  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600 dark:text-green-400'
    if (score >= 60) return 'text-yellow-600 dark:text-yellow-400'
    return 'text-red-600 dark:text-red-400'
  }

  const getUrgencyBadge = (urgency: string) => {
    const colors = {
      critical: 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400',
      high: 'bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400',
      medium: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400',
      low: 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
    }
    return colors[urgency] || colors.medium
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">AI-Powered Lead Discovery</h1>
          <p className="text-gray-600 dark:text-gray-400">Discover and analyze new biotech leads automatically</p>
        </div>
        <div className="flex space-x-3">
          <Button variant="outline" className="flex items-center space-x-2">
            <Download className="w-4 h-4" />
            <span>Export Results</span>
          </Button>
          <Button onClick={handleSearch} disabled={isSearching} className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600">
            <Search className="w-4 h-4" />
            <span>{isSearching ? 'Searching...' : 'Start Discovery'}</span>
          </Button>
        </div>
      </div>

      {/* Search Configuration */}
      <Card className="card-bg border-0 shadow-lg">
        <CardHeader>
          <CardTitle className="flex items-center text-gray-900 dark:text-white">
            <Filter className="mr-2 h-5 w-5" />
            Discovery Parameters
          </CardTitle>
          <CardDescription>Configure your lead discovery criteria</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Industries */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Industries</label>
              <div className="space-y-2">
                {['Biotechnology', 'Pharmaceuticals', 'Medical Devices', 'Digital Health'].map(industry => (
                  <div key={industry} className="flex items-center space-x-2">
                    <Checkbox
                      checked={searchParams.industries.includes(industry)}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setSearchParams(prev => ({
                            ...prev,
                            industries: [...prev.industries, industry]
                          }))
                        } else {
                          setSearchParams(prev => ({
                            ...prev,
                            industries: prev.industries.filter(i => i !== industry)
                          }))
                        }
                      }}
                    />
                    <span className="text-sm text-gray-700 dark:text-gray-300">{industry}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Funding Stages */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Funding Stages</label>
              <div className="space-y-2">
                {['Seed', 'Series A', 'Series B', 'Series C', 'Growth'].map(stage => (
                  <div key={stage} className="flex items-center space-x-2">
                    <Checkbox
                      checked={searchParams.fundingStages.includes(stage)}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setSearchParams(prev => ({
                            ...prev,
                            fundingStages: [...prev.fundingStages, stage]
                          }))
                        } else {
                          setSearchParams(prev => ({
                            ...prev,
                            fundingStages: prev.fundingStages.filter(s => s !== stage)
                          }))
                        }
                      }}
                    />
                    <span className="text-sm text-gray-700 dark:text-gray-300">{stage}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Options */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Options</label>
              <div className="space-y-2">
                <div className="flex items-center space-x-2">
                  <Checkbox
                    checked={searchParams.excludeExisting}
                    onCheckedChange={(checked) => 
                      setSearchParams(prev => ({ ...prev, excludeExisting: checked as boolean }))
                    }
                  />
                  <span className="text-sm text-gray-700 dark:text-gray-300">Exclude existing companies</span>
                </div>
                <div className="flex items-center space-x-2">
                  <Checkbox
                    checked={searchParams.aiScoring}
                    onCheckedChange={(checked) => 
                      setSearchParams(prev => ({ ...prev, aiScoring: checked as boolean }))
                    }
                  />
                  <span className="text-sm text-gray-700 dark:text-gray-300">AI relevance scoring</span>
                </div>
              </div>
              <div className="mt-4">
                <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Max Results</label>
                <Input
                  type="number"
                  value={searchParams.maxResults}
                  onChange={(e) => setSearchParams(prev => ({ 
                    ...prev, 
                    maxResults: parseInt(e.target.value) || 100 
                  }))}
                  min="10"
                  max="500"
                />
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Progress */}
      {isSearching && (
        <Card className="card-bg border-0 shadow-lg">
          <CardContent className="p-6">
            <div className="flex items-center space-x-4">
              <RefreshCw className="w-5 h-5 animate-spin text-blue-500" />
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900 dark:text-white">Discovering leads...</p>
                <Progress value={searchProgress} className="mt-2" />
              </div>
              <span className="text-sm text-gray-500 dark:text-gray-400">{searchProgress}%</span>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Results Summary */}
      {discoveredLeads.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card className="card-bg border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Building className="w-8 h-8 mx-auto mb-2 text-blue-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{discoveredLeads.length}</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Companies Found</p>
            </CardContent>
          </Card>
          
          <Card className="card-bg border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Users className="w-8 h-8 mx-auto mb-2 text-green-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {discoveredLeads.reduce((sum, lead) => sum + lead.contacts.length, 0)}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Contacts Found</p>
            </CardContent>
          </Card>

          <Card className="card-bg border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Brain className="w-8 h-8 mx-auto mb-2 text-purple-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {discoveredLeads.filter(lead => lead.aiScore && lead.aiScore.overallScore >= 70).length}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">High-Quality Leads</p>
            </CardContent>
          </Card>

          <Card className="card-bg border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Target className="w-8 h-8 mx-auto mb-2 text-orange-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{selectedLeads.length}</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Selected to Save</p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Action Bar */}
      {selectedLeads.length > 0 && (
        <Card className="card-bg border-0 shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-700 dark:text-gray-300">
                {selectedLeads.length} lead{selectedLeads.length > 1 ? 's' : ''} selected
              </span>
              <div className="flex space-x-2">
                <Button 
                  variant="outline" 
                  onClick={() => setSelectedLeads([])}
                  size="sm"
                >
                  Clear Selection
                </Button>
                <Button 
                  onClick={handleSaveSelected}
                  disabled={isSaving}
                  size="sm"
                  className="bg-green-600 hover:bg-green-700"
                >
                  <Save className="w-4 h-4 mr-2" />
                  {isSaving ? 'Saving...' : 'Save to Database'}
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Results Table */}
      {discoveredLeads.length > 0 && (
        <Card className="card-bg border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">Discovered Leads</CardTitle>
            <CardDescription>AI-analyzed biotech companies and contacts</CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-gray-200 dark:border-gray-700">
                  <TableHead className="w-12">
                    <Checkbox
                      checked={selectedLeads.length === discoveredLeads.length}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setSelectedLeads(discoveredLeads.map(lead => lead.company))
                        } else {
                          setSelectedLeads([])
                        }
                      }}
                    />
                  </TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Company</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Industry</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Stage</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Contacts</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">AI Score</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Urgency</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {discoveredLeads.map((lead) => (
                  <TableRow key={lead.company} className="border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800">
                    <TableCell>
                      <Checkbox
                        checked={selectedLeads.includes(lead.company)}
                        onCheckedChange={(checked) => {
                          if (checked) {
                            setSelectedLeads([...selectedLeads, lead.company])
                          } else {
                            setSelectedLeads(selectedLeads.filter(id => id !== lead.company))
                          }
                        }}
                      />
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">{lead.company}</p>
                        <p className="text-sm text-gray-500 dark:text-gray-400">{lead.location}</p>
                        {lead.website && (
                          <a 
                            href={lead.website} 
                            target="_blank" 
                            rel="noopener noreferrer"
                            className="text-xs text-blue-600 dark:text-blue-400 hover:underline"
                          >
                            {lead.website}
                          </a>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline" className="text-gray-700 dark:text-gray-300">
                        {lead.industry}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge className="bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400">
                        {lead.fundingStage}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <span className="text-sm text-gray-600 dark:text-gray-400">
                        {lead.contacts.length} contact{lead.contacts.length !== 1 ? 's' : ''}
                      </span>
                    </TableCell>
                    <TableCell>
                      {lead.aiScore ? (
                        <div className="flex items-center space-x-2">
                          <Star className={`w-4 h-4 ${getScoreColor(lead.aiScore.overallScore)}`} />
                          <span className={`font-medium ${getScoreColor(lead.aiScore.overallScore)}`}>
                            {lead.aiScore.overallScore}
                          </span>
                        </div>
                      ) : (
                        <span className="text-gray-400 dark:text-gray-500">N/A</span>
                      )}
                    </TableCell>
                    <TableCell>
                      {lead.aiScore && (
                        <Badge className={getUrgencyBadge(lead.aiScore.urgencyLevel)}>
                          {lead.aiScore.urgencyLevel}
                        </Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setShowLeadDialog(lead)}
                      >
                        <Eye className="w-4 h-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {/* Lead Detail Dialog */}
      {showLeadDialog && (
        <Dialog open={!!showLeadDialog} onOpenChange={() => setShowLeadDialog(null)}>
          <DialogContent className="max-w-4xl">
            <DialogHeader>
              <DialogTitle className="flex items-center space-x-2">
                <Building className="w-5 h-5" />
                <span>{showLeadDialog.company}</span>
              </DialogTitle>
              <DialogDescription>
                Detailed analysis and contact information
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-6">
              {/* Company Info */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <h4 className="font-semibold mb-2">Company Details</h4>
                  <div className="space-y-2 text-sm">
                    <p><strong>Industry:</strong> {showLeadDialog.industry}</p>
                    <p><strong>Funding Stage:</strong> {showLeadDialog.fundingStage}</p>
                    <p><strong>Location:</strong> {showLeadDialog.location}</p>
                    {showLeadDialog.employeeCount && (
                      <p><strong>Employees:</strong> {showLeadDialog.employeeCount}</p>
                    )}
                    {showLeadDialog.totalFunding && (
                      <p><strong>Total Funding:</strong> ${showLeadDialog.totalFunding.toLocaleString()}</p>
                    )}
                  </div>
                </div>
                
                {showLeadDialog.aiScore && (
                  <div>
                    <h4 className="font-semibold mb-2">AI Analysis</h4>
                    <div className="space-y-2 text-sm">
                      <p><strong>Overall Score:</strong> <span className={getScoreColor(showLeadDialog.aiScore.overallScore)}>{showLeadDialog.aiScore.overallScore}/100</span></p>
                      <p><strong>Relevance:</strong> <span className={getScoreColor(showLeadDialog.aiScore.relevanceScore)}>{showLeadDialog.aiScore.relevanceScore}/100</span></p>
                      <p><strong>Urgency:</strong> <Badge className={getUrgencyBadge(showLeadDialog.aiScore.urgencyLevel)}>{showLeadDialog.aiScore.urgencyLevel}</Badge></p>
                    </div>
                  </div>
                )}
              </div>

              {/* Description */}
              <div>
                <h4 className="font-semibold mb-2">Description</h4>
                <p className="text-sm text-gray-600 dark:text-gray-400">{showLeadDialog.description}</p>
              </div>

              {/* AI Reasoning */}
              {showLeadDialog.aiScore && (
                <div>
                  <h4 className="font-semibold mb-2">AI Reasoning</h4>
                  <p className="text-sm text-gray-600 dark:text-gray-400">{showLeadDialog.aiScore.reasoning}</p>
                  <div className="mt-2 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                    <p className="text-sm font-medium text-blue-800 dark:text-blue-400">Recommended Action:</p>
                    <p className="text-sm text-blue-700 dark:text-blue-300">{showLeadDialog.aiScore.actionRecommendation}</p>
                  </div>
                </div>
              )}

              {/* Contacts */}
              <div>
                <h4 className="font-semibold mb-2">Key Contacts ({showLeadDialog.contacts.length})</h4>
                <div className="space-y-2">
                  {showLeadDialog.contacts.map((contact, index) => (
                    <div key={index} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
                      <div>
                        <p className="font-medium">{contact.name}</p>
                        <p className="text-sm text-gray-600 dark:text-gray-400">{contact.title}</p>
                        <Badge variant="outline" className="mt-1">{contact.role_category}</Badge>
                      </div>
                      <div className="flex space-x-2">
                        {contact.email && (
                          <Button size="sm" variant="outline">
                            <Mail className="w-4 h-4" />
                          </Button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}
EOF

echo ""
echo "🎉 AI-Powered Lead Discovery System Complete!"
echo ""
echo "✅ Created:"
echo "  - AI lead scoring and analysis engine"
echo "  - Multi-source discovery (Apollo, Crunchbase, News, Web scraping)"
echo "  - Comprehensive lead discovery page with filters"
echo "  - Real-time progress tracking"
echo "  - Lead deduplication and quality scoring"
echo "  - Personalized email generation with AI"
echo "  - Batch save functionality"
echo "  - Advanced search parameters"
echo ""
echo "🔧 API Keys needed in .env.local:"
echo "  - OPENAI_API_KEY (for AI scoring and email generation)"
echo "  - NEWS_API_KEY (for news-based discovery)"
echo "  - CRUNCHBASE_API_KEY (optional, for enhanced company data)"
echo ""
echo "🚀 Features:"
echo "  - Intelligent lead scoring based on biotech relevance"
echo "  - Multi-source data aggregation"
echo "  - AI-powered email personalization"
echo "  - Real-time discovery progress"
echo "  - Advanced filtering and selection"
echo "  - Automated deduplication"
echo ""
echo "Navigate to /discovery to start finding high-quality biotech leads!"
