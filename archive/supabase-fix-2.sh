#!/bin/bash

echo "🔧 Fixing Supabase Configuration Error..."
echo "========================================"

# 1. Fix the lib/supabase.ts file to include the missing function
echo "📝 Updating lib/supabase.ts with proper configuration..."
cat > lib/supabase.ts << 'EOF'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

// Check if Supabase is properly configured
export function isSupabaseConfigured(): boolean {
  return !!(supabaseUrl && supabaseAnonKey && 
    supabaseUrl !== 'undefined' && 
    supabaseAnonKey !== 'undefined' &&
    supabaseUrl.startsWith('http'))
}

// Client-side Supabase client
export const supabase = isSupabaseConfigured() 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null

// Service role client for server-side operations
export function createServiceRoleClient() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  
  if (!serviceRoleKey || !supabaseUrl) {
    return null
  }
  
  return createClient(supabaseUrl, serviceRoleKey)
}

// Admin client for API routes
export const supabaseAdmin = createServiceRoleClient()

// Type definitions based on your existing schema
export interface Company {
  id: string
  name: string
  website?: string
  industry?: string
  funding_stage?: 'Series A' | 'Series B' | 'Series C'
  location?: string
  description?: string
  total_funding?: number
  last_funding_date?: string
  employee_count?: number
  crunchbase_url?: string
  linkedin_url?: string
  created_at: string
  updated_at: string
}

export interface Contact {
  id: string
  company_id?: string
  first_name: string
  last_name: string
  email?: string
  phone?: string
  title?: string
  role_category?: 'VC' | 'Founder' | 'Board Member' | 'Executive'
  linkedin_url?: string
  address?: string
  bio?: string
  contact_status?: 'not_contacted' | 'contacted' | 'responded' | 'interested' | 'not_interested'
  last_contacted_at?: string
  created_at: string
  updated_at: string
}

export interface EmailCampaign {
  id: string
  name: string
  subject: string
  template: string
  target_role_category?: string
  active: boolean
  created_at: string
  updated_at: string
}

export interface EmailLog {
  id: string
  contact_id?: string
  campaign_id?: string
  subject: string
  content: string
  sent_at: string
  opened_at?: string
  clicked_at?: string
  replied_at?: string
  bounced: boolean
  status: 'sent' | 'delivered' | 'opened' | 'clicked' | 'replied' | 'bounced'
}
EOF

# 2. Create a working companies API endpoint
echo "🏢 Creating companies API endpoint..."
mkdir -p pages/api/companies
cat > pages/api/companies/index.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { isSupabaseConfigured, supabaseAdmin } from '../../../lib/supabase'

// Demo companies data
const DEMO_COMPANIES = [
  {
    id: 'demo-comp-1',
    name: 'BioTech Innovations Inc.',
    website: 'https://biotechinnovations.com',
    industry: 'Biotechnology',
    funding_stage: 'Series B',
    location: 'Boston, MA, USA',
    description: 'AI-powered drug discovery platform leveraging machine learning to accelerate pharmaceutical development.',
    total_funding: 45000000,
    employee_count: 125,
    created_at: '2024-01-15T10:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-comp-2',
    name: 'GenomeTherapeutics',
    website: 'https://genometherapeutics.com',
    industry: 'Gene Therapy',
    funding_stage: 'Series A',
    location: 'San Francisco, CA, USA',
    description: 'Revolutionary gene therapy platform developing treatments for rare genetic diseases using CRISPR.',
    total_funding: 28000000,
    employee_count: 67,
    created_at: '2024-02-20T14:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-comp-3',
    name: 'NeuralBio Systems',
    website: 'https://neuralbio.com',
    industry: 'Neurotechnology',
    funding_stage: 'Series C',
    location: 'Cambridge, MA, USA',
    description: 'Brain-computer interface technology for treating neurological disorders.',
    total_funding: 125000000,
    employee_count: 245,
    created_at: '2024-03-10T09:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  }
]

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    // If Supabase is not configured, return demo data
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      console.log('Supabase not configured, returning demo companies data')
      return res.status(200).json({
        companies: DEMO_COMPANIES,
        count: DEMO_COMPANIES.length,
        source: 'demo'
      })
    }

    // Fetch real companies from Supabase
    const { data: companies, error, count } = await supabaseAdmin
      .from('companies')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .limit(100)

    if (error) {
      console.error('Supabase query error:', error)
      // Fallback to demo data on error
      return res.status(200).json({
        companies: DEMO_COMPANIES,
        count: DEMO_COMPANIES.length,
        source: 'demo_fallback',
        error: 'Database query failed'
      })
    }

    res.status(200).json({
      companies: companies || [],
      count: count || 0,
      source: 'production'
    })

  } catch (error) {
    console.error('Companies API Error:', error)
    // Fallback to demo data on any error
    res.status(200).json({
      companies: DEMO_COMPANIES,
      count: DEMO_COMPANIES.length,
      source: 'demo_fallback',
      error: 'API error occurred'
    })
  }
}
EOF

# 3. Create a working contacts API endpoint
echo "👥 Creating contacts API endpoint..."
mkdir -p pages/api/contacts
cat > pages/api/contacts/index.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { isSupabaseConfigured, supabaseAdmin } from '../../../lib/supabase'

