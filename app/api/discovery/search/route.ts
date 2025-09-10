import { NextRequest, NextResponse } from 'next/server'
import { ApolloService } from '@/lib/services/apollo'

export async function POST(request: NextRequest) {
  try {
    const searchCriteria = await request.json()
    
    console.log('Discovery search criteria:', searchCriteria)

    // Initialize Apollo service
    const apollo = new ApolloService()

    let results
    
    // Use enhanced search with proper progress tracking
    if (searchCriteria.includeVCs) {
      // Enhanced search with VCs
      results = await apollo.searchCompaniesWithExecutives(
        searchCriteria,
        (step: string, current: number, total: number) => {
          console.log(`Progress: ${step} (${current}/${total})`)
        }
      )
    } else {
      // Company-only search
      results = await apollo.searchCompaniesWithExecutives(
        searchCriteria,
        (step: string, current: number, total: number) => {
          console.log(`Progress: ${step} (${current}/${total})`)
        }
      )
    }

    // Transform results to match expected format
    const transformedLeads = results.companies.map((company: any) => ({
      id: company.id,
      company: company.name,
      website: company.website_url,
      industry: company.industry || 'Unknown',
      fundingStage: company.funding_info?.stage || company.latest_funding_stage,
      description: company.description || `${company.name} is a company in the ${company.industry || 'biotech'} industry.`,
      location: company.location || 'Unknown',
      totalFunding: company.funding_info?.total_funding || company.total_funding,
      employeeCount: company.estimated_num_employees || company.organization_headcount,
      foundedYear: company.founded_year,
      ai_score: company.ai_score,
      domain: company.domain,
      funding_info: company.funding_info,
      contacts: company.contacts || []
    }))

    // Transform VC contacts
    const transformedVCs = (results.vcContacts || []).map((vc: any) => ({
      name: vc.name,
      title: vc.title,
      email: vc.email,
      role_category: vc.role_category,
      linkedin: vc.linkedin,
      seniority: vc.seniority,
      photo_url: vc.photo_url,
      location: vc.location,
      organization: vc.organization,
      organization_domain: vc.organization_domain
    }))

    console.log(`Search completed: ${transformedLeads.length} companies, ${results.totalContacts} contacts, ${transformedVCs.length} VCs`)

    return NextResponse.json({
      success: true,
      leads: transformedLeads,
      vcContacts: transformedVCs,
      totalCompanies: results.totalCompanies,
      totalContacts: results.totalContacts,
      pagination: results.pagination
    })

  } catch (error) {
    console.error('Apollo API Error:', error)
    
    // Return more specific error information
    let errorMessage = 'Failed to search companies'
    if (error instanceof Error) {
      errorMessage = error.message
    }

    return NextResponse.json(
      { 
        success: false, 
        message: errorMessage,
        error: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    )
  }
}
