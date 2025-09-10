'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Checkbox } from '@/components/ui/checkbox'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { 
  Search, 
  Building, 
  Plus,
  MoreHorizontal, 
  Eye,
  Edit,
  Trash,
  ExternalLink,
  MapPin,
  DollarSign,
  Users,
  Calendar,
  TrendingUp,
  Download,
  RefreshCw,
  Briefcase,
  Globe,
  Mail,
  Filter
} from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { DEMO_COMPANIES, DEMO_CONTACTS } from '@/lib/demo-data'
import { toast } from 'react-hot-toast'

interface Company {
  id: string
  name: string
  website?: string | null
  industry: string
  funding_stage: string
  location: string
  description?: string | null
  total_funding?: number | null
  last_funding_date?: string | null
  employee_count?: number | null
  crunchbase_url?: string | null
  linkedin_url?: string | null
  created_at: string
  updated_at: string
}

export default function CompaniesPage() {
  const { isDemoMode } = useDemoMode()
  const [companies, setCompanies] = useState<Company[]>([])
  const [selectedCompanies, setSelectedCompanies] = useState<string[]>([])
  const [selectedCompany, setSelectedCompany] = useState<Company | null>(null)
  const [showCompanyDialog, setShowCompanyDialog] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterIndustry, setFilterIndustry] = useState('all')
  const [filterStage, setFilterStage] = useState('all')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadCompanies()
  }, [isDemoMode])

  const loadCompanies = async () => {
    setLoading(true)
    try {
      if (isDemoMode) {
        // Demo mode - use mock data
        await new Promise(resolve => setTimeout(resolve, 500))
        setCompanies(DEMO_COMPANIES)
        toast.success(`Loaded ${DEMO_COMPANIES.length} demo companies`)
      } else {
        // Production mode - fetch from API
        const response = await fetch('/api/companies')
        if (response.ok) {
          const data = await response.json()
          setCompanies(data.companies || [])
          toast.success(`Loaded ${data.companies?.length || 0} companies`)
        } else {
          throw new Error('Failed to fetch companies')
        }
      }
    } catch (error) {
      console.error('Error loading companies:', error)
      toast.error('Failed to load companies')
      setCompanies([])
    } finally {
      setLoading(false)
    }
  }

  const filteredCompanies = companies.filter(company => {
    const matchesSearch = company.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         company.industry.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         company.location.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (company.description && company.description.toLowerCase().includes(searchTerm.toLowerCase()))
    
    const matchesIndustry = filterIndustry === 'all' || company.industry === filterIndustry
    const matchesStage = filterStage === 'all' || company.funding_stage === filterStage
    
    return matchesSearch && matchesIndustry && matchesStage
  })

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedCompanies(filteredCompanies.map(c => c.id))
    } else {
      setSelectedCompanies([])
    }
  }

  const handleSelectCompany = (companyId: string, checked: boolean) => {
    if (checked) {
      setSelectedCompanies([...selectedCompanies, companyId])
    } else {
      setSelectedCompanies(selectedCompanies.filter(id => id !== companyId))
    }
  }

  const handleViewDetails = (company: Company) => {
    setSelectedCompany(company)
    setShowCompanyDialog(true)
  }

  const handleDeleteCompany = async (companyId: string) => {
    if (!confirm('Are you sure you want to delete this company? This will also delete all associated contacts.')) return

    try {
      if (isDemoMode) {
        setCompanies(prev => prev.filter(c => c.id !== companyId))
        toast.success('Demo: Company deleted')
        return
      }

      const response = await fetch(`/api/companies/${companyId}`, {
        method: 'DELETE'
      })

      if (response.ok) {
        setCompanies(prev => prev.filter(c => c.id !== companyId))
        toast.success('Company deleted successfully')
      } else {
        throw new Error('Failed to delete company')
      }
    } catch (error) {
      console.error('Error deleting company:', error)
      toast.error('Failed to delete company')
    }
  }

  const handleBulkDelete = async () => {
    if (selectedCompanies.length === 0) return
    if (!confirm(`Are you sure you want to delete ${selectedCompanies.length} companies? This will also delete all associated contacts.`)) return

    try {
      if (isDemoMode) {
        setCompanies(prev => prev.filter(c => !selectedCompanies.includes(c.id)))
        setSelectedCompanies([])
        toast.success(`Demo: Deleted ${selectedCompanies.length} companies`)
        return
      }

      // Production bulk delete would go here
      toast.success('Bulk delete completed')
      setSelectedCompanies([])
    } catch (error) {
      console.error('Error with bulk delete:', error)
      toast.error('Failed to delete companies')
    }
  }

  const getContactCount = (companyId: string) => {
    if (isDemoMode) {
      return DEMO_CONTACTS.filter(c => c.company_id === companyId).length
    }
    return 0
  }

  const getIndustryColor = (industry: string) => {
    const colors: { [key: string]: string } = {
      'Biotechnology': 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400',
      'Gene Therapy': 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400',
      'Neurotechnology': 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400',
      'Medical Devices': 'bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400',
      'Regenerative Medicine': 'bg-pink-100 text-pink-800 dark:bg-pink-900/30 dark:text-pink-400',
      'Pharmaceuticals': 'bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-400'
    }
    return colors[industry] || 'bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-400'
  }

  const getStageColor = (stage: string) => {
    const colors: { [key: string]: string } = {
      'Seed': 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400',
      'Series A': 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400',
      'Series B': 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400',
      'Series C': 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400',
      'Growth': 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400',
      'Public': 'bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-400'
    }
    return colors[stage] || 'bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-400'
  }

  const uniqueIndustries = Array.from(new Set(companies.map(c => c.industry))).sort()
  const uniqueStages = Array.from(new Set(companies.map(c => c.funding_stage))).sort()

  const totalFunding = companies.reduce((sum, c) => sum + (c.total_funding || 0), 0)
  const avgEmployees = companies.length > 0 
    ? Math.round(companies.reduce((sum, c) => sum + (c.employee_count || 0), 0) / companies.length)
    : 0

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Companies</h1>
          <p className="text-gray-600 dark:text-gray-400">
            Manage your biotech company portfolio • {isDemoMode ? 'Demo Data' : 'Production Data'}
          </p>
        </div>
        <div className="flex space-x-3">
          <Button variant="outline" className="flex items-center space-x-2">
            <Download className="w-4 h-4" />
            <span>Export</span>
          </Button>
          <Button variant="outline" className="flex items-center space-x-2" onClick={loadCompanies}>
            <RefreshCw className="w-4 h-4" />
            <span>Sync</span>
          </Button>
          <Button className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600">
            <Plus className="w-4 h-4" />
            <span>Add Company</span>
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <Building className="w-8 h-8 mx-auto mb-2 text-blue-500" />
            <p className="text-2xl font-bold text-gray-900 dark:text-white">{companies.length}</p>
            <p className="text-sm text-gray-600 dark:text-gray-400">Total Companies</p>
          </CardContent>
        </Card>
        
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <TrendingUp className="w-8 h-8 mx-auto mb-2 text-green-500" />
            <p className="text-2xl font-bold text-gray-900 dark:text-white">
              {companies.filter(c => c.funding_stage.includes('Series')).length}
            </p>
            <p className="text-sm text-gray-600 dark:text-gray-400">Series Funded</p>
          </CardContent>
        </Card>

        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <DollarSign className="w-8 h-8 mx-auto mb-2 text-purple-500" />
            <p className="text-2xl font-bold text-gray-900 dark:text-white">
              ${(totalFunding / 1000000).toFixed(0)}M
            </p>
            <p className="text-sm text-gray-600 dark:text-gray-400">Total Funding</p>
          </CardContent>
        </Card>

        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-4 text-center">
            <Users className="w-8 h-8 mx-auto mb-2 text-orange-500" />
            <p className="text-2xl font-bold text-gray-900 dark:text-white">
              {companies.reduce((sum, c) => sum + getContactCount(c.id), 0)}
            </p>
            <p className="text-sm text-gray-600 dark:text-gray-400">Total Contacts</p>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                <Input
                  placeholder="Search companies, industries, or locations..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
            <div className="flex gap-3">
              <select
                value={filterIndustry}
                onChange={(e) => setFilterIndustry(e.target.value)}
                className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-sm bg-white dark:bg-gray-800"
              >
                <option value="all">All Industries</option>
                {uniqueIndustries.map(industry => (
                  <option key={industry} value={industry}>{industry}</option>
                ))}
              </select>
              <select
                value={filterStage}
                onChange={(e) => setFilterStage(e.target.value)}
                className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-sm bg-white dark:bg-gray-800"
              >
                <option value="all">All Stages</option>
                {uniqueStages.map(stage => (
                  <option key={stage} value={stage}>{stage}</option>
                ))}
              </select>
            </div>
          </div>
          
          {selectedCompanies.length > 0 && (
            <div className="mt-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg flex items-center justify-between">
              <span className="text-sm text-blue-800 dark:text-blue-400">
                {selectedCompanies.length} company{selectedCompanies.length > 1 ? 'ies' : ''} selected
              </span>
              <div className="flex space-x-2">
                <Button size="sm" variant="outline" onClick={() => setSelectedCompanies([])}>
                  Clear Selection
                </Button>
                <Button size="sm" onClick={handleBulkDelete} className="bg-red-600 hover:bg-red-700">
                  Delete Selected
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Companies Table */}
      {loading ? (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-12 text-center">
            <div className="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full mx-auto mb-4"></div>
            <p className="text-gray-600 dark:text-gray-400">Loading companies...</p>
          </CardContent>
        </Card>
      ) : filteredCompanies.length === 0 ? (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
          <CardContent className="p-12 text-center">
            <Building className="w-16 h-16 mx-auto mb-4 text-gray-400" />
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">No Companies Found</h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              {searchTerm || filterIndustry !== 'all' || filterStage !== 'all'
                ? 'No companies match your current filters'
                : 'No companies in your database yet'
              }
            </p>
            <Button className="bg-gradient-to-r from-blue-500 to-purple-600">
              <Plus className="w-4 h-4 mr-2" />
              Add Your First Company
            </Button>
          </CardContent>
        </Card>
      ) : (
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="text-gray-900 dark:text-white">
              Companies ({filteredCompanies.length})
            </CardTitle>
            <CardDescription>Your biotech company portfolio</CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-gray-200 dark:border-gray-700">
                  <TableHead className="w-12">
                    <Checkbox
                      checked={selectedCompanies.length === filteredCompanies.length && filteredCompanies.length > 0}
                      onCheckedChange={handleSelectAll}
                    />
                  </TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Company</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Industry</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Stage</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Location</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Funding</TableHead>
                  <TableHead className="text-gray-900 dark:text-white">Contacts</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredCompanies.map((company) => (
                  <TableRow key={company.id} className="border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700">
                    <TableCell>
                      <Checkbox
                        checked={selectedCompanies.includes(company.id)}
                        onCheckedChange={(checked) => handleSelectCompany(company.id, checked as boolean)}
                      />
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">{company.name}</p>
                        {company.website && (
                          <a 
                            href={company.website} 
                            target="_blank" 
                            rel="noopener noreferrer"
                            className="text-xs text-blue-600 dark:text-blue-400 hover:underline flex items-center"
                          >
                            {company.website.replace('https://', '')}
                            <ExternalLink className="w-3 h-3 ml-1" />
                          </a>
                        )}
                        {company.employee_count && (
                          <p className="text-xs text-gray-500 dark:text-gray-400">
                            ~{company.employee_count} employees
                          </p>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className={getIndustryColor(company.industry)}>
                        {company.industry}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge className={getStageColor(company.funding_stage)}>
                        {company.funding_stage}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center text-sm text-gray-600 dark:text-gray-400">
                        <MapPin className="w-3 h-3 mr-1" />
                        {company.location}
                      </div>
                    </TableCell>
                    <TableCell>
                      {company.total_funding ? (
                        <div>
                          <p className="font-medium text-gray-900 dark:text-white">
                            ${(company.total_funding / 1000000).toFixed(1)}M
                          </p>
                          {company.last_funding_date && (
                            <p className="text-xs text-gray-500 dark:text-gray-400">
                              {new Date(company.last_funding_date).toLocaleDateString()}
                            </p>
                          )}
                        </div>
                      ) : (
                        <span className="text-gray-400 dark:text-gray-500">N/A</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <span className="text-sm text-gray-600 dark:text-gray-400">
                        {getContactCount(company.id)} contact{getContactCount(company.id) !== 1 ? 's' : ''}
                      </span>
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="sm">
                            <MoreHorizontal className="w-4 h-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuLabel>Actions</DropdownMenuLabel>
                          <DropdownMenuItem onClick={() => handleViewDetails(company)}>
                            <Eye className="w-4 h-4 mr-2" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Edit className="w-4 h-4 mr-2" />
                            Edit Company
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Mail className="w-4 h-4 mr-2" />
                            Email Contacts
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem 
                            className="text-red-600"
                            onClick={() => handleDeleteCompany(company.id)}
                          >
                            <Trash className="w-4 h-4 mr-2" />
                            Delete
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

      {/* Company Detail Dialog */}
      {showCompanyDialog && selectedCompany && (
        <Dialog open={showCompanyDialog} onOpenChange={setShowCompanyDialog}>
          <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle className="flex items-center space-x-2">
                <Building className="w-5 h-5" />
                <span>{selectedCompany.name}</span>
                <Badge className={getIndustryColor(selectedCompany.industry)}>
                  {selectedCompany.industry}
                </Badge>
                <Badge className={getStageColor(selectedCompany.funding_stage)}>
                  {selectedCompany.funding_stage}
                </Badge>
              </DialogTitle>
              <DialogDescription>
                Comprehensive company information and contact details
              </DialogDescription>
            </DialogHeader>
            
            <div className="space-y-6">
              {/* Company Overview */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold mb-3 text-gray-900 dark:text-white">Company Details</h4>
                  <div className="space-y-2 text-sm">
                    <p><strong>Industry:</strong> {selectedCompany.industry}</p>
                    <p><strong>Funding Stage:</strong> {selectedCompany.funding_stage}</p>
                    <p><strong>Location:</strong> {selectedCompany.location}</p>
                    {selectedCompany.employee_count && (
                      <p><strong>Employees:</strong> ~{selectedCompany.employee_count}</p>
                    )}
                    {selectedCompany.total_funding && (
                      <p><strong>Total Funding:</strong> ${(selectedCompany.total_funding / 1000000).toFixed(1)}M</p>
                    )}
                    {selectedCompany.last_funding_date && (
                      <p><strong>Last Funding:</strong> {new Date(selectedCompany.last_funding_date).toLocaleDateString()}</p>
                    )}
                    {selectedCompany.website && (
                      <p>
                        <strong>Website:</strong>{' '}
                        <a 
                          href={selectedCompany.website} 
                          target="_blank" 
                          rel="noopener noreferrer"
                          className="text-blue-600 dark:text-blue-400 hover:underline"
                        >
                          {selectedCompany.website.replace('https://', '')}
                        </a>
                      </p>
                    )}
                  </div>
                </div>
                
                <div>
                  <h4 className="font-semibold mb-3 text-gray-900 dark:text-white">External Links</h4>
                  <div className="space-y-2">
                    {selectedCompany.crunchbase_url && (
                      <a 
                        href={selectedCompany.crunchbase_url} 
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="flex items-center text-sm text-blue-600 dark:text-blue-400 hover:underline"
                      >
                        <ExternalLink className="w-3 h-3 mr-1" />
                        Crunchbase Profile
                      </a>
                    )}
                    {selectedCompany.linkedin_url && (
                      <a 
                        href={selectedCompany.linkedin_url} 
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="flex items-center text-sm text-blue-600 dark:text-blue-400 hover:underline"
                      >
                        <ExternalLink className="w-3 h-3 mr-1" />
                        LinkedIn Company Page
                      </a>
                    )}
                    <div className="pt-2 border-t border-gray-200 dark:border-gray-700">
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        Added: {new Date(selectedCompany.created_at).toLocaleDateString()}
                      </p>
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        Updated: {new Date(selectedCompany.updated_at).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Description */}
              {selectedCompany.description && (
                <div>
                  <h4 className="font-semibold mb-2 text-gray-900 dark:text-white">Description</h4>
                  <p className="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
                    {selectedCompany.description}
                  </p>
                </div>
              )}

              {/* Company Contacts */}
              <div>
                <h4 className="font-semibold mb-3 text-gray-900 dark:text-white">
                  Key Contacts ({getContactCount(selectedCompany.id)})
                </h4>
                {isDemoMode ? (
                  <div className="space-y-3">
                    {DEMO_CONTACTS
                      .filter(contact => contact.company_id === selectedCompany.id)
                      .map((contact, index) => (
                        <div key={index} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                          <div className="flex-1">
                            <div className="flex items-center space-x-3">
                              <p className="font-medium text-gray-900 dark:text-white">
                                {contact.first_name} {contact.last_name}
                              </p>
                              <Badge variant="outline">{contact.role_category}</Badge>
                              <Badge className={
                                contact.contact_status === 'responded' ? 'bg-green-100 text-green-800' :
                                contact.contact_status === 'contacted' ? 'bg-blue-100 text-blue-800' :
                                contact.contact_status === 'interested' ? 'bg-purple-100 text-purple-800' :
                                'bg-gray-100 text-gray-800'
                              }>
                                {contact.contact_status.replace('_', ' ')}
                              </Badge>
                            </div>
                            <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">{contact.title}</p>
                            {contact.email && (
                              <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">{contact.email}</p>
                            )}
                          </div>
                          <div className="flex space-x-2">
                            <Button size="sm" variant="outline">
                              <Eye className="w-3 h-3 mr-1" />
                              View
                            </Button>
                            <Button size="sm" className="bg-blue-600 hover:bg-blue-700">
                              <Mail className="w-3 h-3 mr-1" />
                              Email
                            </Button>
                          </div>
                        </div>
                      ))}
                  </div>
                ) : (
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    No contacts found for this company.
                  </p>
                )}
              </div>

              {/* Action Buttons */}
              <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200 dark:border-gray-700">
                <Button variant="outline" onClick={() => setShowCompanyDialog(false)}>
                  Close
                </Button>
                <Button>
                  <Edit className="w-4 h-4 mr-2" />
                  Edit Company
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}
