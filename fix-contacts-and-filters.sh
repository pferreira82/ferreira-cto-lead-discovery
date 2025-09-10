#!/bin/bash

echo "Fixing Contact Enrichment and Result Filters"
echo "==========================================="

# Fix Apollo service to use domain-based contact search
echo "Updating Apollo service with correct contact API pattern..."
cat > lib/services/apollo.ts << 'EOF'
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
EOF

# Fix the discovery page to show filters and handle contacts properly
echo "Fixing discovery page to show filters and handle contacts..."
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { 
  Search, 
  Users, 
  Building, 
  RefreshCw,
  Save,
  Filter,
  Download,
  Target,
  Brain,
  Eye,
  Mail,
  Globe,
  MapPin,
  Star,
  MoreVertical,
  Play,
  Database,
  SlidersHorizontal,
  X
} from 'lucide-react'
import { toast } from 'react-hot-toast'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'

interface DiscoveredLead {
  id: string
  company: string
  website?: string
  industry: string
  fundingStage?: string
  description: string
  location: string
  totalFunding?: number
  employeeCount?: number
  foundedYear?: number
  ai_score?: number
  domain?: string
  contacts: Array<{
    name: string
    title: string
    email?: string
    role_category: string
    linkedin?: string
    seniority?: string
    photo_url?: string
  }>
}

interface ResultFilters {
  minScore: number
  maxScore: number
  hasContacts: boolean
  minContacts: number
  majorCitiesOnly: boolean
}

const INDUSTRIES = [
  'Biotechnology', 'Pharmaceuticals', 'Medical Devices', 'Digital Health',
  'Gene Therapy', 'Cell Therapy', 'Diagnostics', 'Genomics',
  'Synthetic Biology', 'Neurotechnology', 'Biomanufacturing'
]

const FUNDING_STAGES = [
  'Pre-Seed', 'Seed', 'Series A', 'Series B', 'Series C', 
  'Series D+', 'Growth', 'Pre-IPO', 'Public', 'Private'
]

const LOCATIONS = [
  'United States', 'Canada', 'United Kingdom', 'Portugal',
  'Germany', 'France', 'Switzerland', 'Netherlands',
  'Sweden', 'Israel', 'Singapore', 'Australia'
]

const MAJOR_CITIES = [
  'San Francisco', 'Boston', 'New York', 'London', 'Cambridge',
  'San Diego', 'Los Angeles', 'Seattle', 'Toronto', 'Berlin'
]

