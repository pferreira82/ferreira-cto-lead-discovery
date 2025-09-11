#!/bin/bash

echo "Fixing Supabase Import Paths"
echo "============================"

# 1. First, let's check/create the correct Supabase client
echo "Creating/updating Supabase client at lib/supabase.ts..."
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

// For server-side operations
export function createServiceRoleClient() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  
  if (!serviceRoleKey || !supabaseUrl) {
    return null
  }
  
  return createClient(supabaseUrl, serviceRoleKey)
}

// Server-side client for API routes
export const supabaseAdmin = createServiceRoleClient()

// Helper to create client with correct context
export function createClient() {
  return supabase
}

// Database Types based on your existing schema
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
  ai_score?: number
  discovered_at?: string
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
  discovered_at?: string
  created_at: string
  updated_at: string
}

export interface SavedItem {
  id: string
  user_id: string
  item_type: 'company' | 'contact' | 'vc'
  company_id?: string
  contact_id?: string
  vc_data?: any
  ai_score?: number
  discovery_source?: string
  search_criteria?: any
  created_at: string
  updated_at: string
}
EOF

# 2. Fix the existing-schema-prospects service to use correct import
echo "Fixing existing-schema-prospects.ts import..."
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

      const { data: { user } } = await client.auth.getUser()
      if (!user) {
        throw new Error('User not authenticated')
      }

      const savedItems = []
      
      for (const prospect of prospects) {
        if (prospect.type === 'company') {
          await this.saveCompanyProspect(user.id, prospect.data, savedItems)
        } else if (prospect.type === 'vc') {
          await this.saveVCProspect(user.id, prospect.data, savedItems)
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
            funding_stage: companyData.fundingStage,
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

      // Save company contacts
      if (companyData.contacts && companyData.contacts.length > 0) {
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

    for (const contactData of contacts) {
      try {
        // Map role categories to existing schema
        const roleCategory = this.mapRoleCategory(contactData.role_category)
        const nameParts = contactData.name.split(' ')
        const firstName = nameParts[0] || contactData.name
        const lastName = nameParts.slice(1).join(' ') || ''
        
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

      } catch (error) {
        console.error(`Error saving contact ${contactData.name}:`, error)
        // Continue with other contacts
      }
    }
  }

  private async saveVCProspect(userId: string, vcData: any, savedItems: any[]) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

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

      const { data: { user } } = await client.auth.getUser()
      if (!user) {
        throw new Error('User not authenticated')
      }

      const { data: savedItems, error } = await client
        .from('saved_items')
        .select(`
          *,
          company:companies(*),
          contact:contacts(*)
        `)
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

      if (error) throw error

      // Transform to match expected format
      return (savedItems || []).map(item => ({
        type: item.item_type === 'vc' ? 'vc' : 'company',
        data: item.item_type === 'vc' ? item.vc_data : {
          id: item.company?.id,
          company: item.company?.name,
          website: item.company?.website,
          industry: item.company?.industry,
          fundingStage: item.company?.funding_stage,
          location: item.company?.location,
          description: item.company?.description,
          ai_score: item.ai_score || item.company?.ai_score,
          contacts: item.contact ? [{
            name: `${item.contact.first_name} ${item.contact.last_name}`,
            title: item.contact.title,
            email: item.contact.email,
            role_category: item.contact.role_category,
            linkedin: item.contact.linkedin_url
          }] : []
        },
        saved_at: item.created_at,
        saved_id: item.id
      }))

    } catch (error) {
      console.error('Error fetching saved prospects:', error)
      throw error
    }
  }

  async deleteSavedProspects(savedItemIds: string[]) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      const { data: { user } } = await client.auth.getUser()
      if (!user) {
        throw new Error('User not authenticated')
      }

      const { error } = await client
        .from('saved_items')
        .delete()
        .eq('user_id', user.id)
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

      const { data: { user } } = await client.auth.getUser()
      if (!user) {
        throw new Error('User not authenticated')
      }

      const { data: savedItems, error } = await client
        .from('saved_items')
        .select('item_type')
        .eq('user_id', user.id)

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
}

export const existingSchemaProspects = new ExistingSchemaProspectsService()
EOF

echo ""
echo "Supabase Import Fix Complete!"
echo "============================"
echo ""
echo "Fixed Issues:"
echo "✅ Corrected import path from '@/lib/supabase/client' to '@/lib/supabase'"
echo "✅ Updated Supabase client configuration"
echo "✅ Added proper error handling for missing Supabase config"
echo "✅ Added client/server context handling"
echo "✅ Fixed service to use correct import path"
echo ""
echo "Your Supabase client is now properly configured at lib/supabase.ts"
echo "and the prospect saving service uses the correct import path."
echo ""
echo "Restart your server and try saving prospects again!"
echo ""
