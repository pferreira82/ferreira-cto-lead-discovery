'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
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
  X,
  DollarSign,
  Briefcase,
  Crown,
  TrendingUp
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
  location: string // Short format (City, Country)
  full_address?: string // Full address for detail view
  totalFunding?: number
  employeeCount?: number
  foundedYear?: number
  ai_score?: number
  domain?: string
  funding_info?: {
    stage?: string
    amount?: number
    total_funding?: number
    date?: string
  }
  contacts: Array<{
    name: string
    title: string
    email?: string
    role_category: string
    linkedin?: string
    seniority?: string
    photo_url?: string
    location?: string
  }>
}

interface VCContact {
  name: string
  title: string
  email?: string
  role_category: string
  linkedin?: string
  seniority?: string
  photo_url?: string
  location?: string
  organization: string
  organization_domain?: string
}

interface ResultFilters {
  minScore: number
  maxScore: number
  hasContacts: boolean
  minContacts: number
  executivesOnly: boolean
  recentFunding: boolean
  majorCitiesOnly: boolean
}

const INDUSTRIES = [
  'Biotechnology', 'Pharmaceuticals', 'Medical Devices', 'Digital Health',
  'Gene Therapy', 'Cell Therapy', 'Diagnostics', 'Genomics',
  'Synthetic Biology', 'Neurotechnology', 'Biomanufacturing', 'Venture Capital'
]

const FUNDING_STAGES = [
  'Pre-Seed', 'Seed', 'Series A', 'Series B', 'Series C', 
  'Series D+', 'Growth', 'Pre-IPO', 'Public'
]

const COUNTRIES = [
  'United States', 'Canada', 'United Kingdom', 'Germany', 'France', 
  'Switzerland', 'Netherlands', 'Sweden', 'Israel', 'Singapore', 
  'Australia', 'Portugal', 'Spain', 'Italy', 'Ireland'
]

const MAJOR_CITIES = [
  'San Francisco', 'Boston', 'New York', 'London', 'Cambridge',
  'San Diego', 'Los Angeles', 'Seattle', 'Toronto', 'Berlin',
  'Zurich', 'Amsterdam', 'Stockholm', 'Tel Aviv', 'Singapore'
]

const EMPLOYEE_RANGES = [
  '1,10', '11,50', '51,200', '201,500', '501,1000', 
  '1001,5000', '5001,10000', '10001,100000'
]

