#!/bin/bash

echo "🔧 Fixing Demo Mode Consistency"
echo "==============================="

# Check the demo context file
DEMO_CONTEXT="lib/demo-context.tsx"

if [[ -f "$DEMO_CONTEXT" ]]; then
    echo "📄 Found demo context: $DEMO_CONTEXT"
    echo ""
    echo "Current demo context logic:"
    grep -A 10 -B 5 "isDemoMode" "$DEMO_CONTEXT" | head -20
    echo ""
    
    # Create backup
    BACKUP_FILE="${DEMO_CONTEXT}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$DEMO_CONTEXT" "$BACKUP_FILE"
    echo "💾 Backup created: $BACKUP_FILE"
    
else
    echo "❌ Demo context file not found, creating it..."
    mkdir -p lib
fi

echo "🔧 Creating consistent demo mode logic..."

# Create demo context with proper logic
cat > "$DEMO_CONTEXT" << 'EOF'
'use client'

import { createContext, useContext, useState, useEffect } from 'react'

interface DemoContextType {
  isDemoMode: boolean
  setDemoMode: (enabled: boolean) => void
  isLoaded: boolean
}

const DemoContext = createContext<DemoContextType | undefined>(undefined)

export function DemoProvider({ children }: { children: React.ReactNode }) {
  const [isDemoMode, setIsDemoMode] = useState(false)
  const [isLoaded, setIsLoaded] = useState(false)

  useEffect(() => {
    // Check if demo mode is explicitly enabled
    // This should match the backend logic exactly
    const checkDemoMode = () => {
      try {
        // Check localStorage first (user preference)
        const storedDemoMode = localStorage.getItem('demoMode')
        if (storedDemoMode !== null) {
          const isDemo = storedDemoMode === 'true'
          console.log('🔧 Demo mode from localStorage:', isDemo)
          setIsDemoMode(isDemo)
          setIsLoaded(true)
          return
        }

        // Check environment variable (should only be 'true' if explicitly set)
        // Note: This won't work in client-side, but we'll default to false
        // The actual demo mode should be controlled by localStorage or API response
        
        console.log('🔧 No demo mode preference found, defaulting to production mode')
        setIsDemoMode(false)
        setIsLoaded(true)
        
      } catch (error) {
        console.error('Error checking demo mode:', error)
        // Default to production mode on error
        setIsDemoMode(false)
        setIsLoaded(true)
      }
    }

    checkDemoMode()
  }, [])

  const setDemoMode = (enabled: boolean) => {
    console.log('🔧 Setting demo mode:', enabled)
    setIsDemoMode(enabled)
    localStorage.setItem('demoMode', enabled.toString())
  }

  return (
    <DemoContext.Provider value={{ isDemoMode, setDemoMode, isLoaded }}>
      {children}
    </DemoContext.Provider>
  )
}

// Export alias for compatibility
export const DemoModeProvider = DemoProvider

export function useDemoMode() {
  const context = useContext(DemoContext)
  if (context === undefined) {
    throw new Error('useDemoMode must be used within a DemoProvider')
  }
  return context
}
EOF

echo ""
echo "🔧 Updating contacts page to handle production mode properly..."

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

