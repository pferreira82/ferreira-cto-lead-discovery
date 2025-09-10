import { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const apolloApiKey = process.env.APOLLO_API_KEY
  
  if (!apolloApiKey) {
    return res.status(400).json({ error: 'Apollo API key not configured' })
  }

  try {
    // Very simple search to see what Apollo returns
    const response = await fetch('https://api.apollo.io/v1/organizations/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': apolloApiKey
      },
      body: JSON.stringify({
        page: 1,
        per_page: 10,
        q_keywords: 'biotech'
      })
    })

    if (!response.ok) {
      const error = await response.text()
      return res.status(response.status).json({ error })
    }

    const data = await response.json()
    
    // Show raw company data
    const companies = (data.organizations || []).map((org: any) => ({
      name: org.name,
      industry: org.industry,
      description: org.short_description,
      employees: org.estimated_num_employees,
      funding_stage: org.latest_funding_stage,
      location: `${org.city || 'Unknown'}, ${org.state || org.country || 'Unknown'}`,
      keywords: org.keywords?.slice(0, 15) || [],
      website: org.website_url
    }))

    res.status(200).json({
      success: true,
      message: `Apollo returned ${companies.length} companies for "biotech" search`,
      totalAvailable: data.pagination?.total_entries || 0,
      companies: companies
    })

  } catch (error) {
    res.status(500).json({
      error: 'Request failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    })
  }
}