export default function EnhancedLeadDiscoveryPage() {
  const { isDemoMode, isLoaded } = useDemoMode()
  const { fetchWithDemo } = useDemoAPI()
  
  const [isSearching, setIsSearching] = useState(false)
  const [searchProgress, setSearchProgress] = useState(0)
  const [currentStep, setCurrentStep] = useState('')
  const [discoveredLeads, setDiscoveredLeads] = useState<DiscoveredLead[]>([])
  const [vcContacts, setVcContacts] = useState<VCContact[]>([])
  const [filteredLeads, setFilteredLeads] = useState<DiscoveredLead[]>([])
  const [selectedLead, setSelectedLead] = useState<DiscoveredLead | null>(null)
  const [showLeadDialog, setShowLeadDialog] = useState(false)
  const [showFilters, setShowFilters] = useState(false)
  const [totalContacts, setTotalContacts] = useState(0)
  const [activeTab, setActiveTab] = useState('companies')
  
  const [searchParams, setSearchParams] = useState({
    industries: ['Biotechnology', 'Pharmaceuticals'],
    fundingStages: ['Series A', 'Series B', 'Series C'],
    locations: ['United States', 'United Kingdom'],
    employeeRanges: ['51,200', '201,500', '501,1000'],
    includeVCs: true,
    maxResults: 15
  })

  const [resultFilters, setResultFilters] = useState<ResultFilters>({
    minScore: 70,
    maxScore: 100,
    hasContacts: false,
    minContacts: 0,
    executivesOnly: false,
    recentFunding: false,
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

    if (resultFilters.executivesOnly) {
      filtered = filtered.filter(lead => 
        lead.contacts.some(contact => 
          ['Founder', 'C-Suite', 'Board/Partner'].includes(contact.role_category)
        )
      )
    }

    if (resultFilters.recentFunding) {
      filtered = filtered.filter(lead => {
        if (!lead.funding_info?.date) return false
        const fundingDate = new Date(lead.funding_info.date)
        const monthsAgo = (Date.now() - fundingDate.getTime()) / (1000 * 60 * 60 * 24 * 30)
        return monthsAgo <= 12
      })
    }

    if (resultFilters.majorCitiesOnly) {
      filtered = filtered.filter(lead =>
        MAJOR_CITIES.some(city => 
          lead.location?.toLowerCase().includes(city.toLowerCase())
        )
      )
    }

    setFilteredLeads(filtered)
  }, [discoveredLeads, resultFilters])

  const handleSearch = async () => {
    setIsSearching(true)
    setSearchProgress(0)
    setCurrentStep('Starting enhanced search...')
    setDiscoveredLeads([])
    setVcContacts([])

    try {
      const response = await fetchWithDemo('/api/discovery/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(searchParams)
      })

      if (response.ok) {
        const data = await response.json()
        setDiscoveredLeads(data.leads || [])
        setVcContacts(data.vcContacts || [])
        setTotalContacts(data.totalContacts || 0)
        
        if (data.leads?.length > 0 || data.vcContacts?.length > 0) {
          setShowFilters(true)
        }
        
        toast.success(`Found ${data.leads?.length || 0} companies with ${data.totalContacts || 0} contacts and ${data.vcContacts?.length || 0} VCs!`)
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

  const getRoleBadgeColor = (roleCategory: string) => {
    switch (roleCategory) {
      case 'Founder': return 'bg-purple-100 text-purple-800'
      case 'C-Suite': return 'bg-red-100 text-red-800'
      case 'Board/Partner': return 'bg-blue-100 text-blue-800'
      case 'VP': return 'bg-orange-100 text-orange-800'
      case 'Investor/VC': return 'bg-green-100 text-green-800'
      default: return 'bg-gray-100 text-gray-600'
    }
  }

  if (!isLoaded) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold">Loading...</h1>
          <p className="text-gray-600">Initializing enhanced discovery system...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">Enhanced VC & Founder Discovery</h1>
          <p className="text-gray-600">Find companies, founders, and VCs with enhanced filtering</p>
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
            Enhanced Search Parameters
          </CardTitle>
          <CardDescription>Configure your discovery criteria for companies, founders, and VCs</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
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

            {/* Funding Stages */}
            <div>
              <label className="block text-sm font-medium mb-2">
                <TrendingUp className="inline w-4 h-4 mr-1" />
                Funding Stages
              </label>
              <div className="space-y-2 max-h-48 overflow-y-auto border rounded p-2">
                {FUNDING_STAGES.map(stage => (
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
                    <span className="text-sm">{stage}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Locations */}
            <div>
              <label className="block text-sm font-medium mb-2">
                <Globe className="inline w-4 h-4 mr-1" />
                Countries
              </label>
              <div className="space-y-2 max-h-48 overflow-y-auto border rounded p-2">
                {COUNTRIES.map(country => (
                  <div key={country} className="flex items-center space-x-2">
                    <Checkbox
                      checked={searchParams.locations.includes(country)}
                      onCheckedChange={(checked) => {
                        if (checked) {
                          setSearchParams(prev => ({
                            ...prev,
                            locations: [...prev.locations, country]
                          }))
                        } else {
                          setSearchParams(prev => ({
                            ...prev,
                            locations: prev.locations.filter(l => l !== country)
                          }))
                        }
                      }}
                    />
                    <span className="text-sm">{country}</span>
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
                      maxResults: parseInt(e.target.value) || 15 
                    }))}
                    min="5"
                    max="30"
                    className="w-24 mt-1"
                  />
                </div>
                
                <div className="flex items-center space-x-2">
                  <Checkbox
                    checked={searchParams.includeVCs}
                    onCheckedChange={(checked) => 
                      setSearchParams(prev => ({ ...prev, includeVCs: checked as boolean }))
                    }
                  />
                  <span className="text-sm">Include VCs & Investors</span>
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

      {/* Result Filters */}
      {(discoveredLeads.length > 0 || vcContacts.length > 0) && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <div className="flex items-center">
                <SlidersHorizontal className="mr-2 h-5 w-5" />
                Advanced Filters
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
                <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
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
                      <div className="flex items-center space-x-2">
                        <Checkbox
                          checked={resultFilters.executivesOnly}
                          onCheckedChange={(checked) => 
                            setResultFilters(prev => ({ ...prev, executivesOnly: checked as boolean }))
                          }
                        />
                        <span className="text-sm">Executives only</span>
                      </div>
                    </div>
                  </div>

                  {/* Quality Filters */}
                  <div>
                    <label className="block text-sm font-medium mb-2">Quality Filters</label>
                    <div className="space-y-2">
                      <div className="flex items-center space-x-2">
                        <Checkbox
                          checked={resultFilters.recentFunding}
                          onCheckedChange={(checked) => 
                            setResultFilters(prev => ({ ...prev, recentFunding: checked as boolean }))
                          }
                        />
                        <span className="text-sm">Recent funding</span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Checkbox
                          checked={resultFilters.majorCitiesOnly}
                          onCheckedChange={(checked) => 
                            setResultFilters(prev => ({ ...prev, majorCitiesOnly: checked as boolean }))
                          }
                        />
                        <span className="text-sm">Major cities</span>
                      </div>
                    </div>
                  </div>

                  {/* Min Contacts */}
                  <div>
                    <label className="block text-sm font-medium mb-2">Min Contacts</label>
                    <Input
                      type="number"
                      value={resultFilters.minContacts}
                      onChange={(e) => setResultFilters(prev => ({
                        ...prev,
                        minContacts: parseInt(e.target.value) || 0
                      }))}
                      min="0"
                      className="w-full"
                    />
                  </div>

                  {/* Quick Actions */}
                  <div>
                    <label className="block text-sm font-medium mb-2">Quick Filters</label>
                    <div className="space-y-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setResultFilters(prev => ({ 
                          ...prev, 
                          minScore: 80, 
                          executivesOnly: true,
                          recentFunding: true
                        }))}
                        className="w-full text-xs"
                      >
                        Premium Only
                      </Button>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setResultFilters({
                          minScore: 60,
                          maxScore: 100,
                          hasContacts: false,
                          minContacts: 0,
                          executivesOnly: false,
                          recentFunding: false,
                          majorCitiesOnly: false
                        })}
                        className="w-full text-xs"
                      >
                        Clear All
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
      {(filteredLeads.length > 0 || vcContacts.length > 0) && (
        <div className="grid grid-cols-1 md:grid-cols-6 gap-4">
          <Card>
            <CardContent className="p-4 text-center">
              <Building className="w-8 h-8 mx-auto mb-2 text-blue-500" />
              <p className="text-2xl font-bold">{filteredLeads.length}</p>
              <p className="text-sm text-gray-600">Companies</p>
            </CardContent>
          </Card>
          
          <Card>
            <CardContent className="p-4 text-center">
              <Crown className="w-8 h-8 mx-auto mb-2 text-purple-500" />
              <p className="text-2xl font-bold">
                {filteredLeads.reduce((sum, lead) => 
                  sum + lead.contacts.filter(c => c.role_category === 'Founder').length, 0
                )}
              </p>
              <p className="text-sm text-gray-600">Founders</p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-4 text-center">
              <Briefcase className="w-8 h-8 mx-auto mb-2 text-red-500" />
              <p className="text-2xl font-bold">
                {filteredLeads.reduce((sum, lead) => 
                  sum + lead.contacts.filter(c => c.role_category === 'C-Suite').length, 0
                )}
              </p>
              <p className="text-sm text-gray-600">C-Suite</p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-4 text-center">
              <DollarSign className="w-8 h-8 mx-auto mb-2 text-green-500" />
              <p className="text-2xl font-bold">{vcContacts.length}</p>
              <p className="text-sm text-gray-600">VCs/Investors</p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-4 text-center">
              <Users className="w-8 h-8 mx-auto mb-2 text-orange-500" />
              <p className="text-2xl font-bold">
                {filteredLeads.reduce((sum, lead) => sum + lead.contacts.length, 0) + vcContacts.length}
              </p>
              <p className="text-sm text-gray-600">Total Contacts</p>
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

      {/* Results Tabs */}
      {(filteredLeads.length > 0 || vcContacts.length > 0) && (
        <Card>
          <CardHeader>
            <CardTitle>Discovery Results</CardTitle>
            <CardDescription>Companies and VCs with key decision makers</CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs value={activeTab} onValueChange={setActiveTab}>
              <TabsList className="grid w-full grid-cols-2">
                <TabsTrigger value="companies">
                  Companies ({filteredLeads.length})
                </TabsTrigger>
                <TabsTrigger value="vcs">
                  VCs & Investors ({vcContacts.length})
                </TabsTrigger>
              </TabsList>

              <TabsContent value="companies" className="mt-4">
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b">
                        <th className="p-3 text-left font-medium">Company</th>
                        <th className="p-3 text-left font-medium">Location</th>
                        <th className="p-3 text-left font-medium">Funding</th>
                        <th className="p-3 text-left font-medium">Key Contacts</th>
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
                              <p className="text-xs text-gray-500">{lead.industry}</p>
                            </div>
                          </td>
                          <td className="p-3">
                            <div className="flex items-center text-sm text-gray-600">
                              <MapPin className="w-3 h-3 mr-1" />
                              {/* SHORT FORMAT: City, Country */}
                              <span className="truncate max-w-[120px]">{lead.location}</span>
                            </div>
                          </td>
                          <td className="p-3">
                            <div className="text-sm">
                              {lead.funding_info?.stage && (
                                <Badge variant="outline" className="text-xs mb-1">
                                  {lead.funding_info.stage}
                                </Badge>
                              )}
                              {lead.funding_info?.total_funding && (
                                <p className="text-xs text-gray-500">
                                  ${(lead.funding_info.total_funding / 1000000).toFixed(1)}M total
                                </p>
                              )}
                            </div>
                          </td>
                          <td className="p-3">
                            <div className="flex flex-wrap gap-1">
                              {lead.contacts.slice(0, 3).map((contact, idx) => (
                                <Badge 
                                  key={idx} 
                                  className={`${getRoleBadgeColor(contact.role_category)} text-xs`}
                                >
                                  {contact.role_category}
                                </Badge>
                              ))}
                              {lead.contacts.length > 3 && (
                                <span className="text-xs text-gray-500">+{lead.contacts.length - 3}</span>
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
              </TabsContent>

              <TabsContent value="vcs" className="mt-4">
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b">
                        <th className="p-3 text-left font-medium">Name</th>
                        <th className="p-3 text-left font-medium">Title</th>
                        <th className="p-3 text-left font-medium">Organization</th>
                        <th className="p-3 text-left font-medium">Location</th>
                        <th className="p-3 text-left font-medium">Contact</th>
                      </tr>
                    </thead>
                    <tbody>
                      {vcContacts.map((vc, index) => (
                        <tr key={index} className="border-b hover:bg-gray-50">
                          <td className="p-3">
                            <div className="flex items-center space-x-2">
                              {vc.photo_url && (
                                <img 
                                  src={vc.photo_url} 
                                  alt={vc.name}
                                  className="w-8 h-8 rounded-full object-cover"
                                />
                              )}
                              <span className="font-medium">{vc.name}</span>
                            </div>
                          </td>
                          <td className="p-3">
                            <span className="text-sm">{vc.title}</span>
                          </td>
                          <td className="p-3">
                            <div>
                              <span className="text-sm font-medium">{vc.organization}</span>
                              {vc.organization_domain && (
                                <p className="text-xs text-gray-500">{vc.organization_domain}</p>
                              )}
                            </div>
                          </td>
                          <td className="p-3">
                            <span className="text-sm text-gray-600">{vc.location}</span>
                          </td>
                          <td className="p-3">
                            <div className="flex space-x-2">
                              {vc.email && (
                                <Button variant="ghost" size="sm">
                                  <Mail className="w-3 h-3" />
                                </Button>
                              )}
                              {vc.linkedin && (
                                <Button variant="ghost" size="sm" asChild>
                                  <a href={vc.linkedin} target="_blank" rel="noopener noreferrer">
                                    <Globe className="w-3 h-3" />
                                  </a>
                                </Button>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      )}

      {/* Empty State */}
      {!isSearching && discoveredLeads.length === 0 && vcContacts.length === 0 && (
        <Card>
          <CardContent className="p-12 text-center">
            <Search className="w-16 h-16 mx-auto mb-4 text-gray-400" />
            <h3 className="text-lg font-semibold mb-2">Ready for Enhanced Discovery</h3>
            <p className="text-gray-600 mb-4">
              Find companies, founders, board members, and VCs with advanced filtering
            </p>
            <Button onClick={handleSearch} className="bg-gradient-to-r from-blue-500 to-purple-600">
              <Search className="w-4 h-4 mr-2" />
              Start Enhanced Discovery
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Lead Detail Dialog */}
      {showLeadDialog && selectedLead && (
        <Dialog open={showLeadDialog} onOpenChange={setShowLeadDialog}>
          <DialogContent className="max-w-5xl max-h-[90vh] overflow-y-auto">
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
              <DialogDescription>Comprehensive company and contact details</DialogDescription>
            </DialogHeader>
            
            <div className="space-y-6">
              {/* Company Overview */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <h4 className="font-semibold mb-3">Company Information</h4>
                  <div className="space-y-2 text-sm">
                    <p><strong>Industry:</strong> {selectedLead.industry}</p>
                    {/* FULL ADDRESS: Complete location information */}
                    <p><strong>Location:</strong> {selectedLead.full_address || selectedLead.location}</p>
                    {selectedLead.foundedYear && <p><strong>Founded:</strong> {selectedLead.foundedYear}</p>}
                    {selectedLead.employeeCount && <p><strong>Employees:</strong> ~{selectedLead.employeeCount}</p>}
                    {selectedLead.domain && <p><strong>Domain:</strong> {selectedLead.domain}</p>}
                  </div>
                </div>
                
                <div>
                  <h4 className="font-semibold mb-3">Funding Information</h4>
                  <div className="space-y-2 text-sm">
                    {selectedLead.funding_info?.stage && (
                      <p><strong>Stage:</strong> {selectedLead.funding_info.stage}</p>
                    )}
                    {selectedLead.funding_info?.total_funding && (
                      <p><strong>Total Funding:</strong> ${(selectedLead.funding_info.total_funding / 1000000).toFixed(1)}M</p>
                    )}
                    {selectedLead.funding_info?.amount && (
                      <p><strong>Latest Round:</strong> ${(selectedLead.funding_info.amount / 1000000).toFixed(1)}M</p>
                    )}
                    {selectedLead.funding_info?.date && (
                      <p><strong>Last Funded:</strong> {new Date(selectedLead.funding_info.date).toLocaleDateString()}</p>
                    )}
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
                    <div className="flex justify-between">
                      <span>Executive Access:</span>
                      <span className="font-medium">
                        {selectedLead.contacts.filter(c => ['Founder', 'C-Suite'].includes(c.role_category)).length > 0 ? 'Yes' : 'No'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Company Description */}
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
                              className="w-12 h-12 rounded-full object-cover"
                            />
                          )}
                          <div className="flex-1">
                            <p className="font-medium">{contact.name}</p>
                            <p className="text-sm text-gray-600">{contact.title}</p>
                            {contact.email && (
                              <p className="text-xs text-blue-600">{contact.email}</p>
                            )}
                            {contact.location && (
                              <p className="text-xs text-gray-500">{contact.location}</p>
                            )}
                            <div className="flex items-center space-x-2 mt-2">
                              <Badge className={`${getRoleBadgeColor(contact.role_category)} text-xs`}>
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