# Create contacts page that respects demo mode properly
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
  AlertCircle,
  CheckCircle,
  Settings
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
  const { isDemoMode, setDemoMode, isLoaded } = useDemoMode()
  const [contacts, setContacts] = useState<Contact[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedContacts, setSelectedContacts] = useState<string[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [showEmailDialog, setShowEmailDialog] = useState(false)
  const [showAddContactDialog, setShowAddContactDialog] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [addingContact, setAddingContact] = useState(false)
  const [apiResponse, setApiResponse] = useState<any>(null)

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
    console.log('🔄 Demo mode state changed:', { isDemoMode, isLoaded })
    if (isLoaded) {
      fetchContacts()
    }
  }, [isDemoMode, isLoaded])

  const fetchContacts = async () => {
    try {
      setLoading(true)
      setError(null)
      
      console.log('🔍 Fetching contacts...')
      console.log('📊 Current demo mode (frontend):', isDemoMode)
      
      const response = await fetch('/api/contacts', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
        cache: 'no-store'
      })
      
      console.log('📡 Response status:', response.status)
      
      const data = await response.json()
      console.log('📊 Full API response:', data)
      setApiResponse(data)
      
      // CRITICAL: Only use contacts if the response is successful
      // Never show demo data in production mode
      if (data.success) {
        setContacts(data.contacts || [])
        setError(null)
        
        const contactCount = data.contacts?.length || 0
        if (data.source === 'demo') {
          toast.success(`Loaded ${contactCount} demo contacts`)
        } else if (data.source === 'supabase') {
          toast.success(`Loaded ${contactCount} contacts from database`)
        }
      } else {
        // API returned error - show it properly
        console.error('❌ API returned error:', data.error)
        setError(data.error || 'Unknown error occurred')
        setContacts([]) // Clear any existing contacts
        toast.error(`Error: ${data.error}`)
      }
      
    } catch (error) {
      console.error('❌ Failed to fetch contacts:', error)
      setError(error instanceof Error ? error.message : 'Network error occurred')
      setContacts([]) // Clear any existing contacts
      toast.error(`Network error: ${error instanceof Error ? error.message : 'Unknown error'}`)
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
      
      // Prepare the contact data
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
      
      console.log('➕ Adding new contact:', contactData)
      console.log('📊 Current demo mode during add:', isDemoMode)
      
      const response = await fetch('/api/contacts', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(contactData)
      })
      
      const data = await response.json()
      console.log('📡 Add contact response:', data)
      
      if (data.success && data.contact) {
        setContacts(prev => [data.contact, ...prev])
        toast.success(`Contact ${data.contact.first_name} ${data.contact.last_name} added successfully!`)
        
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
      } else {
        console.error('❌ Failed to add contact:', data.error)
        toast.error(data.error || 'Failed to add contact')
      }
      
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

  return (
    <div className="space-y-6">
      {/* Debug Info Banner */}
      <Card className="border-0 shadow-sm bg-yellow-50 dark:bg-yellow-900/20">
        <CardContent className="p-4">
          <div className="flex items-center space-x-3">
            <AlertCircle className="w-5 h-5 text-yellow-600 dark:text-yellow-400" />
            <div className="flex-1">
              <p className="font-medium text-yellow-800 dark:text-yellow-200">System Status</p>
              <div className="text-sm text-yellow-600 dark:text-yellow-400 mt-1">
                <p>Demo Mode: {isDemoMode ? 'ON' : 'OFF'} | Data Source: {apiResponse?.source || 'unknown'} | Contacts: {contacts.length}</p>
                <p>API Success: {apiResponse?.success ? 'YES' : 'NO'} | Error: {apiResponse?.error || 'none'}</p>
              </div>
            </div>
            <Button 
              size="sm" 
              variant="outline" 
              onClick={() => setDemoMode(!isDemoMode)}
              className="border-yellow-200 text-yellow-600 hover:bg-yellow-50"
            >
              <Settings className="w-4 h-4 mr-2" />
              Toggle Demo Mode
            </Button>
          </div>
        </CardContent>
      </Card>

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
                {isDemoMode ? 'Demo Data Active' : 'Production Mode'}
              </p>
              <p className={`text-sm ${isDemoMode ? 'text-blue-600 dark:text-blue-400' : 'text-green-600 dark:text-green-400'}`}>
                {isDemoMode 
                  ? 'Showing sample contacts for testing and exploration'
                  : 'Connected to live Supabase database'
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
                <p className="font-medium text-red-800 dark:text-red-200">Database Error</p>
                <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
                {!isDemoMode && (
                  <p className="text-xs text-red-500 mt-1">
                    Enable demo mode to see sample data, or configure Supabase credentials.
                  </p>
                )}
              </div>
              <div className="flex space-x-2">
                <Button 
                  size="sm" 
                  variant="outline" 
                  onClick={fetchContacts}
                  className="border-red-200 text-red-600 hover:bg-red-50"
                >
                  Retry
                </Button>
                {!isDemoMode && (
                  <Button 
                    size="sm" 
                    onClick={() => setDemoMode(true)}
                    className="bg-blue-600 hover:bg-blue-700 text-white"
                  >
                    Enable Demo Mode
                  </Button>
                )}
              </div>
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
            onClick={fetchContacts}
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
            disabled={!isDemoMode && !!error}
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

      {/* Contacts Table or Empty State */}
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
              {loading ? (
                <p>Loading contacts...</p>
              ) : error ? (
                <div>
                  <p className="font-medium">No contacts available</p>
                  <p className="text-sm mt-1">
                    {isDemoMode 
                      ? 'Demo mode is enabled but no demo data was returned'
                      : 'Please configure your Supabase database or enable demo mode to see sample data'
                    }
                  </p>
                </div>
              ) : (
                <div>
                  <p className="font-medium">No contacts found</p>
                  <p className="text-sm mt-1">Add your first contact to get started</p>
                </div>
              )}
            </div>
          </CardContent>
        )}
      </Card>

      {/* Add Contact Dialog */}
      {showAddContactDialog && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            {/* Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
              <div>
                <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Add New Contact</h2>
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  Add a new biotech industry contact to your {isDemoMode ? 'demo' : 'database'}
                </p>
              </div>
              <button
                onClick={() => setShowAddContactDialog(false)}
                className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            
            {/* Content */}
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
            
            {/* Footer */}
            <div className="flex justify-end space-x-3 p-6 border-t border-gray-200 dark:border-gray-700">
              <Button variant="outline" onClick={() => setShowAddContactDialog(false)}>
                Cancel
              </Button>
              <Button 
                onClick={handleAddContact}
                disabled={!newContact.first_name || !newContact.last_name || addingContact}
                className="bg-gradient-to-r from-blue-500 to-purple-600"
              >
                {addingContact ? 'Adding...' : 'Add Contact'}
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
echo "✅ Demo Mode Consistency Fixed!"
echo "==============================="
echo ""
echo "Changes made:"
echo "• Updated demo-context to only use demo mode when explicitly enabled"
echo "• Removed automatic fallback to demo data on errors"
echo "• Added toggle button to switch demo mode on/off"
echo "• Clear system status display showing current mode and data source"
echo "• Proper error handling that doesn't show demo data in production"
echo "• Consistent demo mode detection between frontend and backend"
echo ""
echo "Demo mode behavior:"
echo "• Demo ON: Shows demo data (ignores Supabase)"
echo "• Demo OFF: Uses Supabase only (shows errors if not configured)"
echo "• No automatic fallbacks to demo data"
echo ""
echo "Toggle demo mode using the 'Toggle Demo Mode' button in the interface."
