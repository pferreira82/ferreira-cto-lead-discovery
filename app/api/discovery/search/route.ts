import { NextRequest, NextResponse } from 'next/server'
import { ApolloService } from '@/lib/services/apollo'

export async function POST(request: NextRequest) {
  try {
    const searchCriteria = await request.json()
    
    console.log('Discovery search criteria:', searchCriteria)

    // Initialize Apollo service
    const apollo = new ApolloService()

    // Use enhanced search with complete organization details
    const results = await apollo.searchCompaniesWithExecutives(
      searchCriteria,
      (step: string, current: number, total: number) => {
        console.log(`Progress: ${step} (${current}/${total})`)
      }
    )

    // Transform results with RICH DATA from complete organization info
    const transformedLeads = results.companies.map((company: any) => {
      return {
        id: company.id,
        company: company.name,
        website: company.website_url,
        industry: company.industry || 'Unknown',
        fundingStage: company.funding_info?.stage || company.latest_funding_stage,
        description: company.short_description || company.description || `${company.name} is a company in the ${company.industry || 'biotech'} industry.`,
        location: company.location || 'Unknown', // Short format for table
        full_address: company.full_address || company.raw_address || company.location || 'Unknown', // Full format for detail view
        totalFunding: company.funding_info?.total_funding || company.total_funding,
        totalFundingPrinted: company.funding_info?.total_funding_printed || company.total_funding_printed,
        employeeCount: company.estimated_num_employees || company.organization_headcount,
        foundedYear: company.founded_year,
        ai_score: company.ai_score,
        domain: company.domain,
        logo_url: company.logo_url,
        // RICH FUNDING DATA
        funding_info: {
          ...company.funding_info,
          events: company.funding_events || []
        },
        // RICH COMPANY DATA
        short_description: company.short_description,
        revenue_info: company.revenue_info,
        latest_investors: company.latest_investors,
        all_investors: company.all_investors,
        keywords: company.keywords || [],
        // LOCATION DATA
        address_components: {
          street_address: company.street_address,
          city: company.city,
          state: company.state,
          postal_code: company.postal_code,
          country: company.country,
          raw_address: company.raw_address
        },
        contacts: company.contacts || []
      }
    })

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

    console.log(`Enhanced search completed: ${transformedLeads.length} companies with full details, ${results.totalContacts} contacts, ${transformedVCs.length} VCs`)

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