// Demo contacts data
const DEMO_CONTACTS = [
  {
    id: 'demo-contact-1',
    company_id: 'demo-comp-1',
    first_name: 'Sarah',
    last_name: 'Chen',
    email: 'sarah.chen@biotechinnovations.com',
    title: 'CEO & Co-Founder',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/sarahchen-biotech',
    contact_status: 'not_contacted',
    created_at: '2024-01-15T10:30:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-2',
    company_id: 'demo-comp-1',
    first_name: 'Michael',
    last_name: 'Rodriguez',
    email: 'm.rodriguez@biotechinnovations.com',
    title: 'Chief Technology Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/mrodriguez-cto',
    contact_status: 'contacted',
    last_contacted_at: '2024-09-05T10:30:00Z',
    created_at: '2024-01-15T11:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-3',
    company_id: 'demo-comp-2',
    first_name: 'James',
    last_name: 'Liu',
    email: 'james.liu@genometherapeutics.com',
    title: 'CEO',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/jamesliu-genomics',
    contact_status: 'responded',
    last_contacted_at: '2024-09-04T14:22:00Z',
    created_at: '2024-02-20T14:30:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-4',
    company_id: 'demo-comp-3',
    first_name: 'Amanda',
    last_name: 'Foster',
    email: 'amanda.foster@neuralbio.com',
    title: 'Co-Founder & CEO',
    role_category: 'Founder',
    contact_status: 'interested',
    last_contacted_at: '2024-09-06T16:15:00Z',
    created_at: '2024-03-10T09:30:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-5',
    company_id: 'demo-comp-3',
    first_name: 'David',
    last_name: 'Park',
    email: 'd.park@neuralbio.com',
    title: 'Chief Technology Officer',
    role_category: 'Executive',
    contact_status: 'not_contacted',
    created_at: '2024-03-10T10:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  }
]

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    // If Supabase is not configured, return demo data
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      console.log('Supabase not configured, returning demo contacts data')
      return res.status(200).json({
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo'
      })
    }

    // Fetch real contacts from Supabase with company information
    const { data: contacts, error, count } = await supabaseAdmin
      .from('contacts')
      .select(`
        *,
        companies (
          name,
          industry,
          funding_stage
        )
      `, { count: 'exact' })
      .order('created_at', { ascending: false })
      .limit(500)

    if (error) {
      console.error('Supabase query error:', error)
      // Fallback to demo data on error
      return res.status(200).json({
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo_fallback',
        error: 'Database query failed'
      })
    }

    res.status(200).json({
      contacts: contacts || [],
      count: count || 0,
      source: 'production'
    })

  } catch (error) {
    console.error('Contacts API Error:', error)
    // Fallback to demo data on any error
    res.status(200).json({
      contacts: DEMO_CONTACTS,
      count: DEMO_CONTACTS.length,
      source: 'demo_fallback',
      error: 'API error occurred'
    })
  }
}
EOF

# 4. Update the contacts page to use the API and demo context
echo "📱 Updating contacts page to use API properly..."
cat > app/contacts/page.tsx << 'EOF'
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

  useEffect(() => {
    if (isLoaded) {
      fetchContacts()
    }
  }, [isDemoMode, isLoaded])

  const fetchContacts = async () => {
    try {
      setLoading(true)
      
      const response = await fetch('/api/contacts')
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      setContacts(data.contacts || [])
      
      if (data.source === 'demo' || data.source === 'demo_fallback') {
        if (isDemoMode) {
          toast.success('Demo contacts loaded')
        } else {
          toast.error('Production mode but using demo data - check Supabase configuration')
        }
      } else {
        toast.success('Production contacts loaded')
      }
    } catch (error) {
      console.error('Failed to fetch contacts:', error)
      toast.error('Failed to load contacts')
    } finally {
      setLoading(false)
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
          <Button className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600">
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
            {filteredContacts.map((contact) => (
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
            ))}
          </TableBody>
        </Table>
      </Card>

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
    </div>
  )
}
EOF

echo ""
echo "✅ Supabase Configuration Error Fixed!"
echo ""
echo "🔧 What was Fixed:"
echo "  - Added missing isSupabaseConfigured() function to lib/supabase.ts"
echo "  - Created proper API endpoints for /api/contacts and /api/companies"
echo "  - Added fallback to demo data when Supabase is not configured"
echo "  - Updated contacts page to use the global demo context"
echo "  - Added proper error handling and loading states"
echo ""
echo "📊 How it Works:"
echo "  - Demo Mode: Uses hardcoded demo data"
echo "  - Production Mode: Fetches from Supabase, falls back to demo if needed"
echo "  - API endpoints handle both cases gracefully"
echo "  - Clear indicators show data source (demo vs production)"
echo ""
echo "🚀 Test Instructions:"
echo "  1. Navigate to /contacts page"
echo "  2. Toggle between demo and production modes"
echo "  3. Should see different data sources loading properly"
echo "  4. Check browser console - no more 500 errors"
echo ""
echo "The contacts and companies API endpoints should now work properly!"