export default function LeadDiscoveryPage() {
  const { isDemoMode, isLoaded } = useDemoMode()
  const { fetchWithDemo } = useDemoAPI()
  
  const [isSearching, setIsSearching] = useState(false)
  const [searchProgress, setSearchProgress] = useState(0)
  const [currentStep, setCurrentStep] = useState('')
  const [discoveredLeads, setDiscoveredLeads] = useState<DiscoveredLead[]>([])
  const [filteredLeads, setFilteredLeads] = useState<DiscoveredLead[]>([])
  const [selectedLead, setSelectedLead] = useState<DiscoveredLead | null>(null)
  const [showLeadDialog, setShowLeadDialog] = useState(false)
  const [showFilters, setShowFilters] = useState(false)
  const [totalContacts, setTotalContacts] = useState(0)
  
  const [searchParams, setSearchParams] = useState({
    industries: ['Biotechnology', 'Pharmaceuticals'],
    fundingStages: ['Series A', 'Series B', 'Series C'],
    locations: ['United States', 'United Kingdom'],
    maxResults: 10 // Reduced for contact processing
  })

  const [resultFilters, setResultFilters] = useState<ResultFilters>({
    minScore: 60,
    maxScore: 100,
    hasContacts: false,
    minContacts: 0,
    majorCitiesOnly: false
  })

  // Apply filters to results
  useEffect(() => {
    let filtered = [...discoveredLeads]

    filtered = filtered.filter(lead => 
      (lead.ai_score || 0) >= resultFilters.minScore && 
      (lead.ai_score || 0) <= resultFilters.maxScore
    )

    if (resultFilters.hasContacts) {
      filtered = filtered.filter(lead => lead.contacts.length > 0)
    }
    if (resultFilters.minContacts > 0) {
      filtered = filtered.filter(lead => lead.contacts.length >= resultFilters.minContacts)
    }

    if (resultFilters.majorCitiesOnly) {
      filtered = filtered.filter(lead =>
        MAJOR_CITIES.some(city => 
          lead.location.toLowerCase().includes(city.toLowerCase())
        )
      )
    }

    setFilteredLeads(filtered)
  }, [discoveredLeads, resultFilters])

  const handleSearch = async () => {
    setIsSearching(true)
    setSearchProgress(0)
    setCurrentStep('Starting search...')
    setDiscoveredLeads([])

    try {
      const response = await fetchWithDemo('/api/discovery/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(searchParams)
      })

      if (response.ok) {
        const data = await response.json()
        setDiscoveredLeads(data.leads || [])
        setTotalContacts(data.totalContacts || 0)
        
        // Show filters after getting results
        if (data.leads?.length > 0) {
          setShowFilters(true)
        }
        
        toast.success(`Found ${data.leads?.length || 0} companies with ${data.totalContacts || 0} contacts!`)
      } else {
        const errorData = await response.json()
        throw new Error(errorData.message || 'Search failed')
      }
    } catch (error) {
      console.error('Search error:', error)
      toast.error(error instanceof Error ? error.message : 'Search failed. Please try again.')
    } finally {
      setIsSearching(false)
      setCurrentStep('')
      setTimeout(() => setSearchProgress(0), 2000)
    }
  }

  const getScoreColor = (score?: number) => {
    if (!score) return 'text-gray-400'
    if (score >= 85) return 'text-green-600'
    if (score >= 75) return 'text-blue-600'
    if (score >= 65) return 'text-yellow-600'
    return 'text-red-600'
  }

  const getScoreBadge = (score?: number) => {
    if (!score) return 'bg-gray-100 text-gray-600'
    if (score >= 85) return 'bg-green-100 text-green-800'
    if (score >= 75) return 'bg-blue-100 text-blue-800'
    if (score >= 65) return 'bg-yellow-100 text-yellow-800'
    return 'bg-red-100 text-red-800'
  }

  if (!isLoaded) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold">Loading...</h1>
          <p className="text-gray-600">Initializing lead discovery system...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">Enhanced Lead Discovery</h1>
          <p className="text-gray-600">Find biotech companies with key decision maker contacts</p>
        </div>
        <div className="flex items-center space-x-4">
          <Badge variant="outline" className={isDemoMode ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'}>
            {isDemoMode ? 'Demo Mode' : 'Production Mode'}
          </Badge>
          <Button 
            onClick={handleSearch} 
            disabled={isSearching} 
            className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600"
          >
            <Search className="w-4 h-4" />
            <span>{isSearching ? 'Searching...' : 'Start Discovery'}</span>
          </Button>
        </div>
      </div>

      {/* Search Configuration */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Filter className="mr-2 h-5 w-5" />
            Search Parameters
          </CardTitle>
          <CardDescription>Configure your lead discovery criteria</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Industries */}
            <div>
              <label className="block text-sm font-medium mb-2">Industries</label>
              <div className="space-y-2 max-h-48 overflow-y-auto border rounded p-2">
                {INDUSTRIES.map(industry => (
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
                    <span className="text-sm">{industry}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Locations */}
            <div>
              <label className="block text-sm font-medium mb-2">
                <Globe className="inline w-4 h-4 mr-1" />
                Locations
              </label>
              <div className="space-y-2 max-h-48 overflow-y-auto border rounded p-2">
                {LOCATIONS.map(location => (
                  <div key={location} className="flex items-center space-x-2">
                    <Checkbox
                      checked={searchParams.locations.includes(location)}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setSearchParams(prev => ({
                            ...prev,
                            locations: [...prev.locations, location]
                          }))
                        } else {
                          setSearchParams(prev => ({
                            ...prev,
                            locations: prev.locations.filter(l => l !== location)
                          }))
                        }
                      }}
                    />
                    <span className="text-sm">{location}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Settings */}
            <div>
              <label className="block text-sm font-medium mb-2">Settings</label>
              <div className="space-y-3">
                <div>
                  <label className="text-sm font-medium">Max Results:</label>
                  <Input
                    type="number"
                    value={searchParams.maxResults}
                    onChange={(e) => setSearchParams(prev => ({ 
                      ...prev, 
                      maxResults: parseInt(e.target.value) || 10 
                    }))}
                    min="5"
                    max="25"
                    className="w-24 mt-1"
                  />
                  <p className="text-xs text-gray-500 mt-1">Fewer results = faster contact enrichment</p>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Progress */}
      {isSearching && (
        <Card>
          <CardContent className="p-6">
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium">{currentStep}</h3>
                <span className="text-sm text-gray-500">{searchProgress}%</span>
              </div>
              <Progress value={searchProgress} className="h-2" />
            </div>
          </CardContent>
        </Card>
      )}

      {/* Result Filters - ALWAYS SHOW if we have results */}
      {discoveredLeads.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <div className="flex items-center">
                <SlidersHorizontal className="mr-2 h-5 w-5" />
                Result Filters
              </div>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setShowFilters(!showFilters)}
              >
                {showFilters ? <X className="w-4 h-4" /> : <SlidersHorizontal className="w-4 h-4" />}
              </Button>
            </CardTitle>
            {showFilters && (
              <CardContent className="pt-4">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  {/* Score Range */}
                  <div>
                    <label className="block text-sm font-medium mb-2">AI Score Range</label>
                    <div className="flex space-x-2">
                      <Input
                        type="number"
                        placeholder="Min"
                        value={resultFilters.minScore}
                        onChange={(e) => setResultFilters(prev => ({
                          ...prev,
                          minScore: parseInt(e.target.value) || 0
                        }))}
                        min="0"
                        max="100"
                        className="w-20"
                      />
                      <Input
                        type="number"
                        placeholder="Max"
                        value={resultFilters.maxScore}
                        onChange={(e) => setResultFilters(prev => ({
                          ...prev,
                          maxScore: parseInt(e.target.value) || 100
                        }))}
                        min="0"
                        max="100"
                        className="w-20"
                      />
                    </div>
                  </div>

                  {/* Contact Filters */}
                  <div>
                    <label className="block text-sm font-medium mb-2">Contact Requirements</label>
                    <div className="space-y-2">
                      <div className="flex items-center space-x-2">
                        <Checkbox
                          checked={resultFilters.hasContacts}
                          onCheckedChange={(checked) => 
                            setResultFilters(prev => ({ ...prev, hasContacts: checked as boolean }))
                          }
                        />
                        <span className="text-sm">Has contacts</span>
                      </div>
                      <Input
                        type="number"
                        placeholder="Min contacts"
                        value={resultFilters.minContacts}
                        onChange={(e) => setResultFilters(prev => ({
                          ...prev,
                          minContacts: parseInt(e.target.value) || 0
                        }))}
                        min="0"
                        className="w-full"
                      />
                    </div>
                  </div>

                  {/* Location Filter */}
                  <div>
                    <label className="block text-sm font-medium mb-2">Location Filter</label>
                    <div className="flex items-center space-x-2">
                      <Checkbox
                        checked={resultFilters.majorCitiesOnly}
                        onCheckedChange={(checked) => 
                          setResultFilters(prev => ({ ...prev, majorCitiesOnly: checked as boolean }))
                        }
                      />
                      <span className="text-sm">Major cities only</span>
                    </div>
                  </div>

                  {/* Quick Actions */}
                  <div>
                    <label className="block text-sm font-medium mb-2">Quick Filters</label>
                    <div className="space-y-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setResultFilters(prev => ({ ...prev, minScore: 80, hasContacts: true }))}
                        className="w-full text-xs"
                      >
                        High Quality Only
                      </Button>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setResultFilters({
                          minScore: 60,
                          maxScore: 100,
                          hasContacts: false,
                          minContacts: 0,
                          majorCitiesOnly: false
                        })}
                        className="w-full text-xs"
                      >
                        Clear Filters
                      </Button>
                    </div>
                  </div>
                </div>
              </CardContent>
            )}
          </CardHeader>
        </Card>
      )}

      {/* Results Stats */}
      {filteredLeads.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
          <Card>
            <CardContent className="p-4 text-center">
              <Target className="w-8 h-8 mx-auto mb-2 text-blue-500" />
              <p className="text-2xl font-bold">{filteredLeads.length}</p>
              <p className="text-sm text-gray-600">Companies</p>
            </CardContent>
          </Card>
          
          <Card>
            <CardContent className="p-4 text-center">
              <Users className="w-8 h-8 mx-auto mb-2 text-green-500" />
              <p className="text-2xl font-bold">
                {filteredLeads.reduce((sum, lead) => sum + lead.contacts.length, 0)}
              </p>
              <p className="text-sm text-gray-600">Key Contacts</p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-4 text-center">
              <Brain className="w-8 h-8 mx-auto mb-2 text-purple-500" />
              <p className="text-2xl font-bold">
                {filteredLeads.filter(lead => (lead.ai_score || 0) >= 80).length}
              </p>
              <p className="text-sm text-gray-600">High Quality</p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-4 text-center">
              <Building className="w-8 h-8 mx-auto mb-2 text-orange-500" />
              <p className="text-2xl font-bold">
                {filteredLeads.filter(lead => lead.contacts.length > 0).length}
              </p>
              <p className="text-sm text-gray-600">With Contacts</p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-4 text-center">
              <Star className="w-8 h-8 mx-auto mb-2 text-yellow-500" />
              <p className="text-2xl font-bold">
                {Math.round(filteredLeads.reduce((sum, lead) => sum + (lead.ai_score || 0), 0) / filteredLeads.length) || 0}
              </p>
              <p className="text-sm text-gray-600">Avg Score</p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Results Table */}
      {filteredLeads.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Discovery Results ({filteredLeads.length})</CardTitle>
            <CardDescription>Companies with key decision maker contacts</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="p-3 text-left font-medium">Company</th>
                    <th className="p-3 text-left font-medium">Industry</th>
                    <th className="p-3 text-left font-medium">Location</th>
                    <th className="p-3 text-left font-medium">Contacts</th>
                    <th className="p-3 text-left font-medium">AI Score</th>
                    <th className="w-12 p-3"></th>
                  </tr>
                </thead>
                <tbody>
                  {filteredLeads.map((lead) => (
                    <tr key={lead.id} className="border-b hover:bg-gray-50">
                      <td className="p-3">
                        <div>
                          <p className="font-medium">{lead.company}</p>
                          {lead.website && (
                            <a href={lead.website} target="_blank" rel="noopener noreferrer" className="text-xs text-blue-600 hover:underline">
                              {lead.website.replace('https://', '')}
                            </a>
                          )}
                          {lead.domain && (
                            <p className="text-xs text-gray-500">Domain: {lead.domain}</p>
                          )}
                        </div>
                      </td>
                      <td className="p-3">
                        <span className="text-sm">{lead.industry}</span>
                      </td>
                      <td className="p-3">
                        <div className="flex items-center text-sm text-gray-600">
                          <MapPin className="w-3 h-3 mr-1" />
                          <span className="truncate max-w-[150px]">{lead.location}</span>
                        </div>
                      </td>
                      <td className="p-3">
                        <div className="flex items-center space-x-1">
                          <Users className="w-3 h-3 text-gray-400" />
                          <span className="text-sm font-medium">{lead.contacts.length}</span>
                          {lead.contacts.length > 0 && (
                            <Badge variant="outline" className="text-xs px-1">
                              {lead.contacts.filter(c => c.role_category === 'Executive').length} exec
                            </Badge>
                          )}
                        </div>
                      </td>
                      <td className="p-3">
                        {lead.ai_score ? (
                          <Badge className={`${getScoreBadge(lead.ai_score)} font-medium`}>
                            {lead.ai_score}
                          </Badge>
                        ) : (
                          <span className="text-gray-400">N/A</span>
                        )}
                      </td>
                      <td className="p-3">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => {
                            setSelectedLead(lead)
                            setShowLeadDialog(true)
                          }}
                        >
                          <Eye className="w-4 h-4" />
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Empty State */}
      {!isSearching && discoveredLeads.length === 0 && (
        <Card>
          <CardContent className="p-12 text-center">
            <Search className="w-16 h-16 mx-auto mb-4 text-gray-400" />
            <h3 className="text-lg font-semibold mb-2">Ready for Enhanced Discovery</h3>
            <p className="text-gray-600 mb-4">
              Find biotech companies with key decision maker contacts
            </p>
            <Button onClick={handleSearch} className="bg-gradient-to-r from-blue-500 to-purple-600">
              <Search className="w-4 h-4 mr-2" />
              Start Discovery
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Lead Detail Dialog */}
      {showLeadDialog && selectedLead && (
        <Dialog open={showLeadDialog} onOpenChange={setShowLeadDialog}>
          <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle className="flex items-center space-x-2">
                <Building className="w-5 h-5" />
                <span>{selectedLead.company}</span>
                {selectedLead.ai_score && (
                  <Badge className={`${getScoreBadge(selectedLead.ai_score)} font-medium ml-2`}>
                    Score: {selectedLead.ai_score}
                  </Badge>
                )}
              </DialogTitle>
              <DialogDescription>Company details and key decision maker contacts</DialogDescription>
            </DialogHeader>
            
            <div className="space-y-6">
              {/* Company Details */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold mb-3">Company Information</h4>
                  <div className="space-y-2 text-sm">
                    <p><strong>Industry:</strong> {selectedLead.industry}</p>
                    <p><strong>Location:</strong> {selectedLead.location}</p>
                    {selectedLead.foundedYear && <p><strong>Founded:</strong> {selectedLead.foundedYear}</p>}
                    {selectedLead.employeeCount && <p><strong>Employees:</strong> ~{selectedLead.employeeCount}</p>}
                    {selectedLead.domain && <p><strong>Domain:</strong> {selectedLead.domain}</p>}
                  </div>
                </div>
                
                <div>
                  <h4 className="font-semibold mb-3">AI Analysis</h4>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span>Overall Score:</span>
                      <span className={`font-medium ${getScoreColor(selectedLead.ai_score)}`}>
                        {selectedLead.ai_score}/100
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span>Contact Quality:</span>
                      <span className="font-medium">
                        {selectedLead.contacts.length > 2 ? 'Excellent' : 
                         selectedLead.contacts.length > 0 ? 'Good' : 'No contacts'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Description */}
              <div>
                <h4 className="font-semibold mb-2">Company Description</h4>
                <p className="text-sm text-gray-600 leading-relaxed">
                  {selectedLead.description}
                </p>
              </div>

              {/* Key Contacts */}
              <div>
                <h4 className="font-semibold mb-3">
                  Key Decision Makers ({selectedLead.contacts.length})
                </h4>
                {selectedLead.contacts.length > 0 ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {selectedLead.contacts.map((contact, index) => (
                      <div key={index} className="p-4 bg-gray-50 rounded-lg">
                        <div className="flex items-start space-x-3">
                          {contact.photo_url && (
                            <img 
                              src={contact.photo_url} 
                              alt={contact.name}
                              className="w-10 h-10 rounded-full object-cover"
                            />
                          )}
                          <div className="flex-1">
                            <p className="font-medium">{contact.name}</p>
                            <p className="text-sm text-gray-600">{contact.title}</p>
                            {contact.email && (
                              <p className="text-xs text-blue-600">{contact.email}</p>
                            )}
                            <div className="flex items-center space-x-2 mt-2">
                              <Badge variant="outline" className="text-xs">
                                {contact.role_category}
                              </Badge>
                              {contact.seniority && (
                                <Badge variant="outline" className="text-xs capitalize">
                                  {contact.seniority.replace('_', ' ')}
                                </Badge>
                              )}
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-gray-500 text-center py-4">No key contacts found for this company</p>
                )}
              </div>

              {/* Action Buttons */}
              <div className="flex justify-end space-x-3 pt-4 border-t">
                <Button variant="outline" onClick={() => setShowLeadDialog(false)}>
                  Close
                </Button>
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
echo "Contact Enrichment and Filters Fixed!"
echo "===================================="
echo ""
echo "Key fixes applied:"
echo "• ✅ CORRECT API PATTERN: Now uses q_organization_domains_list with company domains"
echo "• ✅ TWO-STEP PROCESS: Companies first, then cycle through each domain for contacts"
echo "• ✅ FILTERS ALWAYS VISIBLE: Result filters show whenever there are results"
echo "• ✅ DOMAIN EXTRACTION: Extracts domains from website_url or uses primary_domain"
echo "• ✅ PROGRESS TRACKING: Shows contact enrichment progress per company"
echo "• ✅ RATE LIMITING: Small delays between contact API calls"
echo ""
echo "Now the system:"
echo "1. Calls /mixed_companies/search to get companies"
echo "2. For each company, extracts domain (google.com, microsoft.com, etc.)"
echo "3. Calls /mixed_people/search?q_organization_domains_list[]=domain"
echo "4. Shows filters immediately when results appear"
echo ""
echo "Restart your server and test:"
echo "npm run dev"
echo ""
echo "You should now see actual contacts for each company!"
echo ""
