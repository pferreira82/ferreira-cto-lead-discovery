import { NextApiRequest, NextApiResponse } from 'next'
import { createClient } from "@supabase/supabase-js"
import { isSupabaseConfigured } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    const { leads } = req.body

    if (!leads || !Array.isArray(leads)) {
      return res.status(400).json({ 
        success: false,
        error: 'Invalid leads data. Expected array of leads.' 
      })
    }

    console.log(`💾 Saving ${leads.length} leads to database...`)

    // Check if Supabase is configured
    if (!supabaseUrl || !supabaseKey) {
      console.warn('⚠️ Supabase not configured, simulating save...')
      await new Promise(resolve => setTimeout(resolve, 1500))
      
      return res.status(200).json({
        success: true,
        results: {
          companies: leads.length,
          contacts: leads.reduce((sum, lead) => sum + lead.contacts.length, 0),
          errors: []
        },
        message: `Simulated save: ${leads.length} companies and ${leads.reduce((sum, lead) => sum + lead.contacts.length, 0)} contacts`
      })
    }

    const supabase = createClient(supabaseUrl, supabaseKey)
    const results = {
      companies: 0,
      contacts: 0,
      errors: []
    }

    for (const lead of leads) {
      try {
        // Check if company already exists
        const { data: existingCompany } = await supabase
          .from('companies')
          .select('id')
          .eq('name', lead.company)
          .single()

        let companyId = existingCompany?.id

        if (!existingCompany) {
          // Save new company
          const { data: newCompany, error: companyError } = await supabase
            .from('companies')
            .insert({
              name: lead.company,
              website: lead.website,
              industry: lead.industry,
              funding_stage: lead.fundingStage,
              description: lead.description,
              location: lead.location,
              total_funding: lead.totalFunding,
              employee_count: lead.employeeCount
            })
            .select('id')
            .single()

          if (companyError) {
            console.error(`Company save error for ${lead.company}:`, companyError)
            results.errors.push(`Company ${lead.company}: ${companyError.message}`)
            continue
          }

          companyId = newCompany.id
          results.companies++
          console.log(`✅ Saved company: ${lead.company}`)
        } else {
          console.log(`ℹ️ Company already exists: ${lead.company}`)
        }

        // Save contacts
        for (const contact of lead.contacts) {
          try {
            // Skip contacts without email
            if (!contact.email) {
              console.log(`⚠️ Skipping contact ${contact.name} - no email`)
              continue
            }

            // Check if contact already exists
            const { data: existingContact } = await supabase
              .from('contacts')
              .select('id')
              .eq('email', contact.email)
              .single()

            if (!existingContact) {
              const nameParts = contact.name.split(' ')
              const firstName = nameParts[0] || ''
              const lastName = nameParts.slice(1).join(' ') || ''

              const { error: contactError } = await supabase
                .from('contacts')
                .insert({
                  company_id: companyId,
                  first_name: firstName,
                  last_name: lastName,
                  email: contact.email,
                  title: contact.title,
                  role_category: contact.role_category,
                  linkedin_url: contact.linkedin,
                  contact_status: 'not_contacted'
                })

              if (!contactError) {
                results.contacts++
                console.log(`✅ Saved contact: ${contact.name}`)
              } else {
                console.error(`Contact save error for ${contact.name}:`, contactError)
                results.errors.push(`Contact ${contact.name}: ${contactError.message}`)
              }
            } else {
              console.log(`ℹ️ Contact already exists: ${contact.name}`)
            }
          } catch (contactError) {
            console.error(`Contact processing error for ${contact.name}:`, contactError)
            results.errors.push(`Contact ${contact.name}: ${contactError.message}`)
          }
        }

      } catch (companyError) {
        console.error(`Company processing error for ${lead.company}:`, companyError)
        results.errors.push(`Company ${lead.company}: ${companyError.message}`)
      }
    }

    // Log the save operation
    try {
      await supabase
        .from('search_queries')
        .insert({
          query_type: 'save_leads',
          parameters: { 
            leads_count: leads.length,
            companies_saved: results.companies,
            contacts_saved: results.contacts
          },
          results_count: results.companies + results.contacts,
          status: 'completed'
        })
    } catch (logError) {
      console.warn('Failed to log save operation:', logError)
    }

    console.log(`✅ Save completed: ${results.companies} companies, ${results.contacts} contacts`)

    res.status(200).json({
      success: true,
      results,
      message: `Successfully saved ${results.companies} companies and ${results.contacts} contacts`
    })

  } catch (error) {
    console.error('❌ Save Leads API Error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to save leads',
      message: error instanceof Error ? error.message : String(error) || 'Unknown error occurred'
    })
  }
}
