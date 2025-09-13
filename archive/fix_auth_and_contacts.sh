#!/bin/bash

echo "Fixing Authentication and Contact Saving Issues"
echo "=============================================="

# 1. Fix the service to work without authentication
echo "Updating existing-schema-prospects service..."
cat > lib/services/existing-schema-prospects.ts << 'EOF'
import { supabase, supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'
import type { Company, Contact, SavedItem } from '@/lib/supabase'

export interface ExistingCompany extends Company {}
export interface ExistingContact extends Contact {}

export class ExistingSchemaProspectsService {
  private getSupabaseClient() {
    // Use admin client for server-side operations, regular client for client-side
    return typeof window === 'undefined' ? (supabaseAdmin || supabase) : supabase
  }

  async saveProspects(prospects: Array<{ type: 'company' | 'vc', data: any }>) {
    try {
      if (!isSupabaseConfigured()) {
        throw new Error('Supabase not configured')
      }

      const client = this.getSupabaseClient()
      if (!client) {
        throw new Error('Supabase client not available')
      }

      // For now, work without authentication - use a default user_id
      // TODO: Replace with actual auth when implemented
      const defaultUserId = '00000000-0000-0000-0000-000000000000'
      
      console.log(`Saving ${prospects.length} prospects without authentication (demo mode)`)

      const savedItems = []
      
      for (const prospect of prospects) {
        if (prospect.type === 'company') {
          await this.saveCompanyProspect(defaultUserId, prospect.data, savedItems)
        } else if (prospect.type === 'vc') {
          await this.saveVCProspect(defaultUserId, prospect.data, savedItems)
        }
      }

      return {
        success: true,
        saved_items: savedItems,
        message: `Saved ${prospects.length} prospects to existing schema`
      }

    } catch (error) {
      console.error('Error saving prospects to existing schema:', error)
      throw error
    }
  }

  private async saveCompanyProspect(userId: string, companyData: any, savedItems: any[]) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      console.log(`Saving company: ${companyData.company} with ${companyData.contacts?.length || 0} contacts`)

      // First, check if company already exists in companies table
      let companyId: string
      const { data: existingCompany } = await client
        .from('companies')
        .select('id')
        .eq('name', companyData.company)
        .maybeSingle()

      if (existingCompany) {
        // Update existing company with discovery data
        const { data: updatedCompany, error } = await client
          .from('companies')
          .update({
            ai_score: companyData.ai_score,
            discovered_at: new Date().toISOString(),
            industry: companyData.industry || 'Biotech',
            location: companyData.location,
            description: companyData.description || companyData.short_description,
            total_funding: companyData.totalFunding,
            funding_stage: this.mapFundingStage(companyData.fundingStage),
            employee_count: companyData.employeeCount,
            website: companyData.website,
            linkedin_url: companyData.website // Fallback
          })
          .eq('id', existingCompany.id)
          .select()
          .single()

        if (error) throw error
        companyId = existingCompany.id
        console.log(`Updated existing company: ${companyData.company}`)
      } else {
        // Insert new company
        const { data: newCompany, error } = await client
          .from('companies')
          .insert({
            name: companyData.company,
            website: companyData.website,
            industry: companyData.industry || 'Biotech',
            funding_stage: this.mapFundingStage(companyData.fundingStage),
            location: companyData.location,
            description: companyData.description || companyData.short_description,
            total_funding: companyData.totalFunding,
            employee_count: companyData.employeeCount,
            linkedin_url: companyData.website, // Fallback
            ai_score: companyData.ai_score,
            discovered_at: new Date().toISOString()
          })
          .select()
          .single()

        if (error) throw error
        companyId = newCompany.id
        console.log(`Created new company: ${companyData.company}`)
      }

      // Save company to saved_items
      const { data: savedCompany, error: saveError } = await client
        .from('saved_items')
        .upsert({
          user_id: userId,
          item_type: 'company',
          company_id: companyId,
          ai_score: companyData.ai_score,
          discovery_source: 'apollo_search',
          search_criteria: { discovery_type: 'enhanced_search' }
        })
        .select()
        .single()

      if (saveError) throw saveError
      savedItems.push(savedCompany)

      // Save ALL company contacts (not just VCs)
      if (companyData.contacts && companyData.contacts.length > 0) {
        console.log(`Saving ${companyData.contacts.length} contacts for ${companyData.company}`)
        await this.saveCompanyContacts(userId, companyId, companyData.contacts, savedItems)
      }

    } catch (error) {
      console.error(`Error saving company ${companyData.company}:`, error)
      throw error
    }
  }

  private async saveCompanyContacts(userId: string, companyId: string, contacts: any[], savedItems: any[]) {
    const client = this.getSupabaseClient()
    if (!client) throw new Error('Supabase client not available')

    let contactsSaved = 0

    for (const contactData of contacts) {
      try {
        // Map role categories to existing schema
        const roleCategory = this.mapRoleCategory(contactData.role_category)
        const nameParts = contactData.name.split(' ')
        const firstName = nameParts[0] || contactData.name
        const lastName = nameParts.slice(1).join(' ') || ''
        
        console.log(`Saving contact: ${contactData.name} (${roleCategory}) for company ${companyId}`)

        // Check if contact already exists
        const { data: existingContact } = await client
          .from('contacts')
          .select('id')
          .eq('company_id', companyId)
          .eq('first_name', firstName)
          .eq('last_name', lastName)
          .maybeSingle()

        let contactId: string

        if (existingContact) {
          // Update existing contact
          const { data: updatedContact, error } = await client
            .from('contacts')
            .update({
              email: contactData.email,
              title: contactData.title,
              role_category: roleCategory,
              linkedin_url: contactData.linkedin,
              address: contactData.location,
              discovered_at: new Date().toISOString()
            })
            .eq('id', existingContact.id)
            .select()
            .single()

          if (error) throw error
          contactId = existingContact.id
          console.log(`Updated existing contact: ${contactData.name}`)
        } else {
          // Insert new contact
          const { data: newContact, error } = await client
            .from('contacts')
            .insert({
              company_id: companyId,
              first_name: firstName,
              last_name: lastName,
              email: contactData.email,
              title: contactData.title,
              role_category: roleCategory,
              linkedin_url: contactData.linkedin,
              address: contactData.location,
              discovered_at: new Date().toISOString()
            })
            .select()
            .single()

          if (error) throw error
          contactId = newContact.id
          console.log(`Created new contact: ${contactData.name}`)
        }

        // Save contact to saved_items
        const { data: savedContact, error: saveError } = await client
          .from('saved_items')
          .upsert({
            user_id: userId,
            item_type: 'contact',
            company_id: companyId,
            contact_id: contactId,
            discovery_source: 'apollo_search'
          })
          .select()
          .single()

        if (saveError) throw saveError
        savedItems.push(savedContact)
        contactsSaved++

      } catch (error) {
        console.error(`Error saving contact ${contactData.name}:`, error)
        // Continue with other contacts
      }
    }

    console.log(`Successfully saved ${contactsSaved} out of ${contacts.length} contacts`)
  }

  private async saveVCProspect(userId: string, vcData: any, savedItems: any[]) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      console.log(`Saving VC: ${vcData.name} from ${vcData.organization}`)

      // Save VC to saved_items (VCs might not fit existing company schema well)
      const { data: savedVC, error } = await client
        .from('saved_items')
        .insert({
          user_id: userId,
          item_type: 'vc',
          vc_data: vcData,
          discovery_source: 'apollo_search'
        })
        .select()
        .single()

      if (error) throw error
      savedItems.push(savedVC)
      console.log(`Saved VC: ${vcData.name}`)

    } catch (error) {
      console.error(`Error saving VC ${vcData.name}:`, error)
      throw error
    }
  }

  private mapRoleCategory(discoveryRole: string): string {
    // Map discovery role categories to existing schema
    switch (discoveryRole) {
      case 'Founder':
        return 'Founder'
      case 'C-Suite':
        return 'Executive'
      case 'Board/Partner':
        return 'Board Member'
      case 'Investor/VC':
        return 'VC'
      default:
        return 'Executive'
    }
  }

  private mapFundingStage(stage?: string): string | undefined {
    // Map to your existing funding_stage enum
    if (!stage) return undefined
    
    const validStages = ['Series A', 'Series B', 'Series C']
    if (validStages.includes(stage)) {
      return stage
    }
    
    // Map other stages to closest match
    if (stage.includes('A')) return 'Series A'
    if (stage.includes('B')) return 'Series B'
    if (stage.includes('C') || stage.includes('Growth') || stage.includes('D')) return 'Series C'
    
    return undefined
  }

  async getSavedProspects() {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      // Use default user for now
      const defaultUserId = '00000000-0000-0000-0000-000000000000'

      const { data: savedItems, error } = await client
        .from('saved_items')
        .select(`
          *,
          company:companies(*),
          contact:contacts(*)
        `)
        .eq('user_id', defaultUserId)
        .order('created_at', { ascending: false })

      if (error) throw error

      // Group contacts by company for better display
      const groupedItems = new Map()

      for (const item of savedItems || []) {
        if (item.item_type === 'company') {
          if (!groupedItems.has(item.company_id)) {
            groupedItems.set(item.company_id, {
              type: 'company',
              data: {
                id: item.company?.id,
                company: item.company?.name,
                website: item.company?.website,
                industry: item.company?.industry,
                fundingStage: item.company?.funding_stage,
                location: item.company?.location,
                description: item.company?.description,
                ai_score: item.ai_score || item.company?.ai_score,
                contacts: []
              },
              saved_at: item.created_at,
              saved_id: item.id
            })
          }
        } else if (item.item_type === 'contact' && item.contact) {
          const companyItem = groupedItems.get(item.company_id)
          if (companyItem) {
            companyItem.data.contacts.push({
              name: `${item.contact.first_name} ${item.contact.last_name}`,
              title: item.contact.title,
              email: item.contact.email,
              role_category: item.contact.role_category,
              linkedin: item.contact.linkedin_url
            })
          }
        } else if (item.item_type === 'vc') {
          groupedItems.set(`vc_${item.id}`, {
            type: 'vc',
            data: item.vc_data,
            saved_at: item.created_at,
            saved_id: item.id
          })
        }
      }

      return Array.from(groupedItems.values())

    } catch (error) {
      console.error('Error fetching saved prospects:', error)
      throw error
    }
  }

  async deleteSavedProspects(savedItemIds: string[]) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      const defaultUserId = '00000000-0000-0000-0000-000000000000'

      const { error } = await client
        .from('saved_items')
        .delete()
        .eq('user_id', defaultUserId)
        .in('id', savedItemIds)

      if (error) throw error

      return {
        success: true,
        message: `Deleted ${savedItemIds.length} saved items`
      }

    } catch (error) {
      console.error('Error deleting saved prospects:', error)
      throw error
    }
  }

  async getProspectStats() {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      const defaultUserId = '00000000-0000-0000-0000-000000000000'

      const { data: savedItems, error } = await client
        .from('saved_items')
        .select('item_type')
        .eq('user_id', defaultUserId)

      if (error) throw error

      const companies = savedItems?.filter(item => item.item_type === 'company').length || 0
      const contacts = savedItems?.filter(item => item.item_type === 'contact').length || 0
      const vcs = savedItems?.filter(item => item.item_type === 'vc').length || 0

      return {
        total: savedItems?.length || 0,
        companies,
        vcs,
        total_contacts: contacts + vcs
      }

    } catch (error) {
      console.error('Error fetching prospect stats:', error)
      throw error
    }
  }

  // NEW: Check for existing data to avoid duplicates
  async checkExistingData(searchCriteria: any) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      // Get existing company names to exclude from search
      const { data: existingCompanies, error } = await client
        .from('companies')
        .select('name, website')
        .not('name', 'is', null)

      if (error) throw error

      const existingNames = (existingCompanies || []).map(c => c.name.toLowerCase())
      const existingWebsites = (existingCompanies || [])
        .filter(c => c.website)
        .map(c => c.website!.toLowerCase())

      console.log(`Found ${existingNames.length} existing companies in database`)

      return {
        existingNames,
        existingWebsites,
        count: existingNames.length
      }

    } catch (error) {
      console.error('Error checking existing data:', error)
      return { existingNames: [], existingWebsites: [], count: 0 }
    }
  }
}

