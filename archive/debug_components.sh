#!/bin/bash

echo "🔍 Debugging Component Import Issues"
echo "==================================="

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

# Check which UI components actually exist
echo ""
echo "🔍 Checking which UI components exist..."
UI_DIR="components/ui"

declare -a REQUIRED_COMPONENTS=(
    "card"
    "button" 
    "badge"
    "input"
    "checkbox"
    "table"
    "dropdown-menu"
    "dialog"
)

echo ""
echo "📦 Available UI components:"
for component in "${REQUIRED_COMPONENTS[@]}"; do
    if [[ -f "$UI_DIR/$component.tsx" ]]; then
        echo "✅ $component.tsx exists"
    else
        echo "❌ $component.tsx MISSING"
    fi
done

echo ""
echo "🔍 Checking component exports..."

# Function to check if a component is properly exported
check_export() {
    local file="$1"
    local component_name="$2"
    
    if [[ -f "$file" ]]; then
        if grep -q "export.*$component_name" "$file"; then
            echo "✅ $component_name is exported from $file"
        else
            echo "❌ $component_name is NOT exported from $file"
            echo "   Available exports:"
            grep -E "^export" "$file" | head -5
        fi
    fi
}

# Check each component file
if [[ -f "$UI_DIR/card.tsx" ]]; then
    check_export "$UI_DIR/card.tsx" "Card"
    check_export "$UI_DIR/card.tsx" "CardContent"
    check_export "$UI_DIR/card.tsx" "CardHeader"
    check_export "$UI_DIR/card.tsx" "CardTitle"
    check_export "$UI_DIR/card.tsx" "CardDescription"
fi

if [[ -f "$UI_DIR/table.tsx" ]]; then
    check_export "$UI_DIR/table.tsx" "Table"
    check_export "$UI_DIR/table.tsx" "TableBody"
    check_export "$UI_DIR/table.tsx" "TableCell"
    check_export "$UI_DIR/table.tsx" "TableHead"
    check_export "$UI_DIR/table.tsx" "TableHeader"
    check_export "$UI_DIR/table.tsx" "TableRow"
fi

if [[ -f "$UI_DIR/dialog.tsx" ]]; then
    check_export "$UI_DIR/dialog.tsx" "Dialog"
    check_export "$UI_DIR/dialog.tsx" "DialogContent"
    check_export "$UI_DIR/dialog.tsx" "DialogDescription"
    check_export "$UI_DIR/dialog.tsx" "DialogFooter"
    check_export "$UI_DIR/dialog.tsx" "DialogHeader"
    check_export "$UI_DIR/dialog.tsx" "DialogTitle"
fi

if [[ -f "$UI_DIR/dropdown-menu.tsx" ]]; then
    check_export "$UI_DIR/dropdown-menu.tsx" "DropdownMenu"
    check_export "$UI_DIR/dropdown-menu.tsx" "DropdownMenuContent"
    check_export "$UI_DIR/dropdown-menu.tsx" "DropdownMenuItem"
    check_export "$UI_DIR/dropdown-menu.tsx" "DropdownMenuLabel"
    check_export "$UI_DIR/dropdown-menu.tsx" "DropdownMenuSeparator"
    check_export "$UI_DIR/dropdown-menu.tsx" "DropdownMenuTrigger"
fi

echo ""
echo "🔧 Creating a minimal version with only guaranteed components..."

# Create backup
BACKUP_FILE="${CONTACTS_PAGE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CONTACTS_PAGE" "$BACKUP_FILE"
echo "💾 Backup created: $BACKUP_FILE"

# Create minimal version
cat > "$CONTACTS_PAGE" << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import { useDemoMode } from '@/lib/demo-context'

// Only import components that definitely exist
// We'll use minimal imports and fallback to HTML elements

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

