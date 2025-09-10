import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    console.log('Testing Apollo API connection...')
    
    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured',
        message: 'Set APOLLO_API_KEY in your environment variables'
      })
    }

    // Test with a simple search for biotech companies using correct API format
    const testParams = {
      q_organization_keyword_tags: ['biotech', 'biotechnology'],
      organization_locations: ['United States'],
      per_page: 5,
      page: 1
    }

    console.log('Testing Apollo with params:', testParams)
    
    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Accept': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY  // CORRECT: API key in header
      },
      body: JSON.stringify(testParams)
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Apollo API error: ${response.status} - ${errorText}`)
    }

    const data = await response.json()
    
    return NextResponse.json({
      success: true,
      message: 'Apollo API connection successful',
      results: {
        companiesFound: data.accounts?.length || 0,
        totalAvailable: data.pagination?.total_entries || 0,
        sampleCompanies: data.accounts?.slice(0, 3).map((company: any) => ({
          name: company.name,
          industry: company.industry,
          location: company.headquarters_address,
          website: company.website_url,
          employees: company.estimated_num_employees,
          funding: company.total_funding
        }))
      },
      pagination: data.pagination
    })

  } catch (error) {
    console.error('Apollo API test failed:', error)
    return NextResponse.json({
      success: false,
      error: 'Apollo API test failed',
      message: error instanceof Error ? error.message : 'Unknown error',
      details: error instanceof Error ? error.stack : undefined
    }, { status: 500 })
  }
}
