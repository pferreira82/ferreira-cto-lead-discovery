#!/bin/bash

echo "🔍 Creating Apollo Debug Endpoint..."
echo "=================================="

# Ensure the debug directory exists
mkdir -p pages/api/debug

# Create the comprehensive debug endpoint
cat > pages/api/debug/apollo-debug.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const apolloApiKey = process.env.APOLLO_API_KEY
  
  if (!apolloApiKey) {
    return res.status(400).json({ error: 'Apollo API key not configured' })
  }

  try {
    console.log('=== DEBUGGING APOLLO SEARCH RESULTS ===')
    
    // Test different search approaches
    const searchTests = [
      {
        name: 'Keywords Only',
        payload: {
          page: 1,
          per_page: 5,
          q_keywords: 'biotechnology OR biotech'
        }
      },
      {
        name: 'Industry Filter',
        payload: {
          page: 1,
          per_page: 5,
          industry_tag_ids: ['5567cd4073696424b10b0000'] // Biotechnology industry ID
        }
      },
      {
        name: 'Broad Keywords',
        payload: {
          page: 1,
          per_page: 5,
          q_keywords: 'pharmaceutical OR therapeutics OR drug'
        }
      },
      {
        name: 'Life Sciences',
        payload: {
          page: 1,
          per_page: 5,
          q_keywords: 'life sciences OR medical device'
        }
      },
      {
        name: 'No Filters',
        payload: {
          page: 1,
          per_page: 5
        }
      }
    ]

    const results = []

    for (const test of searchTests) {
      console.log(`\n--- Testing: ${test.name} ---`)
      console.log('Payload:', JSON.stringify(test.payload, null, 2))

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
        const organizations = data.organizations || []
        
        console.log(`${test.name} returned ${organizations.length} orgs`)
        
        // Show detailed info about what was returned
        const detailedResults = organizations.map((org: any, index: number) => {
          const searchableText = `${org.name || ''} ${org.industry || ''} ${org.short_description || ''}`.toLowerCase()
          
          return {
            index: index + 1,
            name: org.name,
            industry: org.industry,
            description: org.short_description?.substring(0, 200),
            employees: org.estimated_num_employees,
            funding_stage: org.latest_funding_stage,
            location: org.city ? `${org.city}, ${org.state || org.country}` : 'Unknown',
            keywords: org.keywords?.slice(0, 10) || [],
            searchableText: searchableText.substring(0, 300),
            containsBiotech: searchableText.includes('biotech'),
            containsBiotechnology: searchableText.includes('biotechnology'),
            containsPharmaceutical: searchableText.includes('pharmaceutical'),
            containsTherapeutics: searchableText.includes('therapeutics'),
            containsLifeSciences: searchableText.includes('life sciences'),
            containsMedical: searchableText.includes('medical')
          }
        })

        results.push({
          testName: test.name,
          totalFound: organizations.length,
          totalAvailable: data.pagination?.total_entries || 0,
          companies: detailedResults,
          biotechMatches: detailedResults.filter(r => r.containsBiotech || r.containsBiotechnology || r.containsPharmaceutical || r.containsTherapeutics).length
        })

        // Log detailed results for this test
        detailedResults.forEach(result => {
          console.log(`  ${result.index}. ${result.name} (${result.industry})`)
          console.log(`     Location: ${result.location}`)
          console.log(`     Employees: ${result.employees}`)
          console.log(`     Funding: ${result.funding_stage}`)
          console.log(`     Keywords: ${result.keywords.join(', ')}`)
          console.log(`     Biotech matches: biotech=${result.containsBiotech}, biotechnology=${result.containsBiotechnology}`)
          console.log(`     Pharma matches: pharmaceutical=${result.containsPharmaceutical}, therapeutics=${result.containsTherapeutics}`)
          console.log(`     Description: ${result.description?.substring(0, 100)}...`)
          console.log('')
        })
      } else {
        const error = await response.text()
        console.error(`${test.name} failed:`, error)
        results.push({
          testName: test.name,
          error: error,
          status: response.status
        })
      }
    }

    res.status(200).json({
      message: 'Apollo search debugging complete',
      results: results,
      summary: {
        testsRun: searchTests.length,
        totalCompaniesFound: results.reduce((sum, r) => sum + (r.totalFound || 0), 0),
        totalBiotechMatches: results.reduce((sum, r) => sum + (r.biotechMatches || 0), 0)
      },
      recommendations: generateRecommendations(results)
    })

  } catch (error) {
    console.error('Debug test failed:', error)
    res.status(500).json({
      error: 'Debug test failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    })
  }
}

function generateRecommendations(results: any[]) {
  const recommendations = []
  
  // Check which searches found the most biotech companies
  const biotechResults = results.filter(r => r.biotechMatches > 0)
  if (biotechResults.length > 0) {
    const best = biotechResults.sort((a, b) => b.biotechMatches - a.biotechMatches)[0]
    recommendations.push(`Best search strategy: "${best.testName}" found ${best.biotechMatches} biotech companies`)
  } else {
    recommendations.push('No biotech companies found with current search strategies')
  }
  
  // Check if industry filter works
  const industryResult = results.find(r => r.testName === 'Industry Filter')
  if (industryResult && industryResult.totalFound > 0) {
    recommendations.push('Industry filter is working - use industry_tag_ids in searches')
  } else {
    recommendations.push('Industry filter may not be working - use keyword searches instead')
  }
  
  // Check if keywords work
  const keywordResult = results.find(r => r.testName === 'Keywords Only')
  if (keywordResult && keywordResult.totalFound > 0) {
    recommendations.push('Keyword search is working - use q_keywords parameter')
  }
  
  return recommendations
}
EOF

echo "✅ Debug endpoint created!"

# Also update the simple biotech test to show raw data
cat > pages/api/debug/biotech-simple.ts << 'EOF'
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
EOF

echo "✅ Simple biotech test endpoint created!"

echo ""
echo "🧪 Testing Apollo Debug Endpoints..."
echo ""

# Check if dev server is running
if ! curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "⚠️  Dev server not running. Start it with: npm run dev"
    echo ""
fi

echo "📊 Test URLs:"
echo "1. Comprehensive Debug: http://localhost:3000/api/debug/apollo-debug"
echo "2. Simple Biotech Test: http://localhost:3000/api/debug/biotech-simple" 
echo "3. Original Test: http://localhost:3000/api/debug/apollo-test"
echo ""
echo "🔍 What to look for:"
echo "- Which search strategies return biotech companies"
echo "- Whether industry filters work better than keywords"
echo "- What company data Apollo actually provides"
echo "- Recommendations for best search approach"
echo ""
echo "💡 After testing, share the results and I'll create the optimized search strategy!"
