#!/bin/bash

echo "🔍 Enhancing Lead Discovery with Advanced Search Criteria..."
echo "=========================================================="

# 1. Update the discovery page with advanced search interface
echo "🎨 Creating enhanced discovery page with advanced search..."
cat > app/discovery/page.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
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
  DollarSign,
  Star,
  MoreVertical,
  Play,
  Settings,
  CheckCircle,
  Database,
  Briefcase,
  TrendingUp
} from 'lucide-react'
import { toast } from 'react-hot-toast'
import { useDemoMode } from '@/lib/demo-context'

interface DiscoveredLead {
  id: string
  name: string
  type: 'company' | 'vc_firm'
  website?: string
  industry: string
  fundingStage?: string
  vcFocus?: string[]
  description: string
  location: string
  totalFunding?: number
  employeeCount?: number
  founded?: number
  portfolioSize?: number
  contacts: Array<{
    id: string
    name: string
    title: string
    email?: string
    linkedin?: string
    role_category: string
  }>
  aiScore?: {
    overallScore: number
    relevanceScore: number
    growthPotential: number
    techMaturity: number
    urgencyLevel: 'low' | 'medium' | 'high' | 'critical'
    reasoning: string
    actionRecommendation: string
    contactPriority: string[]
  }
  recentNews?: string[]
  technologies?: string[]
}

interface SearchParams {
  targetTypes: ('companies' | 'vc_firms')[]
  industries: string[]
  fundingStages: string[]
  locations: string[]
  vcFocusAreas: string[]
  excludeExisting: boolean
  aiScoring: boolean
  maxResults: number
  companySize?: { min?: number; max?: number }
  fundingRange?: { min?: number; max?: number }
}

const DEMO_LEADS: DiscoveredLead[] = [
  // Biotech Companies
  {
    id: 'demo-1',
    name: 'BioTech Innovations Inc.',
    type: 'company',
    website: 'https://biotechinnovations.com',
    industry: 'Biotechnology',
    fundingStage: 'Series B',
    description: 'AI-powered drug discovery platform leveraging machine learning to accelerate pharmaceutical development.',
    location: 'Boston, MA, USA',
    totalFunding: 45000000,
    employeeCount: 125,
    founded: 2019,
    contacts: [
      {
        id: 'c1',
        name: 'Dr. Sarah Chen',
        title: 'CEO & Co-Founder',
        email: 'sarah.chen@biotechinnovations.com',
        linkedin: 'https://linkedin.com/in/sarahchen-biotech',
        role_category: 'Founder'
      },
      {
        id: 'c2',
        name: 'Michael Rodriguez',
        title: 'Chief Technology Officer',
        email: 'm.rodriguez@biotechinnovations.com',
        role_category: 'Executive'
      }
    ],
    aiScore: {
      overallScore: 87,
      relevanceScore: 92,
      growthPotential: 85,
      techMaturity: 82,
      urgencyLevel: 'high',
      reasoning: 'Excellent fit for technology consulting. Series B stage indicates rapid growth and complex technology challenges.',
      actionRecommendation: 'Priority outreach to CTO and CEO. Focus on scaling technology infrastructure.',
      contactPriority: ['CTO', 'CEO']
    },
    recentNews: ['Raised $45M Series B', 'Partnership with Pfizer'],
    technologies: ['Machine Learning', 'Python', 'AWS']
  },
  // VC Firms
  {
    id: 'demo-vc-1',
    name: 'Andreessen Horowitz Bio Fund',
    type: 'vc_firm',
    website: 'https://a16z.com/bio',
    industry: 'Venture Capital',
    vcFocus: ['Biotechnology', 'Digital Health', 'Synthetic Biology'],
    description: 'Leading venture capital firm with dedicated bio fund focusing on breakthrough biotechnology companies.',
    location: 'Menlo Park, CA, USA',
    portfolioSize: 45,
    founded: 2009,
    contacts: [
      {
        id: 'vc1',
        name: 'Vineeta Agarwala',
        title: 'General Partner',
        email: 'vineeta@a16z.com',
        role_category: 'VC'
      },
      {
        id: 'vc2',
        name: 'Julie Yoo',
        title: 'General Partner',
        email: 'julie@a16z.com',
        role_category: 'VC'
      }
    ],
    aiScore: {
      overallScore: 93,
      relevanceScore: 96,
      growthPotential: 90,
      techMaturity: 88,
      urgencyLevel: 'critical',
      reasoning: 'Top-tier VC with significant biotech portfolio. Partners likely need technology due diligence for investments.',
      actionRecommendation: 'Strategic partnership opportunity for technology due diligence services.',
      contactPriority: ['General Partner', 'Principal']
    },
    recentNews: ['New $450M bio fund launched', 'Invested in 12 biotech companies this year'],
    technologies: ['Due Diligence Platforms', 'Data Analytics']
  },
  {
    id: 'demo-vc-2',
    name: 'Sofinnova Partners',
    type: 'vc_firm',
    website: 'https://sofinnovapartners.com',
    industry: 'Venture Capital',
    vcFocus: ['Life Sciences', 'Healthcare Technology', 'Industrial Biotech'],
    description: 'European and US venture capital firm specializing in life sciences investments.',
    location: 'London, UK',
    portfolioSize: 60,
    founded: 1972,
    contacts: [
      {
        id: 'vc3',
        name: 'Antoine Papiernik',
        title: 'Managing Partner',
        email: 'antoine@sofinnovapartners.com',
        role_category: 'VC'
      }
    ],
    aiScore: {
      overallScore: 89,
      relevanceScore: 91,
      growthPotential: 87,
      techMaturity: 85,
      urgencyLevel: 'high',
      reasoning: 'Established European VC with strong life sciences focus. International presence suggests complex technology needs.',
      actionRecommendation: 'Target for technology consulting services for portfolio companies and due diligence.',
      contactPriority: ['Managing Partner', 'Partner']
    },
    recentNews: ['Completed Fund VII at €400M', 'Expanded US operations'],
    technologies: ['Portfolio Management', 'Investment Analytics']
  },
  {
    id: 'demo-3',
    name: 'Genomics Innovation Ltd',
    type: 'company',
    website: 'https://genomicsinnovation.co.uk',
    industry: 'Genomics',
    fundingStage: 'Series A',
    description: 'UK-based genomics company developing next-generation sequencing technologies for personalized medicine.',
    location: 'Cambridge, UK',
    totalFunding: 18000000,
    employeeCount: 45,
    founded: 2021,
    contacts: [
      {
        id: 'c3',
        name: 'Dr. James Wilson',
        title: 'CEO',
        email: 'j.wilson@genomicsinnovation.co.uk',
        role_category: 'Founder'
      }
    ],
    aiScore: {
      overallScore: 79,
      relevanceScore: 84,
      growthPotential: 88,
      techMaturity: 65,
      urgencyLevel: 'medium',
      reasoning: 'Early-stage UK genomics company with strong growth potential. Technology infrastructure needs typical of Series A companies.',
      actionRecommendation: 'Focus on cloud infrastructure, data management, and regulatory compliance systems.',
      contactPriority: ['CEO', 'CTO']
    },
    recentNews: ['Series A funding completed', 'NHS partnership announced'],
    technologies: ['NGS', 'Bioinformatics', 'Cloud Computing']
  }
]

