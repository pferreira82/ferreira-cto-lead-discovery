import { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const apolloApiKey = process.env.APOLLO_API_KEY
  
  console.log('=== Apollo API Debug ===')
  console.log('Apollo API Key configured:', !!apolloApiKey)
  console.log('Apollo API Key length:', apolloApiKey?.length || 0)
  console.log('Apollo API Key preview:', apolloApiKey ? `${apolloApiKey.substring(0, 8)}...` : 'Not set')
  
  if (!apolloApiKey) {
    return res.status(400).json({
      error: 'Apollo API key not configured',
      message: 'Please set APOLLO_API_KEY in your environment variables'
    })
  }

  try {
    // Test Apollo API connection
    const response = await fetch('https://api.apollo.io/v1/organizations/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'X-Api-Key': apolloApiKey
      },
      body: JSON.stringify({
        page: 1,
        per_page: 10,
        organization_locations: ['United States'],
        industry_tag_ids: ['5567cd4073696424b10b0000'], // Biotechnology
        organization_num_employees_ranges: ['11-50', '51-200'],
        funding_stage_list: ['Series A', 'Series B']
      })
    })

    console.log('Apollo API Response Status:', response.status)
    console.log('Apollo API Response Headers:', Object.fromEntries(response.headers))

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Apollo API Error Response:', errorText)
      
      return res.status(response.status).json({
        error: 'Apollo API request failed',
        status: response.status,
        message: errorText
      })
    }

    const data = await response.json()
    console.log('Apollo API Success - Organizations found:', data.organizations?.length || 0)
    console.log('Apollo API Pagination:', data.pagination)

    res.status(200).json({
      success: true,
      message: `Found ${data.organizations?.length || 0} organizations`,
      sampleData: data.organizations?.slice(0, 2) || [],
      pagination: data.pagination,
      apiKeyValid: true
    })

  } catch (error) {
    console.error('Apollo API Test Error:', error)
    res.status(500).json({
      error: 'Apollo API test failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    })
  }
}
