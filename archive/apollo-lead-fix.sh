#!/bin/bash

echo "Fixing Apollo sort criteria error..."

# Fix the biotech test endpoint first - remove sort criteria
cat > pages/api/debug/biotech-test.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const apolloApiKey = process.env.APOLLO_API_KEY
  
  if (!apolloApiKey) {
    return res.status(400).json({ error: 'Apollo API key not configured' })
  }

  try {
    console.log('Testing simple biotech search...')
    
    // Simple search - no sort criteria to avoid errors
    const response = await fetch('https://api.apollo.io/v1/organizations/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': apolloApiKey
      },
      body: JSON.stringify({
        page: 1,
        per_page: 10,
        q_keywords: 'biotechnology OR biotech'
        // Removed all sort criteria
      })
    })

    console.log('Apollo response status:', response.status)

    if (!response.ok) {
      const error = await response.text()
      console.error('Apollo error:', error)
      return res.status(response.status).json({ 
        error: 'Apollo API error',
        details: error,
        status: response.status
      })
    }

    const data = await response.json()
    console.log('Raw results:', data.organizations?.length || 0)

    // Filter for actual biotech companies
    const biotechCompanies = (data.organizations || []).filter((org: any) => {
      const searchText = `${org.name} ${org.industry || ''} ${org.short_description || ''}`.toLowerCase()
      return searchText.includes('biotech') || 
             searchText.includes('biotechnology') || 
             searchText.includes('pharmaceutical') ||
             searchText.includes('therapeutics')
    })

    console.log('Biotech companies found:', biotechCompanies.length)

    res.status(200).json({
      success: true,
      message: `Found ${biotechCompanies.length} biotech companies`,
      results: biotechCompanies.slice(0, 5).map((org: any) => ({
        name: org.name,
        industry: org.industry,
        employees: org.estimated_num_employees,
        funding_stage: org.latest_funding_stage,
        location: org.city ? `${org.city}, ${org.state || org.country}` : 'Unknown',
        description: org.short_description?.substring(0, 150) + '...'
      })),
      debug: {
        totalOrganizations: data.organizations?.length || 0,
        biotechFiltered: biotechCompanies.length,
        pagination: data.pagination
      }
    })

  } catch (error) {
    console.error('Test failed:', error)
    res.status(500).json({
      error: 'Request failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    })
  }
}
EOF

echo "Updated biotech test endpoint - try it now!"
echo "Visit: http://localhost:3000/api/debug/biotech-test"