export default function ContactsPage() {
  const { isDemoMode, isLoaded } = useDemoMode()
  const [contacts, setContacts] = useState<Contact[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [error, setError] = useState<string | null>(null)

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
      
      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`HTTP ${response.status}: ${errorText}`)
      }
      
      const data = await response.json()
      const contactsArray = data.contacts || []
      setContacts(contactsArray)
      
      toast.success(`Loaded ${contactsArray.length} contacts`)
      
    } catch (error) {
      console.error('❌ Failed to fetch contacts:', error)
      setError(error instanceof Error ? error.message : 'Unknown error occurred')
      toast.error(`Failed to load contacts: ${error instanceof Error ? error.message : 'Unknown error'}`)
      setContacts([])
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

  if (!isLoaded) {
    return (
      <div className="p-6">
        <h1 className="text-2xl font-bold mb-4">Loading...</h1>
        <p>Initializing contacts system...</p>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="p-6">
        <h1 className="text-2xl font-bold mb-4">Contacts</h1>
        <p>Loading contacts...</p>
      </div>
    )
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold mb-2">Contacts</h1>
        <p className="text-gray-600">
          Manage your biotech industry contacts • {contacts.length} total contacts
        </p>
      </div>

      {/* Mode Info */}
      <div className={`p-4 rounded-lg ${isDemoMode ? 'bg-blue-50' : 'bg-green-50'}`}>
        <p className="font-medium">
          {isDemoMode ? 'Demo Data Active' : 'Production Data Connected'}
        </p>
        <p className="text-sm text-gray-600">
          {isDemoMode 
            ? 'Showing sample contacts for testing and exploration'
            : 'Live contacts from your Supabase database'
          }
        </p>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="p-4 bg-red-50 rounded-lg">
          <p className="font-medium text-red-800">Connection Error</p>
          <p className="text-sm text-red-600">{error}</p>
          <button 
            onClick={fetchContacts}
            className="mt-2 px-4 py-2 bg-red-100 text-red-800 rounded hover:bg-red-200"
          >
            Try Again
          </button>
        </div>
      )}

      {/* Search */}
      <div className="mb-6">
        <input
          type="text"
          placeholder="Search contacts, companies, or emails..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>

      {/* Contacts Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Contact
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Company
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Role
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {filteredContacts.length > 0 ? (
              filteredContacts.map((contact) => (
                <tr key={contact.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <p className="font-medium text-gray-900">
                        {contact.first_name} {contact.last_name}
                      </p>
                      {contact.email && (
                        <p className="text-sm text-gray-500">{contact.email}</p>
                      )}
                      {contact.title && (
                        <p className="text-xs text-gray-400">{contact.title}</p>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {contact.companies?.name && (
                      <div>
                        <p className="font-medium text-gray-900">{contact.companies.name}</p>
                        {contact.companies.industry && (
                          <p className="text-xs text-gray-400">{contact.companies.industry}</p>
                        )}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {contact.role_category && (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        {contact.role_category}
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {contact.contact_status && (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                        {contact.contact_status.replace('_', ' ')}
                      </span>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={4} className="px-6 py-12 text-center text-gray-500">
                  {contacts.length === 0 ? 'No contacts found. Try refreshing.' : 'No contacts match your search.'}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Debug Info */}
      {contacts.length === 0 && !loading && (
        <div className="p-4 bg-yellow-50 rounded-lg">
          <p className="font-medium text-yellow-800">Debug: No contacts loaded</p>
          <p className="text-sm text-yellow-600">Check browser console for API response details</p>
        </div>
      )}
    </div>
  )
}
EOF

echo ""
echo "✅ Created Minimal Working Version!"
echo "=================================="
echo ""
echo "This version:"
echo "• Uses NO external UI component imports"
echo "• Uses only standard HTML elements with Tailwind classes"
echo "• Should work without any component import errors"
echo "• Maintains core functionality (fetch, display, search contacts)"
echo ""
echo "If this works, we can gradually add back UI components one by one to identify the problematic import."