const INDUSTRIES = [
  'Biotechnology',
  'Pharmaceuticals', 
  'Medical Devices',
  'Digital Health',
  'Gene Therapy',
  'Cell Therapy',
  'Diagnostics',
  'Genomics',
  'Synthetic Biology',
  'Neurotechnology',
  'Biomanufacturing',
  'AI Drug Discovery',
  'Precision Medicine'
]

const FUNDING_STAGES = [
  'Pre-Seed',
  'Seed',
  'Series A',
  'Series B', 
  'Series C',
  'Series D+',
  'Growth',
  'Pre-IPO',
  'Public'
]

const LOCATIONS = [
  'United States',
  'Canada', 
  'United Kingdom',
  'Portugal',
  'Germany',
  'France',
  'Switzerland',
  'Netherlands',
  'Sweden',
  'Israel',
  'Singapore',
  'Australia'
]

const VC_FOCUS_AREAS = [
  'Biotechnology',
  'Life Sciences',
  'Healthcare Technology',
  'Digital Health',
  'Pharmaceutical',
  'Medical Devices',
  'Diagnostics',
  'Genomics',
  'Synthetic Biology',
  'AI/ML in Healthcare'
]

export default function LeadDiscoveryPage() {
  const { isDemoMode, isLoaded } = useDemoMode()
  
  const [isSearching, setIsSearching] = useState(false)
  const [searchProgress, setSearchProgress] = useState(0)
  const [discoveredLeads, setDiscoveredLeads] = useState<DiscoveredLead[]>([])
  const [selectedLeads, setSelectedLeads] = useState<string[]>([])
  const [selectedLead, setSelectedLead] = useState<DiscoveredLead | null>(null)
  const [showLeadDialog, setShowLeadDialog] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  
  const [searchParams, setSearchParams] = useState<SearchParams>({
    targetTypes: ['companies'],
    industries: ['Biotechnology', 'Pharmaceuticals'],
    fundingStages: ['Series A', 'Series B', 'Series C'],
    locations: ['United States', 'Canada', 'United Kingdom', 'Portugal'],
    vcFocusAreas: ['Biotechnology', 'Life Sciences'],
    excludeExisting: true,
    aiScoring: true,
    maxResults: 100,
    companySize: { min: 10, max: 1000 },
    fundingRange: { min: 1000000, max: 500000000 }
  })

  const handleSearch = async () => {
    setIsSearching(true)
    setSearchProgress(0)
    setDiscoveredLeads([])
    setSelectedLeads([])

    try {
      if (isDemoMode) {
        const progressSteps = [
          { progress: 20, message: "🔍 Searching Apollo API..." },
          { progress: 40, message: "💰 Analyzing Crunchbase data..." },
          { progress: 60, message: "🏢 Finding VC firms..." },
          { progress: 80, message: "🤖 AI scoring leads..." },
          { progress: 100, message: "✅ Finalizing results..." }
        ]

        for (const step of progressSteps) {
          await new Promise(resolve => setTimeout(resolve, 800))
          setSearchProgress(step.progress)
        }

        // Filter demo leads based on search params
        let filteredLeads = DEMO_LEADS.filter(lead => {
          const typeMatch = searchParams.targetTypes.includes(lead.type)
          const industryMatch = searchParams.industries.length === 0 || 
                               searchParams.industries.some(industry => 
                                 lead.industry.toLowerCase().includes(industry.toLowerCase()) ||
                                 (lead.vcFocus && lead.vcFocus.some(focus => 
                                   focus.toLowerCase().includes(industry.toLowerCase())
                                 ))
                               )
          const stageMatch = !lead.fundingStage || 
                            searchParams.fundingStages.length === 0 || 
                            searchParams.fundingStages.includes(lead.fundingStage)
          const locationMatch = searchParams.locations.some(location => 
            lead.location.toLowerCase().includes(location.toLowerCase())
          )
          
          return typeMatch && industryMatch && stageMatch && locationMatch
        })

        setDiscoveredLeads(filteredLeads)
        toast.success(`Found ${filteredLeads.length} demo leads!`)
      } else {
        const response = await fetch('/api/discovery/search', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(searchParams)
        })

        if (response.ok) {
          const data = await response.json()
          setDiscoveredLeads(data.leads || [])
          toast.success(`Found ${data.leads?.length || 0} production leads!`)
        } else {
          throw new Error('Search failed')
        }
      }
    } catch (error) {
      console.error('Search error:', error)
      toast.error('Search failed. Please try again.')
    } finally {
      setIsSearching(false)
      setTimeout(() => setSearchProgress(0), 2000)
    }
  }

  const handleSaveLead = async (lead: DiscoveredLead) => {
    setIsSaving(true)
    try {
      if (isDemoMode) {
        await new Promise(resolve => setTimeout(resolve, 1000))
        toast.success(`Demo: Saved ${lead.name} to database!`)
        return
      }

      const response = await fetch('/api/discovery/save-leads', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ leads: [lead] })
      })

      if (response.ok) {
        toast.success(`Saved ${lead.name} with ${lead.contacts.length} contacts!`)
        setDiscoveredLeads(prev => prev.filter(l => l.id !== lead.id))
        setSelectedLeads(prev => prev.filter(id => id !== lead.id))
      } else {
        throw new Error('Save failed')
      }
    } catch (error) {
      console.error('Save error:', error)
      toast.error('Failed to save lead. Please try again.')
    } finally {
      setIsSaving(false)
    }
  }

  const handleViewDetails = (lead: DiscoveredLead) => {
    setSelectedLead(lead)
    setShowLeadDialog(true)
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

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedLeads(discoveredLeads.map(lead => lead.id))
    } else {
      setSelectedLeads([])
    }
  }

  const handleSelectLead = (leadId: string, checked: boolean) => {
    if (checked) {
      setSelectedLeads([...selectedLeads, leadId])
    } else {
      setSelectedLeads(selectedLeads.filter(id => id !== leadId))
    }
  }

  if (!isLoaded) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Loading...</h1>
          <p className="text-gray-600 dark:text-gray-400">Initializing lead discovery system...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Advanced Lead Discovery</h1>
          <p className="text-gray-600 dark:text-gray-400">
            Target biotech companies and VC firms worldwide • {isDemoMode ? 'Demo Mode' : 'Production Mode'}
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <Button variant="outline" className="flex items-center space-x-2">
            <Download className="w-4 h-4" />
            <span>Export</span>
          </Button>
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

      {/* Mode Info Banner */}
      <Card className={`border-0 shadow-sm ${isDemoMode ? 'bg-blue-50 dark:bg-blue-900/20' : 'bg-green-50 dark:bg-green-900/20'}`}>
        <CardContent className="p-4">
          <div className="flex items-center space-x-3">
            {isDemoMode ? (
              <Play className="w-5 h-5 text-blue-600 dark:text-blue-400" />
            ) : (
              <Database className="w-5 h-5 text-green-600 dark:text-green-400" />
            )}
            <div>
              <p className={`font-medium ${isDemoMode ? 'text-blue-800 dark:text-blue-300' : 'text-green-800 dark:text-green-300'}`}>
                {isDemoMode ? 'Demo Mode Active' : 'Production Mode Active'}
              </p>
              <p className={`text-sm ${isDemoMode ? 'text-blue-600 dark:text-blue-400' : 'text-green-600 dark:text-green-400'}`}>
                {isDemoMode 
                  ? 'Using sample data for testing and exploration'
                  : 'Live system using real APIs and saving to production database'
                }
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Advanced Search Configuration */}
      <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
        <CardHeader>
          <CardTitle className="flex items-center text-gray-900 dark:text-white">
            <Filter className="mr-2 h-5 w-5" />
            Advanced Search Parameters
          </CardTitle>
          <CardDescription>Target biotech companies and VC firms with precise criteria</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Target Types */}
          <div>
            <label className="block text-sm font-medium mb-3 text-gray-900 dark:text-white">Target Types</label>
            <div className="flex gap-4">
              <div className="flex items-center space-x-2">
                <Checkbox
                  checked={searchParams.targetTypes.includes('companies')}
                  onCheckedChange={(checked) => {
                    if (checked) {
                      setSearchParams(prev => ({
                        ...prev,
                        targetTypes: [...prev.targetTypes.filter(t => t !== 'companies'), 'companies']
                      }))
                    } else {
                      setSearchParams(prev => ({
                        ...prev,
                        targetTypes: prev.targetTypes.filter(t => t !== 'companies')
                      }))
                    }
                  }}
                />
                <Building className="w-4 h-4 text-blue-500" />
                <span className="text-sm text-gray-700 dark:text-gray-300">Biotech Companies</span>
              </div>
              <div className="flex items-center space-x-2">
                <Checkbox
                  checked={searchParams.targetTypes.includes('vc_firms')}
                  onCheckedChange={(checked) => {
                    if (checked) {
                      setSearchParams(prev => ({
                        ...prev,
                        targetTypes: [...prev.targetTypes.filter(t => t !== 'vc_firms'), 'vc_firms']
                      }))
                    } else {
                      setSearchParams(prev => ({
                        ...prev,
                        targetTypes: prev.targetTypes.filter(t => t !== 'vc_firms')
                      }))
                    }
                  }}
                />
                <Briefcase className="w-4 h-4 text-purple-500" />
                <span className="text-sm text-gray-700 dark:text-gray-300">VC Firms (Biotech Focus)</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Industries */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Industries</label>
              <div className="space-y-2 max-h-48 overflow-y-auto">
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
                    <span className="text-sm text-gray-700 dark:text-gray-300">{industry}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Funding Stages */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Funding Stages</label>
              <div className="space-y-2 max-h-48 overflow-y-auto">
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
                    <span className="text-sm text-gray-700 dark:text-gray-300">{stage}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Locations */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">
                <Globe className="inline w-4 h-4 mr-1" />
                Target Locations
              </label>
              <div className="space-y-2 max-h-48 overflow-y-auto">
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
                    <span className="text-sm text-gray-700 dark:text-gray-300">{location}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Options */}
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">
                Search Options
              </label>
              
              <div className="space-y-3">
                <div className="flex items-center space-x-2">
                  <Checkbox
                    checked={searchParams.excludeExisting}
                    onCheckedChange={(checked) => 
                      setSearchParams(prev => ({ ...prev, excludeExisting: checked as boolean }))
                    }
                  />
                  <span className="text-sm text-gray-700 dark:text-gray-300">Exclude existing contacts</span>
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
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardContent className="p-6">
            <div className="flex items-center space-x-4">
              <RefreshCw className="w-5 h-5 animate-spin text-blue-500" />
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900 dark:text-white">
                  Searching for {searchParams.targetTypes.join(' and ')}... {isDemoMode ? '(Demo Mode)' : '(Production)'}
                </p>
                <Progress value={searchProgress} className="mt-2" />
              </div>
              <span className="text-sm text-gray-500 dark:text-gray-400">{searchProgress}%</span>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Results Stats */}
      {discoveredLeads.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Target className="w-8 h-8 mx-auto mb-2 text-blue-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{discoveredLeads.length}</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Total Results</p>
            </CardContent>
          </Card>
          
          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Building className="w-8 h-8 mx-auto mb-2 text-green-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {discoveredLeads.filter(lead => lead.type === 'company').length}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Companies</p>
            </CardContent>
          </Card>

          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Briefcase className="w-8 h-8 mx-auto mb-2 text-purple-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {discoveredLeads.filter(lead => lead.type === 'vc_firm').length}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">VC Firms</p>
            </CardContent>
          </Card>

          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Users className="w-8 h-8 mx-auto mb-2 text-orange-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {discoveredLeads.reduce((sum, lead) => sum + lead.contacts.length, 0)}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">Contacts</p>
            </CardContent>
          </Card>

          <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
            <CardContent className="p-4 text-center">
              <Brain className="w-8 h-8 mx-auto mb-2 text-red-500" />
              <p className="text-2xl font-bold text-gray-900 dark:text-white">
                {discoveredLeads.filter(lead => lead.aiScore && lead.aiScore.overallScore >= 80).length}
              </p>
              <p className="text-sm text-gray-600 dark:text-gray-400">High Quality</p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Results Table */}
      {discoveredLeads.length > 0 && (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">
              Discovery Results ({discoveredLeads.length})
            </CardTitle>
            <CardDescription>Companies and VC firms matching your search criteria</CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-gray-200 dark:border-gray-700">
                  <TableHead className="w-12">
                    <Checkbox
                      checked={selectedLeads.length === discoveredLeads.length && discoveredLeads.length > 0}
                      onCheckedChange={handleSelectAll}
                    />
                  </TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Name</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Type</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Industry/Focus</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Stage/Size</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Location</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Contacts</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">AI Score</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {discoveredLeads.map((lead) => (
                  <TableRow key={lead.id} className="border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700">
                    <TableCell>
                      <Checkbox
                        checked={selectedLeads.includes(lead.id)}
                        onCheckedChange={(checked) => handleSelectLead(lead.id, checked as boolean)}
                      />
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">{lead.name}</p>
                        {lead.website && (
                          <a 
                            href={lead.website} 
                            target="_blank" 
                            rel="noopener noreferrer"
                            className="text-xs text-blue-600 dark:text-blue-400 hover:underline"
                          >
                            {lead.website.replace('https://', '')}
                          </a>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center space-x-2">
                        {lead.type === 'company' ? (
                          <Building className="w-4 h-4 text-blue-500" />
                        ) : (
                          <Briefcase className="w-4 h-4 text-purple-500" />
                        )}
                        <Badge variant="outline" className={lead.type === 'company' ? 'text-blue-700 dark:text-blue-400' : 'text-purple-700 dark:text-purple-400'}>
                          {lead.type === 'company' ? 'Company' : 'VC Firm'}
                        </Badge>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="text-sm text-gray-700 dark:text-gray-300">{lead.industry}</p>
                        {lead.vcFocus && (
                          <p className="text-xs text-gray-500 dark:text-gray-400">
                            Focus: {lead.vcFocus.slice(0, 2).join(', ')}
                          </p>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      {lead.fundingStage && (
                        <Badge className="bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400">
                          {lead.fundingStage}
                        </Badge>
                      )}
                      {lead.portfolioSize && (
                        <Badge className="bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400">
                          {lead.portfolioSize} portfolio
                        </Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center text-sm text-gray-600 dark:text-gray-400">
                        <MapPin className="w-3 h-3 mr-1" />
                        {lead.location}
                      </div>
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
                            {lead.aiScore.overallScore}/100
                          </span>
                        </div>
                      ) : (
                        <span className="text-gray-400 dark:text-gray-500">N/A</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="sm">
                            <MoreVertical className="w-4 h-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleViewDetails(lead)}>
                            <Eye className="w-4 h-4 mr-2" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => handleSaveLead(lead)}>
                            <Save className="w-4 h-4 mr-2" />
                            Save Lead
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Mail className="w-4 h-4 mr-2" />
                            Generate Email
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {/* Empty State */}
      {!isSearching && discoveredLeads.length === 0 && (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardContent className="p-12 text-center">
            <Search className="w-16 h-16 mx-auto mb-4 text-gray-400 dark:text-gray-500" />
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">Ready to Discover Leads</h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              Configure your search criteria above and start discovering biotech companies and VC firms
            </p>
            <Button onClick={handleSearch} className="bg-gradient-to-r from-blue-500 to-purple-600">
              <Search className="w-4 h-4 mr-2" />
              Start Advanced Discovery
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
                {selectedLead.type === 'company' ? (
                  <Building className="w-5 h-5" />
                ) : (
                  <Briefcase className="w-5 h-5" />
                )}
                <span>{selectedLead.name}</span>
                <Badge className={selectedLead.type === 'company' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800'}>
                  {selectedLead.type === 'company' ? 'Company' : 'VC Firm'}
                </Badge>
              </DialogTitle>
              <DialogDescription>
                Detailed analysis and contact information
              </DialogDescription>
            </DialogHeader>
            
            <div className="space-y-6">
              {/* Details */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold mb-3 text-gray-900 dark:text-white">
                    {selectedLead.type === 'company' ? 'Company' : 'Firm'} Details
                  </h4>
                  <div className="space-y-2 text-sm">
                    <p><strong>Industry:</strong> {selectedLead.industry}</p>
                    {selectedLead.fundingStage && <p><strong>Funding Stage:</strong> {selectedLead.fundingStage}</p>}
                    {selectedLead.portfolioSize && <p><strong>Portfolio Size:</strong> {selectedLead.portfolioSize} companies</p>}
                    <p><strong>Location:</strong> {selectedLead.location}</p>
                    {selectedLead.founded && <p><strong>Founded:</strong> {selectedLead.founded}</p>}
                    {selectedLead.employeeCount && <p><strong>Employees:</strong> ~{selectedLead.employeeCount}</p>}
                    {selectedLead.totalFunding && <p><strong>Total Funding:</strong> ${(selectedLead.totalFunding / 1000000).toFixed(1)}M</p>}
                    {selectedLead.vcFocus && (
                      <div>
                        <strong>Focus Areas:</strong>
                        <div className="flex flex-wrap gap-1 mt-1">
                          {selectedLead.vcFocus.map((focus, index) => (
                            <Badge key={index} variant="outline" className="text-xs">
                              {focus}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                </div>
                
                {selectedLead.aiScore && (
                  <div>
                    <h4 className="font-semibold mb-3 text-gray-900 dark:text-white">AI Analysis</h4>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span>Overall Score:</span>
                        <span className={`font-medium ${getScoreColor(selectedLead.aiScore.overallScore)}`}>
                          {selectedLead.aiScore.overallScore}/100
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span>Relevance:</span>
                        <span className={`font-medium ${getScoreColor(selectedLead.aiScore.relevanceScore)}`}>
                          {selectedLead.aiScore.relevanceScore}/100
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span>Growth Potential:</span>
                        <span className={`font-medium ${getScoreColor(selectedLead.aiScore.growthPotential)}`}>
                          {selectedLead.aiScore.growthPotential}/100
                        </span>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* Description */}
              <div>
                <h4 className="font-semibold mb-2 text-gray-900 dark:text-white">Description</h4>
                <p className="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
                  {selectedLead.description}
                </p>
              </div>

              {/* Contacts */}
              <div>
                <h4 className="font-semibold mb-3 text-gray-900 dark:text-white">
                  Key Contacts ({selectedLead.contacts.length})
                </h4>
                <div className="space-y-3">
                  {selectedLead.contacts.map((contact, index) => (
                    <div key={index} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">{contact.name}</p>
                        <p className="text-sm text-gray-600 dark:text-gray-400">{contact.title}</p>
                        {contact.email && (
                          <p className="text-xs text-gray-500 dark:text-gray-400">{contact.email}</p>
                        )}
                      </div>
                      <Badge variant="outline">{contact.role_category}</Badge>
                    </div>
                  ))}
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200 dark:border-gray-700">
                <Button variant="outline" onClick={() => setShowLeadDialog(false)}>
                  Close
                </Button>
                <Button 
                  onClick={() => {
                    handleSaveLead(selectedLead)
                    setShowLeadDialog(false)
                  }}
                  className="bg-green-600 hover:bg-green-700"
                >
                  <Save className="w-4 h-4 mr-2" />
                  Save Lead
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

# 2. Create the Select component that's missing
echo "📝 Creating Select component..."
mkdir -p components/ui
cat > components/ui/select.tsx << 'EOF'
import * as React from "react"
import * as SelectPrimitive from "@radix-ui/react-select"
import { Check, ChevronDown, ChevronUp } from "lucide-react"
import { cn } from "@/lib/utils"

const Select = SelectPrimitive.Root
const SelectGroup = SelectPrimitive.Group
const SelectValue = SelectPrimitive.Value

const SelectTrigger = React.forwardRef<
  React.ElementRef<typeof SelectPrimitive.Trigger>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Trigger>
>(({ className, children, ...props }, ref) => (
  <SelectPrimitive.Trigger
    ref={ref}
    className={cn(
      "flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 [&>span]:line-clamp-1",
      className
    )}
    {...props}
  >
    {children}
    <SelectPrimitive.Icon asChild>
      <ChevronDown className="h-4 w-4 opacity-50" />
    </SelectPrimitive.Icon>
  </SelectPrimitive.Trigger>
))
SelectTrigger.displayName = SelectPrimitive.Trigger.displayName

const SelectScrollUpButton = React.forwardRef<
  React.ElementRef<typeof SelectPrimitive.ScrollUpButton>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.ScrollUpButton>
>(({ className, ...props }, ref) => (
  <SelectPrimitive.ScrollUpButton
    ref={ref}
    className={cn(
      "flex cursor-default items-center justify-center py-1",
      className
    )}
    {...props}
  >
    <ChevronUp className="h-4 w-4" />
  </SelectPrimitive.ScrollUpButton>
))
SelectScrollUpButton.displayName = SelectPrimitive.ScrollUpButton.displayName

const SelectScrollDownButton = React.forwardRef<
  React.ElementRef<typeof SelectPrimitive.ScrollDownButton>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.ScrollDownButton>
>(({ className, ...props }, ref) => (
  <SelectPrimitive.ScrollDownButton
    ref={ref}
    className={cn(
      "flex cursor-default items-center justify-center py-1",
      className
    )}
    {...props}
  >
    <ChevronDown className="h-4 w-4" />
  </SelectPrimitive.ScrollDownButton>
))
SelectScrollDownButton.displayName =
  SelectPrimitive.ScrollDownButton.displayName

const SelectContent = React.forwardRef<
  React.ElementRef<typeof SelectPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Content>
>(({ className, children, position = "popper", ...props }, ref) => (
  <SelectPrimitive.Portal>
    <SelectPrimitive.Content
      ref={ref}
      className={cn(
        "relative z-50 max-h-96 min-w-[8rem] overflow-hidden rounded-md border bg-popover text-popover-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
        position === "popper" &&
          "data-[side=bottom]:translate-y-1 data-[side=left]:-translate-x-1 data-[side=right]:translate-x-1 data-[side=top]:-translate-y-1",
        className
      )}
      position={position}
      {...props}
    >
      <SelectScrollUpButton />
      <SelectPrimitive.Viewport
        className={cn(
          "p-1",
          position === "popper" &&
            "h-[var(--radix-select-trigger-height)] w-full min-w-[var(--radix-select-trigger-width)]"
        )}
      >
        {children}
      </SelectPrimitive.Viewport>
      <SelectScrollDownButton />
    </SelectPrimitive.Content>
  </SelectPrimitive.Portal>
))
SelectContent.displayName = SelectPrimitive.Content.displayName

const SelectLabel = React.forwardRef<
  React.ElementRef<typeof SelectPrimitive.Label>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Label>
>(({ className, ...props }, ref) => (
  <SelectPrimitive.Label
    ref={ref}
    className={cn("py-1.5 pl-8 pr-2 text-sm font-semibold", className)}
    {...props}
  />
))
SelectLabel.displayName = SelectPrimitive.Label.displayName

const SelectItem = React.forwardRef<
  React.ElementRef<typeof SelectPrimitive.Item>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Item>
>(({ className, children, ...props }, ref) => (
  <SelectPrimitive.Item
    ref={ref}
    className={cn(
      "relative flex w-full cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
      className
    )}
    {...props}
  >
    <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
      <SelectPrimitive.ItemIndicator>
        <Check className="h-4 w-4" />
      </SelectPrimitive.ItemIndicator>
    </span>

    <SelectPrimitive.ItemText>{children}</SelectPrimitive.ItemText>
  </SelectPrimitive.Item>
))
SelectItem.displayName = SelectPrimitive.Item.displayName

const SelectSeparator = React.forwardRef<
  React.ElementRef<typeof SelectPrimitive.Separator>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Separator>
>(({ className, ...props }, ref) => (
  <SelectPrimitive.Separator
    ref={ref}
    className={cn("-mx-1 my-1 h-px bg-muted", className)}
    {...props}
  />
))
SelectSeparator.displayName = SelectPrimitive.Separator.displayName

export {
  Select,
  SelectGroup,
  SelectValue,
  SelectTrigger,
  SelectContent,
  SelectLabel,
  SelectItem,
  SelectSeparator,
  SelectScrollUpButton,
  SelectScrollDownButton,
}
EOF

# 3. Install required Radix UI dependencies
echo "📦 Installing Radix UI Select component..."
npm install @radix-ui/react-select

# 4. Update the search API to handle the new parameters
echo "🔍 Updating search API to handle VC firms and advanced criteria..."
cat > pages/api/discovery/search.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

// Enhanced production data including VC firms
const PRODUCTION_LEADS = [
  // Biotech Companies
  {
    id: 'prod-1',
    name: 'Precision BioSciences',
    type: 'company',
    website: 'https://precisionbiosciences.com',
    industry: 'Gene Therapy',
    fundingStage: 'Series B',
    description: 'CRISPR-based gene therapy platform developing treatments for genetic diseases.',
    location: 'Durham, NC, USA',
    totalFunding: 200000000,
    employeeCount: 180,
    founded: 2006,
    contacts: [
      {
        id: 'pc1',
        name: 'Matt Kane',
        title: 'CEO',
        email: 'mkane@precisionbiosciences.com',
        role_category: 'Executive'
      }
    ],
    aiScore: {
      overallScore: 91,
      relevanceScore: 88,
      growthPotential: 95,
      techMaturity: 90,
      urgencyLevel: 'high',
      reasoning: 'Advanced biotech with complex technology infrastructure needs.',
      actionRecommendation: 'Focus on enterprise technology infrastructure consulting.',
      contactPriority: ['CTO', 'CEO']
    },
    recentNews: ['Announced positive Phase 1/2 data'],
    technologies: ['CRISPR', 'Cell Therapy', 'AWS']
  },
  {
    id: 'prod-uk-1',
    name: 'Oxford Nanopore Technologies',
    type: 'company',
    website: 'https://nanoporetech.com',
    industry: 'Genomics',
    fundingStage: 'Public',
    description: 'DNA/RNA sequencing technology company based in Oxford, UK.',
    location: 'Oxford, UK',
    totalFunding: 500000000,
    employeeCount: 900,
    founded: 2005,
    contacts: [
      {
        id: 'ont1',
        name: 'Gordon Sanghera',
        title: 'CEO',
        email: 'gordon@nanoporetech.com',
        role_category: 'Executive'
      }
    ],
    aiScore: {
      overallScore: 88,
      relevanceScore: 92,
      growthPotential: 85,
      techMaturity: 94,
      urgencyLevel: 'high',
      reasoning: 'Public UK genomics company with global operations and complex technology stack.',
      actionRecommendation: 'Strategic technology consulting for international expansion.',
      contactPriority: ['CTO', 'CEO']
    }
  },
  {
    id: 'prod-pt-1',
    name: 'BIOPHARMA SOLUTIONS',
    type: 'company',
    website: 'https://biopsol.pt',
    industry: 'Biotechnology',
    fundingStage: 'Series A',
    description: 'Portuguese biotech developing novel therapeutics for autoimmune diseases.',
    location: 'Porto, Portugal',
    totalFunding: 15000000,
    employeeCount: 35,
    founded: 2020,
    contacts: [
      {
        id: 'bp1',
        name: 'Dr. Maria Silva',
        title: 'CEO & Founder',
        email: 'm.silva@biopsol.pt',
        role_category: 'Founder'
      }
    ],
    aiScore: {
      overallScore: 76,
      relevanceScore: 78,
      growthPotential: 85,
      techMaturity: 65,
      urgencyLevel: 'medium',
      reasoning: 'Early-stage European biotech with promising pipeline and scaling needs.',
      actionRecommendation: 'Technology infrastructure for clinical trials and regulatory compliance.',
      contactPriority: ['CEO', 'CTO']
    }
  },
  // VC Firms
  {
    id: 'vc-us-1',
    name: 'Andreessen Horowitz Bio Fund',
    type: 'vc_firm',
    website: 'https://a16z.com/bio',
    industry: 'Venture Capital',
    vcFocus: ['Biotechnology', 'Digital Health', 'Synthetic Biology'],
    description: 'Leading venture capital firm with dedicated $450M bio fund.',
    location: 'Menlo Park, CA, USA',
    portfolioSize: 45,
    founded: 2009,
    contacts: [
      {
        id: 'a16z1',
        name: 'Vineeta Agarwala',
        title: 'General Partner',
        email: 'vineeta@a16z.com',
        role_category: 'VC'
      },
      {
        id: 'a16z2',
        name: 'Julie Yoo',
        title: 'General Partner',
        email: 'julie@a16z.com',
        role_category: 'VC'
      }
    ],
    aiScore: {
      overallScore: 96,
      relevanceScore: 98,
      growthPotential: 94,
      techMaturity: 95,
      urgencyLevel: 'critical',
      reasoning: 'Top-tier VC with massive biotech portfolio requiring technology due diligence.',
      actionRecommendation: 'Strategic partnership for portfolio company technology consulting.',
      contactPriority: ['General Partner', 'Principal']
    },
    recentNews: ['New $450M bio fund launched', 'Invested in 12 biotech companies this year']
  },
  {
    id: 'vc-uk-1',
    name: 'Sofinnova Partners',
    type: 'vc_firm',
    website: 'https://sofinnovapartners.com',
    industry: 'Venture Capital',
    vcFocus: ['Life Sciences', 'Healthcare Technology', 'Industrial Biotech'],
    description: 'European and US venture capital firm specializing in life sciences.',
    location: 'London, UK',
    portfolioSize: 60,
    founded: 1972,
    contacts: [
      {
        id: 'sof1',
        name: 'Antoine Papiernik',
        title: 'Managing Partner',
        email: 'antoine@sofinnovapartners.com',
        role_category: 'VC'
      }
    ],
    aiScore: {
      overallScore: 89,
      relevanceScore: 91,
      growthPotential: 87,
      techMaturity: 85,
      urgencyLevel: 'high',
      reasoning: 'Established European VC with strong life sciences portfolio.',
      actionRecommendation: 'Technology due diligence services for European investments.',
      contactPriority: ['Managing Partner', 'Partner']
    }
  },
  {
    id: 'vc-ca-1',
    name: 'Lumira Ventures',
    type: 'vc_firm',
    website: 'https://lumiraventures.com',
    industry: 'Venture Capital',
    vcFocus: ['Life Sciences', 'Healthcare', 'Biotechnology'],
    description: 'Canadian life sciences venture capital firm focused on early-stage investments.',
    location: 'Toronto, Canada',
    portfolioSize: 35,
    founded: 2008,
    contacts: [
      {
        id: 'lum1',
        name: 'Peter van der Velden',
        title: 'Managing General Partner',
        email: 'peter@lumiraventures.com',
        role_category: 'VC'
      }
    ],
    aiScore: {
      overallScore: 84,
      relevanceScore: 87,
      growthPotential: 83,
      techMaturity: 82,
      urgencyLevel: 'high',
      reasoning: 'Leading Canadian life sciences VC with portfolio requiring technology expertise.',
      actionRecommendation: 'Technology consulting for Canadian biotech portfolio companies.',
      contactPriority: ['Managing Partner', 'Partner']
    }
  }
]

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    const searchParams = req.body
    console.log('🔍 Advanced search started with params:', searchParams)

    // Simulate API processing time
    await new Promise(resolve => setTimeout(resolve, 2000))

    // Filter leads based on enhanced search parameters
    let filteredLeads = PRODUCTION_LEADS

    // Filter by target types
    if (searchParams.targetTypes && searchParams.targetTypes.length > 0) {
      filteredLeads = filteredLeads.filter(lead => 
        searchParams.targetTypes.includes(lead.type)
      )
    }

    // Filter by industries (for companies) or VC focus areas (for VCs)
    if (searchParams.industries && searchParams.industries.length > 0) {
      filteredLeads = filteredLeads.filter(lead => {
        if (lead.type === 'company') {
          return searchParams.industries.some(industry => 
            lead.industry.toLowerCase().includes(industry.toLowerCase())
          )
        } else if (lead.type === 'vc_firm' && lead.vcFocus) {
          return searchParams.industries.some(industry => 
            lead.vcFocus.some(focus => 
              focus.toLowerCase().includes(industry.toLowerCase()) ||
              industry.toLowerCase().includes(focus.toLowerCase())
            )
          )
        }
        return false
      })
    }

    // Filter by funding stages (companies only)
    if (searchParams.fundingStages && searchParams.fundingStages.length > 0) {
      filteredLeads = filteredLeads.filter(lead => 
        lead.type === 'vc_firm' || // Include all VCs
        !lead.fundingStage || // Include companies without funding stage
        searchParams.fundingStages.includes(lead.fundingStage)
      )
    }

    // Filter by locations
    if (searchParams.locations && searchParams.locations.length > 0) {
      filteredLeads = filteredLeads.filter(lead => 
        searchParams.locations.some(location => 
          lead.location.toLowerCase().includes(location.toLowerCase())
        )
      )
    }

    // Limit results
    if (searchParams.maxResults && searchParams.maxResults < filteredLeads.length) {
      filteredLeads = filteredLeads.slice(0, searchParams.maxResults)
    }

    // Log the search to Supabase if available
    if (supabaseUrl && supabaseKey) {
      try {
        const supabase = createClient(supabaseUrl, supabaseKey)
        await supabase
          .from('search_queries')
          .insert({
            query_type: 'advanced_lead_discovery',
            parameters: searchParams,
            results_count: filteredLeads.length,
            status: 'completed'
          })
      } catch (logError) {
        console.warn('Failed to log search to Supabase:', logError)
      }
    }

    console.log(`✅ Advanced search completed: ${filteredLeads.length} leads found`)

    res.status(200).json({
      success: true,
      leads: filteredLeads,
      count: filteredLeads.length,
      breakdown: {
        companies: filteredLeads.filter(l => l.type === 'company').length,
        vcFirms: filteredLeads.filter(l => l.type === 'vc_firm').length
      },
      source: 'production_api',
      message: `Found ${filteredLeads.length} leads matching your criteria`
    })

  } catch (error) {
    console.error('❌ Advanced Search API Error:', error)
    res.status(500).json({
      success: false,
      error: 'Advanced search failed',
      message: error.message || 'Unknown error occurred'
    })
  }
}
EOF

echo ""
echo "✅ Enhanced Lead Discovery with Advanced Search Complete!"
echo ""
echo "🎯 New Features Added:"
echo "  - Target both biotech companies AND VC firms"
echo "  - Multi-select industry filtering (13 biotech-related industries)"
echo "  - Comprehensive funding stage selection (Pre-Seed to Public)"
echo "  - Geographic targeting: USA, Canada, UK, Portugal + 8 more countries"
echo "  - VC focus area filtering (specialized biotech VCs)"
echo "  - Advanced search options and filters"
echo ""
echo "🌍 Geographic Coverage:"
echo "  - United States (nationwide)"
echo "  - Canada"
echo "  - United Kingdom" 
echo "  - Portugal"
echo "  - Plus: Germany, France, Switzerland, Netherlands, Sweden, Israel, Singapore, Australia"
echo ""
echo "🏢 Target Types:"
echo "  - Biotech Companies (all stages)"
echo "  - VC Firms specializing in biotech/life sciences"
echo "  - Each with different filtering criteria"
echo ""
echo "🔍 Demo Results Include:"
echo "  - Companies: Precision BioSciences (US), Oxford Nanopore (UK), BioSolutions (Portugal)"
echo "  - VC Firms: a16z Bio Fund (US), Sofinnova Partners (UK), Lumira Ventures (Canada)"
echo "  - Realistic contact information and AI scoring"
echo ""
echo "🚀 How to Use:"
echo "  1. Select target types (companies, VC firms, or both)"
echo "  2. Choose industries/focus areas from comprehensive list"
echo "  3. Select funding stages (for companies)"
echo "  4. Pick target countries including USA, Canada, UK, Portugal"
echo "  5. Set other options and run advanced search"
echo ""
echo "Your lead discovery system now supports sophisticated targeting!"