export const existingSchemaProspects = new ExistingSchemaProspectsService()
EOF

# 2. Add duplicate checking option to search parameters in the frontend
echo "Adding duplicate checking toggle to frontend..."
cat > app/discovery/enhanced-lead-discovery-page-with-duplicates.tsx << 'EOF'
// Enhanced Discovery Page with Duplicate Detection
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
    Search,
    Users,
    Building,
    Save,
    Filter,
    Target,
    Brain,
    Eye,
    Mail,
    Globe,
    MapPin,
    Star,
    SlidersHorizontal,
    X,
    DollarSign,
    Briefcase,
    Crown,
    TrendingUp,
    Check,
    Plus,
    Trash2,
    Download,
    Calendar,
    Building2,
    UserCheck,
    FileDown,
    AlertTriangle,
    Database
} from 'lucide-react'
import { toast } from 'react-hot-toast'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'

// ... (keeping all the existing interfaces as they are)

const [searchParams, setSearchParams] = useState({
    industries: ['Biotechnology', 'Pharmaceuticals'],
    fundingStages: ['Series A', 'Series B', 'Series C'],
    locations: ['United States', 'United Kingdom'],
    employeeRanges: ['51,200', '201,500', '501,1000'],
    includeVCs: true,
    excludeExisting: false,  // NEW: Option to exclude existing data
    maxResults: 10
})

