import puppeteer from 'puppeteer'
import * as cheerio from 'cheerio'
import { apolloService } from './apollo'
import { supabaseAdmin } from './supabase'

interface ScrapingParams {
  industry?: string[]
  funding_stages?: string[]
  locations?: string[]
  role_categories?: string[]
}

class DataScrapingService {
  async scrapeCompanyData(params: ScrapingParams) {
    try {
      console.log('Starting company data scraping...')
      
      // Use Apollo API for initial company discovery
      const companies = await apolloService.searchCompanies({
        industry: params.industry || ['Biotechnology', 'Pharmaceuticals'],
        funding_stage: params.funding_stages || ['Series A', 'Series B', 'Series C']
      })

      const savedCompanies = []

      for (const company of companies) {
        try {
          // Check if company already exists
          const { data: existingCompany } = await supabaseAdmin
            .from('companies')
            .select('id')
            .eq('name', company.name)
            .single()

          if (existingCompany) {
            console.log(`Company ${company.name} already exists, skipping...`)
            continue
          }

          // Save company to database
          const { data: savedCompany, error } = await supabaseAdmin
            .from('companies')
            .insert({
              name: company.name,
              website: company.website_url,
              industry: company.industry,
              funding_stage: company.funding_stage,
              location: company.location,
              description: company.short_description,
              total_funding: company.total_funding,
              employee_count: company.estimated_num_employees,
              linkedin_url: company.linkedin_url
            })
            .select()
            .single()

          if (error) {
            console.error(`Error saving company ${company.name}:`, error)
            continue
          }

          savedCompanies.push(savedCompany)
          console.log(`Saved company: ${company.name}`)

          // Add delay to avoid rate limiting
          await new Promise(resolve => setTimeout(resolve, 500))
        } catch (error) {
          console.error(`Error processing company ${company.name}:`, error)
        }
      }

      return savedCompanies
    } catch (error) {
      console.error('Company scraping error:', error)
      throw error
    }
  }

  async scrapeContactData(companyIds: string[], targetRoles: string[] = ['CEO', 'CTO', 'Founder', 'VP']) {
    try {
      console.log('Starting contact data scraping...')
      
      const savedContacts = []

      for (const companyId of companyIds) {
        try {
          // Get company details
          const { data: company } = await supabaseAdmin
            .from('companies')
            .select('*')
            .eq('id', companyId)
            .single()

          if (!company) continue

          // Search for contacts using Apollo
          const contacts = await apolloService.searchContacts({
            company_names: [company.name],
            role_titles: targetRoles
          })

          for (const contact of contacts) {
            try {
              // Check if contact already exists
              const { data: existingContact } = await supabaseAdmin
                .from('contacts')
                .select('id')
                .eq('email', contact.email)
                .single()

              if (existingContact) {
                console.log(`Contact ${contact.email} already exists, skipping...`)
                continue
              }

              // Determine role category
              let roleCategory = 'Executive'
              const title = contact.title.toLowerCase()
              if (title.includes('founder') || title.includes('co-founder')) {
                roleCategory = 'Founder'
              } else if (title.includes('ceo') || title.includes('cto') || title.includes('cfo')) {
                roleCategory = 'Executive'
              } else if (title.includes('board') || title.includes('director') && title.includes('board')) {
                roleCategory = 'Board Member'
              }

              // Save contact to database
              const { data: savedContact, error } = await supabaseAdmin
                .from('contacts')
                .insert({
                  company_id: companyId,
                  first_name: contact.first_name,
                  last_name: contact.last_name,
                  email: contact.email,
                  title: contact.title,
                  role_category: roleCategory,
                  linkedin_url: contact.linkedin_url,
                  bio: contact.headline
                })
                .select()
                .single()

              if (error) {
                console.error(`Error saving contact ${contact.email}:`, error)
                continue
              }

              savedContacts.push(savedContact)
              console.log(`Saved contact: ${contact.first_name} ${contact.last_name} at ${company.name}`)

              // Add delay to avoid rate limiting
              await new Promise(resolve => setTimeout(resolve, 300))
            } catch (error) {
              console.error(`Error processing contact ${contact.email}:`, error)
            }
          }

          // Add delay between companies
          await new Promise(resolve => setTimeout(resolve, 1000))
        } catch (error) {
          console.error(`Error processing company ${companyId}:`, error)
        }
      }

      return savedContacts
    } catch (error) {
      console.error('Contact scraping error:', error)
      throw error
    }
  }

  async enrichExistingContacts(limit: number = 50) {
    try {
      console.log('Starting contact enrichment...')

      // Get contacts without complete information
      const { data: contacts } = await supabaseAdmin
        .from('contacts')
        .select('*')
        .is('bio', null)
        .or('phone.is.null,linkedin_url.is.null')
        .limit(limit)

      if (!contacts) return []

      const enrichedContacts = []

      for (const contact of contacts) {
        try {
          if (!contact.email) continue

          // Enrich contact using Apollo
          const enrichedData = await apolloService.enrichContact(contact.email)

          if (enrichedData) {
            // Update contact with enriched data
            const { error } = await supabaseAdmin
              .from('contacts')
              .update({
                phone: enrichedData.phone || contact.phone,
                linkedin_url: enrichedData.linkedin_url || contact.linkedin_url,
                bio: enrichedData.headline || contact.bio,
                address: enrichedData.location || contact.address
              })
              .eq('id', contact.id)

            if (!error) {
              enrichedContacts.push(contact)
              console.log(`Enriched contact: ${contact.first_name} ${contact.last_name}`)
            }
          }

          // Add delay to avoid rate limiting
          await new Promise(resolve => setTimeout(resolve, 500))
        } catch (error) {
          console.error(`Error enriching contact ${contact.id}:`, error)
        }
      }

      return enrichedContacts
    } catch (error) {
      console.error('Contact enrichment error:', error)
      throw error
    }
  }

  async runAutomatedScraping(params: ScrapingParams = {}) {
    try {
      console.log('Starting automated scraping process...')

      // Log the search query
      const { data: searchQuery } = await supabaseAdmin
        .from('search_queries')
        .insert({
          query_type: 'automated_scraping',
          parameters: params,
          status: 'running'
        })
        .select()
        .single()

      let totalResults = 0

      try {
        // Step 1: Scrape company data
        const companies = await this.scrapeCompanyData(params)
        console.log(`Scraped ${companies.length} companies`)

        // Step 2: Scrape contact data for new companies
        if (companies.length > 0) {
          const companyIds = companies.map(c => c.id)
          const contacts = await this.scrapeContactData(companyIds, params.role_categories)
          console.log(`Scraped ${contacts.length} contacts`)
          totalResults = companies.length + contacts.length
        }

        // Step 3: Enrich existing contacts
        const enrichedContacts = await this.enrichExistingContacts(25)
        console.log(`Enriched ${enrichedContacts.length} existing contacts`)

        // Update search query status
        await supabaseAdmin
          .from('search_queries')
          .update({
            status: 'completed',
            results_count: totalResults
          })
          .eq('id', searchQuery.id)

        console.log('Automated scraping completed successfully')
        return {
          companies: companies?.length || 0,
          contacts: totalResults,
          enriched: enrichedContacts.length
        }
      } catch (error) {
        // Update search query status on error
        await supabaseAdmin
          .from('search_queries')
          .update({
            status: 'failed'
          })
          .eq('id', searchQuery.id)

        throw error
      }
    } catch (error) {
      console.error('Automated scraping error:', error)
      throw error
    }
  }
}

export const dataScrapingService = new DataScrapingService()
