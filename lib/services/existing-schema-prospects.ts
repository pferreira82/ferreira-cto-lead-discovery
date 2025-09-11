import { supabase, supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'
import type { Company, Contact } from '@/lib/supabase'

export interface SavedSelection {
  id: string
  selection_type: 'company' | 'contact' | 'vc'
  company_id?: string
  contact_id?: string
  vc_data?: any
  discovery_source?: string
  search_criteria?: any
  created_at: string
  updated_at: string
  // Joined data
  company?: Company
  contact?: Contact
}

export class ExistingSchemaProspectsService {
  private getSupabaseClient() {
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

      console.log(`Saving ${prospects.length} prospects using existing schema`)

      const savedSelections = []
      let companiesSaved = 0
      let contactsSaved = 0
      let vcsSaved = 0
      
      for (const prospect of prospects) {
        if (prospect.type === 'company') {
          const result = await this.saveCompanyProspect(prospect.data, savedSelections)
          companiesSaved++
          contactsSaved += result.contactsCount
        } else if (prospect.type === 'vc') {
          await this.saveVCProspect(prospect.data, savedSelections)
          vcsSaved++
        }
      }

      console.log(`Successfully saved: ${companiesSaved} companies, ${contactsSaved} contacts, ${vcsSaved} VCs`)

      return {
        success: true,
        saved_selections: savedSelections,
        message: `Saved ${companiesSaved} companies with ${contactsSaved} contacts and ${vcsSaved} VCs`,
        stats: {
          companies: companiesSaved,
          contacts: contactsSaved,
          vcs: vcsSaved,
          total: savedSelections.length
        }
      }

    } catch (error) {
      console.error('Error saving prospects:', error)
      throw error
    }
  }

  private async saveCompanyProspect(companyData: any, savedSelections: any[]) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      console.log(`Saving company: ${companyData.company} with ${companyData.contacts?.length || 0} contacts`)

      // Save/update in your existing companies table
      let companyId: string
      const { data: existingCompany } = await client
        .from('companies')
        .select('id')
        .eq('name', companyData.company)
        .maybeSingle()

      if (existingCompany) {
        // Update existing company
        const updateData: any = {
          discovered_at: new Date().toISOString(),
          industry: companyData.industry || 'Biotech',
          location: companyData.location,
          description: companyData.description || companyData.short_description,
          website: companyData.website,
          linkedin_url: companyData.website
        }

        if (companyData.ai_score !== undefined) {
          updateData.ai_score = companyData.ai_score
        }
        if (companyData.totalFunding) {
          updateData.total_funding = companyData.totalFunding
        }
        if (companyData.fundingStage) {
          const mappedStage = this.mapFundingStage(companyData.fundingStage)
          if (mappedStage) {
            updateData.funding_stage = mappedStage
          }
        }
        if (companyData.employeeCount) {
          updateData.employee_count = companyData.employeeCount
        }

        const { error } = await client
          .from('companies')
          .update(updateData)
          .eq('id', existingCompany.id)

        if (error) throw error
        companyId = existingCompany.id
        console.log(`Updated existing company: ${companyData.company}`)
      } else {
        // Insert new company
        const insertData: any = {
          name: companyData.company,
          website: companyData.website,
          industry: companyData.industry || 'Biotech',
          location: companyData.location,
          description: companyData.description || companyData.short_description,
          linkedin_url: companyData.website,
          discovered_at: new Date().toISOString()
        }

        if (companyData.ai_score !== undefined) {
          insertData.ai_score = companyData.ai_score
        }
        if (companyData.totalFunding) {
          insertData.total_funding = companyData.totalFunding
        }
        if (companyData.fundingStage) {
          const mappedStage = this.mapFundingStage(companyData.fundingStage)
          if (mappedStage) {
            insertData.funding_stage = mappedStage
          }
        }
        if (companyData.employeeCount) {
          insertData.employee_count = companyData.employeeCount
        }

        const { data: newCompany, error } = await client
          .from('companies')
          .insert(insertData)
          .select()
          .single()

        if (error) throw error
        companyId = newCompany.id
        console.log(`Created new company: ${companyData.company}`)
      }

      // Track that this company was saved from discovery
      const { data: savedCompany, error: saveError } = await client
        .from('saved_selections')
        .upsert({
          selection_type: 'company',
          company_id: companyId,
          discovery_source: 'apollo_search',
          search_criteria: { discovery_type: 'enhanced_search' }
        }, {
          onConflict: 'company_id,selection_type',
          ignoreDuplicates: false
        })
        .select()
        .single()

      if (saveError) {
        console.error('Error tracking company selection:', saveError)
      } else {
        savedSelections.push(savedCompany)
      }

      // Save contacts to your existing contacts table
      let contactsCount = 0
      if (companyData.contacts && companyData.contacts.length > 0) {
        console.log(`Saving ${companyData.contacts.length} contacts for ${companyData.company}`)
        contactsCount = await this.saveCompanyContacts(companyId, companyData.contacts, savedSelections)
      }

      return { contactsCount }

    } catch (error) {
      console.error(`Error saving company ${companyData.company}:`, error)
      throw error
    }
  }

  private async saveCompanyContacts(companyId: string, contacts: any[], savedSelections: any[]) {
    const client = this.getSupabaseClient()
    if (!client) throw new Error('Supabase client not available')

    let contactsSaved = 0

    for (const contactData of contacts) {
      try {
        const roleCategory = this.mapRoleCategory(contactData.role_category)
        const nameParts = contactData.name.split(' ')
        const firstName = nameParts[0] || contactData.name
        const lastName = nameParts.slice(1).join(' ') || ''
        
        console.log(`Saving contact: ${contactData.name} (${roleCategory})`)

        // Save/update in your existing contacts table
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

        // Track that this contact was saved from discovery
        const { data: savedContact, error: saveError } = await client
          .from('saved_selections')
          .upsert({
            selection_type: 'contact',
            company_id: companyId,
            contact_id: contactId,
            discovery_source: 'apollo_search'
          }, {
            onConflict: 'contact_id,selection_type',
            ignoreDuplicates: false
          })
          .select()
          .single()

        if (saveError) {
          console.error('Error tracking contact selection:', saveError)
        } else {
          savedSelections.push(savedContact)
        }
        
        contactsSaved++

      } catch (error) {
        console.error(`Error saving contact ${contactData.name}:`, error)
      }
    }

    console.log(`Successfully saved ${contactsSaved} out of ${contacts.length} contacts`)
    return contactsSaved
  }

  private async saveVCProspect(vcData: any, savedSelections: any[]) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      console.log(`Saving VC: ${vcData.name} from ${vcData.organization}`)

      // Save VC data (VCs don't fit well in companies table)
      const { data: savedVC, error } = await client
        .from('saved_selections')
        .insert({
          selection_type: 'vc',
          vc_data: vcData,
          discovery_source: 'apollo_search'
        })
        .select()
        .single()

      if (error) throw error
      savedSelections.push(savedVC)
      console.log(`Saved VC: ${vcData.name}`)

    } catch (error) {
      console.error(`Error saving VC ${vcData.name}:`, error)
      throw error
    }
  }

  private mapRoleCategory(discoveryRole: string): string {
    switch (discoveryRole) {
      case 'Founder': return 'Founder'
      case 'C-Suite': return 'Executive' 
      case 'Board/Partner': return 'Board Member'
      case 'Investor/VC': return 'VC'
      default: return 'Executive'
    }
  }

  private mapFundingStage(stage?: string): string | undefined {
    if (!stage) return undefined
    
    const validStages = ['Series A', 'Series B', 'Series C']
    if (validStages.includes(stage)) return stage
    
    if (stage.includes('A')) return 'Series A'
    if (stage.includes('B')) return 'Series B'
    if (stage.includes('C') || stage.includes('Growth') || stage.includes('D')) return 'Series C'
    
    return undefined
  }

  async getSavedProspects() {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      const { data: savedSelections, error } = await client
        .from('saved_selections')
        .select(`
          *,
          company:companies(*),
          contact:contacts(*)
        `)
        .order('created_at', { ascending: false })

      if (error) throw error

      // Group by companies for display
      const groupedItems = new Map()

      for (const item of savedSelections || []) {
        if (item.selection_type === 'company') {
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
                ai_score: item.company?.ai_score,
                contacts: []
              },
              saved_at: item.created_at,
              saved_id: item.id
            })
          }
        } else if (item.selection_type === 'contact' && item.contact) {
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
        } else if (item.selection_type === 'vc') {
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

  async getProspectStats() {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      const { data: savedSelections, error } = await client
        .from('saved_selections')
        .select('selection_type')

      if (error) throw error

      const companies = savedSelections?.filter(item => item.selection_type === 'company').length || 0
      const contacts = savedSelections?.filter(item => item.selection_type === 'contact').length || 0
      const vcs = savedSelections?.filter(item => item.selection_type === 'vc').length || 0

      return {
        total: savedSelections?.length || 0,
        companies,
        vcs,
        total_contacts: contacts + vcs
      }

    } catch (error) {
      console.error('Error fetching prospect stats:', error)
      throw error
    }
  }

  async checkExistingData(searchCriteria: any) {
    try {
      const client = this.getSupabaseClient()
      if (!client) throw new Error('Supabase client not available')

      const { data: existingCompanies, error: companiesError } = await client
        .from('companies')
        .select('name, website')
        .not('name', 'is', null)

      if (companiesError) throw companiesError

      const { count: contactsCount, error: contactsError } = await client
        .from('contacts')
        .select('*', { count: 'exact', head: true })

      if (contactsError) throw contactsError

      const existingNames = (existingCompanies || []).map(c => c.name.toLowerCase())
      const existingWebsites = (existingCompanies || [])
        .filter(c => c.website)
        .map(c => c.website!.toLowerCase())

      console.log(`Found ${existingNames.length} existing companies and ${contactsCount || 0} existing contacts`)

      return {
        existingNames,
        existingWebsites,
        companiesCount: existingNames.length,
        contactsCount: contactsCount || 0
      }

    } catch (error) {
      console.error('Error checking existing data:', error)
      return { 
        existingNames: [], 
        existingWebsites: [], 
        companiesCount: 0, 
        contactsCount: 0 
      }
    }
  }
}

export const existingSchemaProspects = new ExistingSchemaProspectsService()