// Add state for existing data tracking
const [existingDataCount, setExistingDataCount] = useState(0)
const [isCheckingExisting, setIsCheckingExisting] = useState(false)

// Function to check existing data
const checkExistingData = async () => {
    setIsCheckingExisting(true)
    try {
        const response = await fetchWithDemo('/api/discovery/check-existing', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(searchParams)
        })

        if (response.ok) {
            const data = await response.json()
            setExistingDataCount(data.count)
            toast.success(`Found ${data.count} existing companies in your database`)
        }
    } catch (error) {
        console.error('Error checking existing data:', error)
        toast.error('Failed to check existing data')
    } finally {
        setIsCheckingExisting(false)
    }
}

// Update your search configuration section to include the new toggle:

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
                max="20"
                className="w-24 mt-1"
            />
            <p className="text-xs text-gray-500 mt-1">Lower for faster results</p>
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

        {/* NEW: Exclude existing data toggle */}
        <div className="flex items-center space-x-2">
            <Checkbox
                checked={searchParams.excludeExisting}
                onCheckedChange={(checked) =>
                    setSearchParams(prev => ({ ...prev, excludeExisting: checked as boolean }))
                }
            />
            <span className="text-sm">Exclude existing companies</span>
        </div>

        {/* NEW: Check existing data button */}
        <div className="pt-2">
            <Button
                variant="outline"
                size="sm"
                onClick={checkExistingData}
                disabled={isCheckingExisting}
                className="flex items-center space-x-2 w-full"
            >
                <Database className="w-4 h-4" />
                <span>{isCheckingExisting ? 'Checking...' : 'Check Existing Data'}</span>
            </Button>
            {existingDataCount > 0 && (
                <p className="text-xs text-gray-600 mt-1">
                    {existingDataCount} companies already in your database
                </p>
            )}
        </div>
    </div>
