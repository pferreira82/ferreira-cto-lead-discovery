import { NextRequest, NextResponse } from 'next/server'

export async function GET() {
  try {
    if (!process.env.APOLLO_API_KEY) {
      return NextResponse.json({
        success: false,
        error: 'Apollo API key not configured'
      })
    }

    // Test with minimal parameters
    const testParams = {
      page: 1,
      per_page: 5,
      organization_locations: ['United States']
    }

    console.log('Testing Apollo with minimal params')
    
    const response = await fetch('https://api.apollo.io/api/v1/mixed_companies/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': process.env.APOLLO_API_KEY
      },
      body: JSON.stringify(testParams)
    })

    const data = await response.json()
    
    console.log('Apollo Response Keys:', Object.keys(data))
    console.log('Accounts array exists:', !!data.accounts)
    console.log('Accounts length:', data.accounts?.length || 0)
    console.log('Total entries:', data.pagination?.total_entries || 0)

    return NextResponse.json({
      success: true,
      results: {
        accountsFound: data.accounts?.length || 0,
        totalAvailable: data.pagination?.total_entries || 0,
        responseKeys: Object.keys(data),
        hasAccountsArray: !!data.accounts,
        pagination: data.pagination,
        firstCompany: data.accounts?.[0] ? {
          name: data.accounts[0].name,
          website: data.accounts[0].website_url,
          industry: data.accounts[0].industry
        } : null
      },
      rawResponse: data
    })

  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
