#!/bin/bash

echo "Fixing Missing UI Components in Contacts Page"
echo "============================================="

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

echo "📄 Found contacts page: $CONTACTS_PAGE"

# Create backup
BACKUP_FILE="${CONTACTS_PAGE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CONTACTS_PAGE" "$BACKUP_FILE"
echo "💾 Backup created: $BACKUP_FILE"

# Create version without Label and Select components
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
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
  Database
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
      fetchContacts()
    }
  }, [isDemoMode, isLoaded])

  const fetchContacts = async () => {
    try {
      setLoading(true)
      setError(null)
      
      console.log('🔍 Fetching contacts...')
      
      const response = await fetch('/api/contacts', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
        cache: 'no-store'
      })
      
      console.log('📡 Response status:', response.status)
      console.log('📡 Response ok:', response.ok)
      
      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`HTTP ${response.status}: ${errorText}`)
      }
      
      const data = await response.json()
      console.log('📊 Response data received:', {
        success: data.success,
        contactCount: data.contacts?.length,
        source: data.source,
        firstContactName: data.contacts?.[0]?.first_name
      })
      
      // Make sure we're setting the contacts array properly
      const contactsArray = data.contacts || []
      console.log('📋 Setting contacts array with', contactsArray.length, 'contacts')
      setContacts(contactsArray)
      
      // Show success message
      const contactCount = contactsArray.length
      if (data.source === 'demo' || !data.source) {
        toast.success(`Loaded ${contactCount} demo contacts`)
      } else {
        toast.success(`Loaded ${contactCount} contacts from database`)
      }
      
    } catch (error) {
      console.error('❌ Failed to fetch contacts:', error)
      setError(error instanceof Error ? error.message : 'Unknown error occurred')
      toast.error(`Failed to load contacts: ${error instanceof Error ? error.message : 'Unknown error'}`)
      
      // Set empty array on error
      setContacts([])
    } finally {
      setLoading(false)
    }
  }

  const handleAddContact = async () => {
    try {
      setAddingContact(true)
      
      // Prepare the contact data
      const contactData = {
        first_name: newContact.first_name,
        last_name: newContact.last_name,
        email: newContact.email || null,
        phone: newContact.phone || null,
        title: newContact.title || null,
        role_category: newContact.role_category || null,
        linkedin_url: newContact.linkedin_url || null,
        companies: newContact.company_name ? {
          name: newContact.company_name,
          industry: newContact.company_industry || null,
          funding_stage: newContact.company_funding_stage || null
        } : null
      }
      
      console.log('➕ Adding new contact:', contactData)
      
      const response = await fetch('/api/contacts', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(contactData)
      })
      
      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.message || `HTTP ${response.status}`)
      }
      
      const result = await response.json()
      console.log('✅ Contact added:', result)
      
      // In demo mode, add the contact to the local state
      if (result.success && result.contact) {
        setContacts(prev => [result.contact, ...prev])
        toast.success(`Contact ${result.contact.first_name} ${result.contact.last_name} added successfully!`)
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

  // Show loading while context loads
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
                {isDemoMode ? 'Demo Data Active' : 'Production Data Connected'}
              </p>
              <p className={`text-sm ${isDemoMode ? 'text-blue-600 dark:text-blue-400' : 'text-green-600 dark:text-green-400'}`}>
                {isDemoMode 
                  ? 'Showing sample contacts for testing and exploration'
                  : 'Live contacts from your Supabase database'
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
              <div className="text-red-600 dark:text-red-400">
                <p className="font-medium">Connection Error</p>
                <p className="text-sm">{error}</p>
                <Button 
                  size="sm" 
                  variant="outline" 
                  onClick={fetchContacts}
                  className="mt-2 border-red-200 text-red-600 hover:bg-red-50"
                >
                  Try Again
                </Button>
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
                  {contacts.length === 0 ? 'No contacts found. Try refreshing or add a new contact.' : 'No contacts match your search.'}
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </Card>

      {/* Add Contact Dialog - Simplified version without Label and Select */}
      <Dialog open={showAddContactDialog} onOpenChange={setShowAddContactDialog}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>Add New Contact</DialogTitle>
            <DialogDescription>
              Add a new biotech industry contact to your database
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <label className="text-sm font-medium">First Name *</label>
                <Input
                  value={newContact.first_name}
                  onChange={(e) => setNewContact(prev => ({...prev, first_name: e.target.value}))}
                  placeholder="Sarah"
                />
              </div>
              <div className="grid gap-2">
                <label className="text-sm font-medium">Last Name *</label>
                <Input
                  value={newContact.last_name}
                  onChange={(e) => setNewContact(prev => ({...prev, last_name: e.target.value}))}
                  placeholder="Chen"
                />
              </div>
            </div>
            <div className="grid gap-2">
              <label className="text-sm font-medium">Email</label>
              <Input
                type="email"
                value={newContact.email}
                onChange={(e) => setNewContact(prev => ({...prev, email: e.target.value}))}
                placeholder="sarah.chen@company.com"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <label className="text-sm font-medium">Phone</label>
                <Input
                  value={newContact.phone}
                  onChange={(e) => setNewContact(prev => ({...prev, phone: e.target.value}))}
                  placeholder="+1-555-0123"
                />
              </div>
              <div className="grid gap-2">
                <label className="text-sm font-medium">Role Category</label>
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
            <div className="grid gap-2">
              <label className="text-sm font-medium">Job Title</label>
              <Input
                value={newContact.title}
                onChange={(e) => setNewContact(prev => ({...prev, title: e.target.value}))}
                placeholder="Chief Executive Officer"
              />
            </div>
            <div className="grid gap-2">
              <label className="text-sm font-medium">LinkedIn URL</label>
              <Input
                value={newContact.linkedin_url}
                onChange={(e) => setNewContact(prev => ({...prev, linkedin_url: e.target.value}))}
                placeholder="https://linkedin.com/in/sarah-chen"
              />
            </div>
            <div className="grid gap-2">
              <label className="text-sm font-medium">Company Name</label>
              <Input
                value={newContact.company_name}
                onChange={(e) => setNewContact(prev => ({...prev, company_name: e.target.value}))}
                placeholder="Nexus Therapeutics"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <label className="text-sm font-medium">Industry</label>
                <Input
                  value={newContact.company_industry}
                  onChange={(e) => setNewContact(prev => ({...prev, company_industry: e.target.value}))}
                  placeholder="Biotechnology"
                />
              </div>
              <div className="grid gap-2">
                <label className="text-sm font-medium">Funding Stage</label>
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
          <DialogFooter>
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
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Email Dialog */}
      <Dialog open={showEmailDialog} onOpenChange={setShowEmailDialog}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>Send Email Campaign</DialogTitle>
            <DialogDescription>
              Send an email to {selectedContacts.length} selected contact{selectedContacts.length > 1 ? 's' : ''}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Subject Line</label>
              <Input placeholder="Technology Due Diligence Partnership Opportunity" />
            </div>
            <div className="flex justify-end space-x-3">
              <Button variant="outline" onClick={() => setShowEmailDialog(false)}>
                Cancel
              </Button>
              <Button className="bg-gradient-to-r from-blue-500 to-purple-600">
                <Send className="w-4 h-4 mr-2" />
                Send Email Campaign
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Debug Info (remove in production) */}
      {contacts.length === 0 && !loading && (
        <Card className="border-0 shadow-sm bg-yellow-50 dark:bg-yellow-900/20">
          <CardContent className="p-4">
            <div className="text-yellow-800 dark:text-yellow-200">
              <p className="font-medium">Debug: No contacts loaded</p>
              <p className="text-sm">Check browser console for API response details</p>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
EOF

echo ""
echo "✅ Fixed Missing UI Components!"
echo "==============================="
echo ""
echo "Changes made:"
echo "• Removed @/components/ui/label import (using regular <label> tags)"
echo "• Removed @/components/ui/select import (using regular <select> elements)"  
echo "• Replaced Label components with <label> elements"
echo "• Replaced Select components with native <select> dropdowns"
echo "• Added proper styling classes to match your UI theme"
echo ""
echo "The contacts page should now:"
echo "• Load without component import errors"
echo "• Show the demo contacts properly"
echo "• Have a working Add Contact form with native dropdowns"
echo "• Maintain the same visual appearance"
echo ""
echo "All functionality preserved using only the UI components you already have installed."
echo ""