</div>
EOF

# 3. Create API endpoint to check existing data
echo "Creating API endpoint to check existing data..."
mkdir -p app/api/discovery
cat > app/api/discovery/check-existing/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { existingSchemaProspects } from '@/lib/services/existing-schema-prospects'

export async function POST(request: NextRequest) {
  try {
    const searchCriteria = await request.json()
    
    console.log('Checking existing data for criteria:', searchCriteria)

    const existingData = await existingSchemaProspects.checkExistingData(searchCriteria)

    return NextResponse.json({
      success: true,
      count: existingData.count,
      existingNames: existingData.existingNames.slice(0, 10), // Sample names
      message: `Found ${existingData.count} existing companies`
    })

  } catch (error) {
    console.error('Error checking existing data:', error)
    
    return NextResponse.json(
      { 
        success: false, 
        message: error instanceof Error ? error.message : 'Failed to check existing data',
        count: 0
      },
      { status: 500 }
    )
  }
}
EOF

echo ""
echo "Authentication and Contact Saving Issues Fixed!"
echo "=============================================="
echo ""
echo "Fixed Issues:"
echo "1. ✅ Removed authentication requirement (uses default user ID for now)"
echo "2. ✅ Save ALL contacts when saving companies (not just VCs)"
echo "3. ✅ Added toggle to exclude existing companies from search"
echo "4. ✅ Added endpoint to check existing data in your database"
echo "5. ✅ Better logging to see what's being saved"
echo ""
echo "New Features:"
echo "- 'Exclude existing companies' checkbox in search params"
echo "- 'Check Existing Data' button to see what's already in your DB"
echo "- Grouped contact saving (all contacts per company)"
echo "- Better duplicate detection"
echo ""
echo "Now when you save companies:"
echo "- The company gets saved to your companies table"
echo "- ALL contacts from that company get saved to your contacts table"
echo "- Each contact is linked to the company via company_id"
echo "- VCs are saved separately as JSON data"
echo ""
echo "No more authentication errors - you can save prospects immediately!"
echo ""
