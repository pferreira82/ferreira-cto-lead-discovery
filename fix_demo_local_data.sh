#!/bin/bash

echo "🔧 Fixing Demo Mode to Use Local Mock Data"
echo "=========================================="

# Find the contacts page
CONTACTS_PAGE=""
if [[ -f "app/contacts/page.tsx" ]]; then
    CONTACTS_PAGE="app/contacts/page.tsx"
elif [[ -f "pages/contacts.tsx" ]]; then
    CONTACTS_PAGE="pages/contacts.tsx"
else
    echo "❌ Could not find contacts page"
    exit 1
fi

# Create backup
BACKUP_FILE="${CONTACTS_PAGE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CONTACTS_PAGE" "$BACKUP_FILE"
echo "💾 Backup created: $BACKUP_FILE"

echo "🔧 Creating contacts page with local demo data..."

cat > "$CONTACTS_PAGE" << 'EOF'
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
  Search, 
  Mail, 
  MoreHorizontal, 
  UserPlus,
  Download,
  RefreshCw,
  Send,
  Eye,
  Edit,
  Trash,
  Play,
  Database,
  X,
  AlertCircle
} from 'lucide-react'
import { toast } from 'react-hot-toast'
import { useDemoMode } from '@/lib/demo-context'

interface Contact {
  id: string
  company_id?: string
  first_name: string
  last_name: string
  email?: string
  phone?: string
  title?: string
  role_category?: 'VC' | 'Founder' | 'Board Member' | 'Executive'
  linkedin_url?: string
  contact_status?: 'not_contacted' | 'contacted' | 'responded' | 'interested' | 'not_interested'
  last_contacted_at?: string
  created_at: string
  updated_at: string
  companies?: {
    name: string
    industry?: string
    funding_stage?: string
  }
}

// Local demo data - no API calls needed
const DEMO_CONTACTS: Contact[] = [
  {
    id: 'demo-1',
    first_name: 'Sarah',
    last_name: 'Chen',
    email: 'sarah.chen@nexustherapeutics.com',
    phone: '+1-555-0123',
    title: 'Chief Executive Officer',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/sarah-chen',
    contact_status: 'not_contacted',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'Nexus Therapeutics',
      industry: 'Biotechnology',
      funding_stage: 'Series A'
    }
  },
  {
    id: 'demo-2',
    first_name: 'Michael',
    last_name: 'Rodriguez',
    email: 'mrodriguez@bioventures.com',
    phone: '+1-555-0456',
    title: 'Partner',
    role_category: 'VC',
    linkedin_url: 'https://linkedin.com/in/michael-rodriguez',
    contact_status: 'contacted',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'BioVentures Capital',
      industry: 'Venture Capital',
      funding_stage: 'N/A'
    }
  },
  {
    id: 'demo-3',
    first_name: 'Dr. Emily',
    last_name: 'Watson',
    email: 'emily.watson@genomicsinc.com',
    phone: '+1-555-0789',
    title: 'Chief Scientific Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/emily-watson-phd',
    contact_status: 'responded',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'Genomics Inc.',
      industry: 'Biotechnology',
      funding_stage: 'Series B'
    }
  },
  {
    id: 'demo-4',
    first_name: 'James',
    last_name: 'Park',
    email: 'j.park@medtechfund.com',
    phone: '+1-555-0321',
    title: 'Managing Partner',
    role_category: 'VC',
    linkedin_url: 'https://linkedin.com/in/jamespark',
    contact_status: 'interested',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'MedTech Fund',
      industry: 'Venture Capital',
      funding_stage: 'N/A'
    }
  },
  {
    id: 'demo-5',
    first_name: 'Dr. Lisa',
    last_name: 'Thompson',
    email: 'lisa.thompson@biorapid.com',
    phone: '+1-555-0654',
    title: 'Founder & CEO',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/lisathompson',
    contact_status: 'not_interested',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'BioRapid',
      industry: 'Biotechnology',
      funding_stage: 'Seed'
    }
  }
]

const statusColors = {
  'not_contacted': 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300',
  'contacted': 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400',
  'responded': 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400',
  'interested': 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400',
  'not_interested': 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
}

