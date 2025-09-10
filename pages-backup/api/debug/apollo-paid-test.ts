import { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const apolloApiKey = process.env.APOLLO_API_KEY
  
  if (!apolloApiKey) {
    return res.status(400).json({ error: 'Apollo API key not configured' })
  }

  try {
    console.log('=== TESTING PAID APOLLO PLAN ===')
    
    const testSearches = [
      { name: 'Biotech', payload: { page: 1, per_page: 5, q_keywords: 'biotechnology' } },
      { name: 'Pharma', payload: { page: 1, per_page: 5, q_keywords: 'pharmaceutical' } },
      { name: 'Software', payload: { page: 1, per_page: 5, q_keywords: 'software startup' } },
      { name: 'Fintech', payload: { page: 1, per_page: 5, q_keywords: 'fintech' } },
      { name: 'Biotech Boston', payload: { page: 1, per_page: 5, q_keywords: 'biotech', organization_locations: ['Boston'] } }
    ]

    const results = []
    const allCompanies = new Set()

    for (const test of testSearches) {
      console.log(`Testing: ${test.name}`)
      
      const response = await fetch('https://api.apollo.io/v1/organizations/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': apolloApiKey
        },
        body: JSON.stringify(test.payload)
      })

      if (response.ok) {
        const data = await response.json()
        const orgs = data.organizations || []
        
        orgs.forEach((org: any) => allCompanies.add(org.name))
        
        const biotechRelevant = orgs.filter((org: any) => {
          const text = `${org.name} ${org.industry || ''} ${org.short_description || ''}`.toLowerCase()
          return text.includes('biotech') || text.includes('biotechnology') || 
                 text.includes('pharmaceutical') || text.includes('therapeutics') ||
                 text.includes('drug') || text.includes('life sciences')
        })
        
        results.push({
          search: test.name,
          companies: orgs.slice(0, 3).map((org: any) => ({
            name: org.name,
            industry: org.industry,
            employees: org.estimated_num_employees,
            location: org.city ? `${org.city}, ${org.state || org.country}` : 'Unknown'
          })),
          totalAvailable: data.pagination?.total_entries || 0,
          biotechRelevant: test.name.includes('Biotech') ? biotechRelevant.length : undefined
        })
        
        console.log(`${test.name}: ${orgs.length} companies, ${data.pagination?.total_entries} total`)
      } else {
        const error = await response.text()
        console.error(`${test.name} failed:`, error)
        results.push({ search: test.name, error: error, status: response.status })
      }
    }

    const uniqueCount = allCompanies.size
    const totalBiotechRelevant = results.reduce((sum, r) => sum + (r.biotechRelevant || 0), 0)
    
    // Determine if paid plan is working
    const isPaidWorking = uniqueCount > 12
    const hasGoodBiotechResults = totalBiotechRelevant > 0
    
    let status = 'UNKNOWN'
    let nextSteps = []
    
    if (isPaidWorking && hasGoodBiotechResults) {
      status = 'EXCELLENT - Paid plan working perfectly'
      nextSteps = ['Your Apollo paid plan is active and finding biotech companies!', 'You can now use real Apollo data for lead discovery']
    } else if (isPaidWorking) {
      status = 'GOOD - Paid plan working, biotech search needs tuning'
      nextSteps = ['Paid plan is active but biotech searches need refinement', 'Try more specific biotech keywords']
    } else if (uniqueCount > 5) {
      status = 'PARTIAL - Some improvement, may need more time'
      nextSteps = ['Plan partially active - wait 30 more minutes', 'Check Apollo billing dashboard', 'Try regenerating API key']
    } else {
      status = 'LIMITED - Still using free/limited results'
      nextSteps = ['Paid plan not yet active', 'Check billing in Apollo dashboard', 'Contact Apollo support', 'Wait up to 1 hour for activation']
    }

    res.status(200).json({
      status: status,
      isPaidPlanWorking: isPaidWorking,
      hasGoodBiotechResults: hasGoodBiotechResults,
      uniqueCompaniesAcrossSearches: uniqueCount,
      biotechCompaniesFound: totalBiotechRelevant,
      results: results,
      allUniqueCompanies: Array.from(allCompanies).slice(0, 20),
      nextSteps: nextSteps,
      recommendation: isPaidWorking ? 'UPDATE_TO_APOLLO' : 'KEEP_DEMO_DATA'
    })

  } catch (error) {
    console.error('Paid plan test failed:', error)
    res.status(500).json({
      error: 'Test failed',
      message: error instanceof Error ? error.message : 'Unknown error',
      recommendation: 'KEEP_DEMO_DATA'
    })
  }
}
