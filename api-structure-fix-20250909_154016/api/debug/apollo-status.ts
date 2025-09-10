import { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const apolloApiKey = process.env.APOLLO_API_KEY
  
  if (!apolloApiKey) {
    return res.status(400).json({
      configured: false,
      message: 'Apollo API key not found in environment variables',
      recommendation: 'Add APOLLO_API_KEY to your .env.local file'
    })
  }

  try {
    // Test basic connectivity
    const testResponse = await fetch('https://api.apollo.io/v1/organizations/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': apolloApiKey
      },
      body: JSON.stringify({
        page: 1,
        per_page: 5,
        q_keywords: 'technology'
      })
    })

    const isWorking = testResponse.ok
    let data = null
    let errorMessage = null

    if (isWorking) {
      data = await testResponse.json()
    } else {
      errorMessage = await testResponse.text()
    }

    res.status(200).json({
      configured: true,
      working: isWorking,
      httpStatus: testResponse.status,
      companiesReturned: data?.organizations?.length || 0,
      totalAvailable: data?.pagination?.total_entries || 0,
      sampleCompany: data?.organizations?.[0]?.name || null,
      errorMessage: errorMessage,
      diagnosis: isWorking ? 
        'Apollo API is responding' : 
        `Apollo API error (${testResponse.status})`,
      recommendation: isWorking ?
        'API is working - check paid plan test for full functionality' :
        'Check API key validity and account status'
    })

  } catch (error) {
    res.status(500).json({
      configured: true,
      working: false,
      error: error instanceof Error ? error.message : 'Unknown error',
      diagnosis: 'Cannot connect to Apollo API',
      recommendation: 'Check internet connection and API key'
    })
  }
}