const roleColors = {
  'VC': 'bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-400',
  'Founder': 'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400',
  'Board Member': 'bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400',
  'Executive': 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400'
}

export default function ContactsPage() {
  const { isDemoMode, isLoaded } = useDemoMode()
  const [contacts, setContacts] = useState<Contact[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedContacts, setSelectedContacts] = useState<string[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [showEmailDialog, setShowEmailDialog] = useState(false)
  const [showAddContactDialog, setShowAddContactDialog] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [addingContact, setAddingContact] = useState(false)

  // New contact form state
  const [newContact, setNewContact] = useState({
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
    title: '',
    role_category: '',
    linkedin_url: '',
    company_name: '',
    company_industry: '',
    company_funding_stage: ''
  })

  useEffect(() => {
    if (isLoaded) {
      loadContacts()
    }
  }, [isDemoMode, isLoaded])

  const loadContacts = async () => {
    try {
      setLoading(true)
      setError(null)
      
      if (isDemoMode) {
        // Demo mode: Use local mock data, no API calls
        console.log('📊 Demo mode: Loading local mock data')
        setContacts(DEMO_CONTACTS)
        toast.success(`Loaded ${DEMO_CONTACTS.length} demo contacts`)
      } else {
        // Production mode: Call Supabase API
        console.log('🔍 Production mode: Fetching from Supabase API')
        
        const response = await fetch('/api/contacts', {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
          cache: 'no-store'
        })
        
        const data = await response.json()
        console.log('📡 API response:', data)
        
        if (data.success) {
          setContacts(data.contacts || [])
          toast.success(`Loaded ${data.contacts?.length || 0} contacts from database`)
        } else {
          throw new Error(data.error || 'Failed to load contacts')
        }
      }
      
    } catch (error) {
      console.error('❌ Failed to load contacts:', error)
      setError(error instanceof Error ? error.message : 'Unknown error occurred')
      toast.error(`Failed to load contacts: ${error instanceof Error ? error.message : 'Unknown error'}`)
      setContacts([])
    } finally {
      setLoading(false)
    }
  }

  const handleAddContact = async () => {
    try {
      setAddingContact(true)
      
      // Validate required fields
      if (!newContact.first_name.trim() || !newContact.last_name.trim()) {
        toast.error('First name and last name are required')
        return
      }
      
      if (isDemoMode) {
        // Demo mode: Add to local state only
        console.log('📊 Demo mode: Adding contact locally')
        
        const newDemoContact: Contact = {
          id: `demo-${Date.now()}`,
          first_name: newContact.first_name.trim(),
          last_name: newContact.last_name.trim(),
          email: newContact.email.trim() || undefined,
          phone: newContact.phone.trim() || undefined,
          title: newContact.title.trim() || undefined,
          role_category: newContact.role_category as any || undefined,
          linkedin_url: newContact.linkedin_url.trim() || undefined,
          contact_status: 'not_contacted',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          companies: newContact.company_name.trim() ? {
            name: newContact.company_name.trim(),
            industry: newContact.company_industry.trim() || undefined,
            funding_stage: newContact.company_funding_stage || undefined
          } : undefined
        }
        
        setContacts(prev => [newDemoContact, ...prev])
        toast.success(`Demo contact ${newDemoContact.first_name} ${newDemoContact.last_name} added!`)
        
      } else {
        // Production mode: Save to Supabase
        console.log('🔍 Production mode: Saving to Supabase')
        
        const contactData = {
          first_name: newContact.first_name.trim(),
          last_name: newContact.last_name.trim(),
          email: newContact.email.trim() || null,
          phone: newContact.phone.trim() || null,
          title: newContact.title.trim() || null,
          role_category: newContact.role_category || null,
          linkedin_url: newContact.linkedin_url.trim() || null,
          companies: newContact.company_name.trim() ? {
            name: newContact.company_name.trim(),
            industry: newContact.company_industry.trim() || null,
            funding_stage: newContact.company_funding_stage || null
          } : null
        }
        
        const response = await fetch('/api/contacts', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(contactData)
        })
        
        const data = await response.json()
        
        if (data.success && data.contact) {
          setContacts(prev => [data.contact, ...prev])
          toast.success(`Contact ${data.contact.first_name} ${data.contact.last_name} saved to database!`)
        } else {
          throw new Error(data.error || 'Failed to save contact')
        }
      }
      
      // Reset form and close dialog
      setNewContact({
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        title: '',
        role_category: '',
        linkedin_url: '',
        company_name: '',
        company_industry: '',
        company_funding_stage: ''
      })
      setShowAddContactDialog(false)
      
    } catch (error) {
      console.error('❌ Error adding contact:', error)
      toast.error(error instanceof Error ? error.message : 'Failed to add contact')
    } finally {
      setAddingContact(false)
    }
  }

  const filteredContacts = contacts.filter(contact => 
    contact.first_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    contact.last_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (contact.email && contact.email.toLowerCase().includes(searchTerm.toLowerCase())) ||
    (contact.companies?.name && contact.companies.name.toLowerCase().includes(searchTerm.toLowerCase()))
  )

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedContacts(filteredContacts.map(c => c.id))
    } else {
      setSelectedContacts([])
    }
  }

  const handleSelectContact = (contactId: string, checked: boolean) => {
    if (checked) {
      setSelectedContacts([...selectedContacts, contactId])
    } else {
      setSelectedContacts(selectedContacts.filter(id => id !== contactId))
    }
  }

  if (!isLoaded) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Loading...</h1>
          <p className="text-gray-600 dark:text-gray-400">Initializing contacts system...</p>
        </div>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Contacts</h1>
            <p className="text-gray-600 dark:text-gray-400">Loading contacts...</p>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[...Array(4)].map((_, i) => (
            <Card key={i} className="animate-pulse">
              <CardContent className="p-6">
                <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2 mb-2"></div>
                <div className="h-8 bg-gray-200 dark:bg-gray-700 rounded w-1/3"></div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
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
                  ? 'Using local mock data for testing and exploration'
                  : 'Connected to Supabase database'
                }
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Error Banner */}
      {error && (
        <Card className="border-0 shadow-sm bg-red-50 dark:bg-red-900/20">
          <CardContent className="p-4">
            <div className="flex items-center space-x-3">
              <AlertCircle className="w-5 h-5 text-red-600 dark:text-red-400" />
              <div className="flex-1">
                <p className="font-medium text-red-800 dark:text-red-200">Error Loading Contacts</p>
                <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
              </div>
              <Button 
                size="sm" 
                variant="outline" 
                onClick={loadContacts}
                className="border-red-200 text-red-600 hover:bg-red-50"
              >
                Retry
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Contacts</h1>
          <p className="text-gray-600 dark:text-gray-400">
            Manage your biotech industry contacts and outreach • {contacts.length} total contacts
          </p>
        </div>
        <div className="flex space-x-3">
          <Button 
            variant="outline" 
            onClick={loadContacts}
            className="flex items-center space-x-2"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Refresh</span>
          </Button>
          <Button variant="outline" className="flex items-center space-x-2">
            <Download className="w-4 h-4" />
            <span>Export</span>
          </Button>
          <Button 
            onClick={() => setShowAddContactDialog(true)}
            className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600"
          >
            <UserPlus className="w-4 h-4" />
            <span>Add Contact</span>
          </Button>
        </div>
      </div>

      {/* Search and Filters */}
      <Card className="border-0 shadow-sm">
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-gray-500 w-4 h-4" />
                <Input
                  placeholder="Search contacts, companies, or emails..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
          </div>
          
          {selectedContacts.length > 0 && (
            <div className="mt-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg flex items-center justify-between">
              <span className="text-sm text-blue-800 dark:text-blue-400">
                {selectedContacts.length} contact{selectedContacts.length > 1 ? 's' : ''} selected
              </span>
              <Button 
                size="sm" 
                onClick={() => setShowEmailDialog(true)}
                className="bg-blue-600 hover:bg-blue-700"
              >
                <Mail className="w-4 h-4 mr-2" />
                Send Email to Selected
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Contacts Table */}
      <Card className="border-0 shadow-sm">
        {contacts.length > 0 ? (
          <Table>
            <TableHeader>
              <TableRow className="bg-gray-50 dark:bg-gray-800">
                <TableHead className="w-12">
                  <Checkbox
                    checked={selectedContacts.length === filteredContacts.length && filteredContacts.length > 0}
                    onCheckedChange={handleSelectAll}
                  />
                </TableHead>
                <TableHead className="text-gray-900 dark:text-white">Contact</TableHead>
                <TableHead className="text-gray-900 dark:text-white">Company</TableHead>
                <TableHead className="text-gray-900 dark:text-white">Role</TableHead>
                <TableHead className="text-gray-900 dark:text-white">Status</TableHead>
                <TableHead className="text-gray-900 dark:text-white">Last Contact</TableHead>
                <TableHead className="text-gray-900 dark:text-white">Stage</TableHead>
                <TableHead className="w-12"></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredContacts.length > 0 ? (
                filteredContacts.map((contact) => (
                  <TableRow key={contact.id} className="hover:bg-gray-50 dark:hover:bg-gray-800">
                    <TableCell>
                      <Checkbox
                        checked={selectedContacts.includes(contact.id)}
                        onCheckedChange={(checked) => handleSelectContact(contact.id, checked as boolean)}
                      />
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-white">
                          {contact.first_name} {contact.last_name}
                        </p>
                        {contact.email && (
                          <p className="text-sm text-gray-500 dark:text-gray-400">{contact.email}</p>
                        )}
                        {contact.title && (
                          <p className="text-xs text-gray-400 dark:text-gray-500">{contact.title}</p>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div>
                        {contact.companies?.name && (
                          <>
                            <p className="font-medium text-gray-900 dark:text-white">{contact.companies.name}</p>
                            {contact.companies.industry && (
                              <p className="text-xs text-gray-400 dark:text-gray-500">{contact.companies.industry}</p>
                            )}
                          </>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      {contact.role_category && (
                        <Badge className={roleColors[contact.role_category]}>
                          {contact.role_category}
                        </Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      {contact.contact_status && (
                        <Badge className={statusColors[contact.contact_status]}>
                          {contact.contact_status.replace('_', ' ')}
                        </Badge>
                      )}
                    </TableCell>
                    <TableCell className="text-sm text-gray-600 dark:text-gray-400">
                      {contact.last_contacted_at 
                        ? new Date(contact.last_contacted_at).toLocaleDateString()
                        : 'Never'
                      }
                    </TableCell>
                    <TableCell>
                      {contact.companies?.funding_stage && (
                        <Badge variant="outline">{contact.companies.funding_stage}</Badge>
                      )}
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
                          <DropdownMenuItem>
                            <Eye className="w-4 h-4 mr-2" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Mail className="w-4 h-4 mr-2" />
                            Send Email
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Edit className="w-4 h-4 mr-2" />
                            Edit Contact
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem className="text-red-600 dark:text-red-400">
                            <Trash className="w-4 h-4 mr-2" />
                            Delete
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={8} className="text-center py-12 text-gray-500">
                    No contacts match your search.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        ) : (
          <CardContent className="p-12 text-center">
            <div className="text-gray-500">
              <p className="font-medium">No contacts found</p>
              <p className="text-sm mt-1">
                {isDemoMode 
                  ? 'No demo data available'
                  : error 
                    ? 'Unable to load from database'
                    : 'Add your first contact to get started'
                }
              </p>
            </div>
          </CardContent>
        )}
      </Card>

      {/* Add Contact Dialog */}
      {showAddContactDialog && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
              <div>
                <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Add New Contact</h2>
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  {isDemoMode ? 'Add to demo data (local only)' : 'Save to Supabase database'}
                </p>
              </div>
              <button
                onClick={() => setShowAddContactDialog(false)}
                className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            
            <div className="p-6">
              <div className="grid gap-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">First Name *</label>
                    <Input
                      value={newContact.first_name}
                      onChange={(e) => setNewContact(prev => ({...prev, first_name: e.target.value}))}
                      placeholder="Sarah"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Last Name *</label>
                    <Input
                      value={newContact.last_name}
                      onChange={(e) => setNewContact(prev => ({...prev, last_name: e.target.value}))}
                      placeholder="Chen"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Email</label>
                  <Input
                    type="email"
                    value={newContact.email}
                    onChange={(e) => setNewContact(prev => ({...prev, email: e.target.value}))}
                    placeholder="sarah.chen@company.com"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Phone</label>
                    <Input
                      value={newContact.phone}
                      onChange={(e) => setNewContact(prev => ({...prev, phone: e.target.value}))}
                      placeholder="+1-555-0123"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Role Category</label>
                    <select 
                      value={newContact.role_category} 
                      onChange={(e) => setNewContact(prev => ({...prev, role_category: e.target.value}))}
                      className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                      <option value="">Select role</option>
                      <option value="Founder">Founder</option>
                      <option value="Executive">Executive</option>
                      <option value="VC">VC</option>
                      <option value="Board Member">Board Member</option>
                    </select>
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Job Title</label>
                  <Input
                    value={newContact.title}
                    onChange={(e) => setNewContact(prev => ({...prev, title: e.target.value}))}
                    placeholder="Chief Executive Officer"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">LinkedIn URL</label>
                  <Input
                    value={newContact.linkedin_url}
                    onChange={(e) => setNewContact(prev => ({...prev, linkedin_url: e.target.value}))}
                    placeholder="https://linkedin.com/in/sarah-chen"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Company Name</label>
                  <Input
                    value={newContact.company_name}
                    onChange={(e) => setNewContact(prev => ({...prev, company_name: e.target.value}))}
                    placeholder="Nexus Therapeutics"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Industry</label>
                    <Input
                      value={newContact.company_industry}
                      onChange={(e) => setNewContact(prev => ({...prev, company_industry: e.target.value}))}
                      placeholder="Biotechnology"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Funding Stage</label>
                    <select 
                      value={newContact.company_funding_stage} 
                      onChange={(e) => setNewContact(prev => ({...prev, company_funding_stage: e.target.value}))}
                      className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                      <option value="">Select stage</option>
                      <option value="Seed">Seed</option>
                      <option value="Series A">Series A</option>
                      <option value="Series B">Series B</option>
                      <option value="Series C">Series C</option>
                      <option value="Growth">Growth</option>
                      <option value="Public">Public</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="flex justify-end space-x-3 p-6 border-t border-gray-200 dark:border-gray-700">
              <Button variant="outline" onClick={() => setShowAddContactDialog(false)}>
                Cancel
              </Button>
              <Button 
                onClick={handleAddContact}
                disabled={!newContact.first_name || !newContact.last_name || addingContact}
                className="bg-gradient-to-r from-blue-500 to-purple-600"
              >
                {addingContact ? 'Adding...' : isDemoMode ? 'Add to Demo' : 'Save to Database'}
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Email Dialog */}
      {showEmailDialog && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-2xl w-full mx-4">
            <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
              <div>
                <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Send Email Campaign</h2>
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  Send an email to {selectedContacts.length} selected contact{selectedContacts.length > 1 ? 's' : ''}
                </p>
              </div>
              <button
                onClick={() => setShowEmailDialog(false)}
                className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            <div className="p-6">
              <div>
                <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Subject Line</label>
                <Input placeholder="Technology Due Diligence Partnership Opportunity" />
              </div>
            </div>
            <div className="flex justify-end space-x-3 p-6 border-t border-gray-200 dark:border-gray-700">
              <Button variant="outline" onClick={() => setShowEmailDialog(false)}>
                Cancel
              </Button>
              <Button className="bg-gradient-to-r from-blue-500 to-purple-600">
                <Send className="w-4 h-4 mr-2" />
                Send Email Campaign
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
EOF

echo ""
echo "✅ Fixed Demo Mode Logic!"
echo "========================"
echo ""
echo "How it works now:"
echo ""
echo "DEMO MODE (isDemoMode = true):"
echo "• Uses local DEMO_CONTACTS array"
echo "• NO API calls to any service"
echo "• Adding contacts updates local state only"
echo "• Shows 5 mock contacts with realistic data"
echo ""
echo "PRODUCTION MODE (isDemoMode = false):"
echo "• Makes API calls to /api/contacts (Supabase)"
echo "• Adding contacts saves to Supabase database"
echo "• Shows real data from your database"
echo ""
echo "Your side nav toggle should now work perfectly:"
echo "• Toggle ON = Local mock data"
echo "• Toggle OFF = Supabase database"
echo "• No Apollo API calls anywhere"
echo ""
echo "Test it by toggling demo mode in your side nav!"
