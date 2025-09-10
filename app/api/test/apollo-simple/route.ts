import { NextRequest, NextResponse } from 'next/server'

export async function GET() {
  try {
    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured'
      })
    }

    // Absolutely minimal test - no filters at all
    const simpleParams = {
      page: 1,
      per_page: 3
    }

    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY
      },
      body: JSON.stringify(simpleParams)
    })

    const data = await response.json()
    
    return NextResponse.json({
      success: response.ok,
      results: {
        companiesReturned: data.accounts?.length || 0,
        totalAvailable: data.pagination?.total_entries || 0,
        companies: data.accounts?.slice(0, 3).map((c: any) => ({
          name: c.name,
          website: c.website_url,
          location: c.headquarters_address
        })) || []
      }
    })

  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
