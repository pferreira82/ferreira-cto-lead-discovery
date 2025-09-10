#!/bin/bash

echo "🚀 Complete Apollo Lead Discovery Fix Script"
echo "==========================================="
echo "This script will:"
echo "1. Test your paid Apollo plan"
echo "2. Update discovery API to use real Apollo data"
echo "3. Create fallback systems"
echo "4. Provide diagnostics"
echo ""

# Ensure required directories exist
mkdir -p pages/api/debug
mkdir -p pages/api/discovery

# 1. Create comprehensive Apollo paid plan test
echo "📊 Creating Apollo paid plan test..."
cat > pages/api/debug/apollo-paid-test.ts << 'EOF'
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
EOF

# 2. Create smart discovery API that uses Apollo if available, demo data as fallback
echo "🔍 Creating smart discovery API with Apollo + demo fallback..."
cat > pages/api/discovery/search.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'

// Curated biotech companies (fallback data)
const BIOTECH_DEMO_COMPANIES = [
  {
    id: 'bt-001', name: 'Moderna', website: 'https://www.modernatx.com',
    industry: 'mRNA Therapeutics', description: 'mRNA therapeutics and vaccines company developing treatments for infectious diseases, immuno-oncology, rare diseases, and cardiovascular disease.',
    funding_stage: 'Public', total_funding: 2600000000, employee_count: 2800,
    location: 'Cambridge, MA, USA', founded_year: 2010, ai_score: 95, source: 'demo'
  },
  {
    id: 'bt-002', name: 'Ginkgo Bioworks', website: 'https://www.ginkgobioworks.com',
    industry: 'Synthetic Biology', description: 'Platform biotechnology company enabling customers to program cells as easily as we can program computers.',
    funding_stage: 'Public', total_funding: 719000000, employee_count: 1200,
    location: 'Boston, MA, USA', founded_year: 2009, ai_score: 88, source: 'demo'
  },
  {
    id: 'bt-003', name: 'Recursion Pharmaceuticals', website: 'https://www.recursion.com',
    industry: 'AI Drug Discovery', description: 'Clinical-stage biotechnology company industrializing drug discovery by decoding biology using AI and automation.',
    funding_stage: 'Public', total_funding: 525000000, employee_count: 450,
    location: 'Salt Lake City, UT, USA', founded_year: 2013, ai_score: 92, source: 'demo'
  },
  {
    id: 'bt-004', name: 'AbCellera', website: 'https://www.abcellera.com',
    industry: 'Antibody Discovery', description: 'Technology company that searches, decodes, and analyzes natural immune systems to find antibodies for drug development.',
    funding_stage: 'Public', total_funding: 554000000, employee_count: 350,
    location: 'Vancouver, BC, Canada', founded_year: 2012, ai_score: 85, source: 'demo'
  },
  {
    id: 'bt-005', name: 'Beam Therapeutics', website: 'https://www.beamtx.com',
    industry: 'Gene Editing', description: 'Biotechnology company developing precision genetic medicines through base editing to provide new treatment options.',
    funding_stage: 'Public', total_funding: 387000000, employee_count: 280,
    location: 'Cambridge, MA, USA', founded_year: 2017, ai_score: 90, source: 'demo'
  },
  {
    id: 'bt-006', name: 'Zymergen', website: 'https://www.zymergen.com',
    industry: 'Synthetic Biology', description: 'Biofacturing company that designs microbes to manufacture specialty chemicals and materials.',
    funding_stage: 'Series C', total_funding: 574000000, employee_count: 750,
    location: 'Emeryville, CA, USA', founded_year: 2013, ai_score: 82, source: 'demo'
  },
  {
    id: 'bt-007', name: 'Tempus', website: 'https://www.tempus.com',
    industry: 'Precision Medicine', description: 'Technology company that has built an operating system to battle cancer by using AI and machine learning.',
    funding_stage: 'Series G', total_funding: 1100000000, employee_count: 1800,
    location: 'Chicago, IL, USA', founded_year: 2015, ai_score: 93, source: 'demo'
  },
  {
    id: 'bt-008', name: 'Grail', website: 'https://www.grail.com',
    industry: 'Early Cancer Detection', description: 'Healthcare company focused on early detection of cancer using breakthrough genomic sequencing technologies.',
    funding_stage: 'Series C', total_funding: 1900000000, employee_count: 1500,
    location: 'Menlo Park, CA, USA', founded_year: 2016, ai_score: 91, source: 'demo'
  },
  {
    id: 'bt-009', name: 'Caribou Biosciences', website: 'https://www.cariboubio.com',
    industry: 'CRISPR Gene Editing', description: 'Leading CRISPR company developing transformative therapies that harness the immune system to fight disease.',
    funding_stage: 'Public', total_funding: 304000000, employee_count: 180,
    location: 'Berkeley, CA, USA', founded_year: 2011, ai_score: 87, source: 'demo'
  },
  {
    id: 'bt-010', name: 'Twist Bioscience', website: 'https://www.twistbioscience.com',
    industry: 'DNA Synthesis', description: 'Company enabling customers to succeed through its offering of high-quality synthetic DNA using silicon platform.',
    funding_stage: 'Public', total_funding: 253000000, employee_count: 500,
    location: 'South San Francisco, CA, USA', founded_year: 2013, ai_score: 84, source: 'demo'
  },
  {
    id: 'bt-011', name: 'Notable Labs', website: 'https://www.notablelabs.com',
    industry: 'AI Drug Discovery', description: 'Precision medicine company using AI and functional precision medicine to match cancer patients with treatments.',
    funding_stage: 'Series A', total_funding: 35000000, employee_count: 45,
    location: 'Foster City, CA, USA', founded_year: 2017, ai_score: 89, source: 'demo'
  },
  {
    id: 'bt-012', name: 'Benchling', website: 'https://www.benchling.com',
    industry: 'Life Sciences Software', description: 'Cloud platform for biotechnology research and development, informatics, and analytics.',
    funding_stage: 'Series F', total_funding: 425000000, employee_count: 800,
    location: 'San Francisco, CA, USA', founded_year: 2012, ai_score: 86, source: 'demo'
  }
]

const apolloApiKey = process.env.APOLLO_API_KEY

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  console.log('🔍 Lead discovery search started:', req.body)

  try {
    const {
      industries = [],
      fundingStages = [],
      locations = [],
      maxResults = 50,
      companySize = { min: 10, max: 1000 },
      fundingRange = { min: 1000000, max: 500000000 }
    } = req.body

    // Try Apollo first if API key is available
    if (apolloApiKey) {
      console.log('🚀 Trying Apollo API search...')
      try {
        const apolloResults = await searchWithApollo(req.body)
        if (apolloResults && apolloResults.length > 0) {
          console.log(`✅ Apollo found ${apolloResults.length} companies`)
          return res.status(200).json({
            results: apolloResults,
            totalCount: apolloResults.length,
            source: 'apollo_api',
            message: 'Results from Apollo API'
          })
        }
      } catch (apolloError) {
        console.warn('Apollo search failed, falling back to demo data:', apolloError)
      }
    }

    // Fallback to demo data with filtering
    console.log('📊 Using curated biotech demo data...')
    let results = [...BIOTECH_DEMO_COMPANIES]

    // Apply filters
    if (industries.length > 0) {
      results = results.filter(company => 
        industries.some(industry => 
          company.industry.toLowerCase().includes(industry.toLowerCase())
        )
      )
    }

    if (fundingStages.length > 0 && !fundingStages.includes('Public')) {
      results = results.filter(company => 
        fundingStages.includes(company.funding_stage)
      )
    }

    if (locations.length > 0) {
      results = results.filter(company =>
        locations.some(location =>
          company.location.toLowerCase().includes(location.toLowerCase())
        )
      )
    }

    if (companySize) {
      results = results.filter(company =>
        company.employee_count >= companySize.min &&
        company.employee_count <= companySize.max
      )
    }

    if (fundingRange) {
      results = results.filter(company =>
        company.total_funding >= fundingRange.min &&
        company.total_funding <= fundingRange.max
      )
    }

    results = results.slice(0, maxResults)

    console.log(`✅ Demo data search completed: ${results.length} companies found`)

    res.status(200).json({
      results: results,
      totalCount: results.length,
      source: apolloApiKey ? 'demo_fallback' : 'demo_only',
      message: apolloApiKey ? 
        'Apollo API available but returned no results - using curated biotech database' :
        'Using curated biotech database - configure Apollo API for more companies'
    })

  } catch (error) {
    console.error('💥 Discovery search error:', error)
    res.status(500).json({
      error: 'Lead discovery failed',
      message: error instanceof Error ? error.message : 'Unknown error',
      results: [],
      totalCount: 0
    })
  }
}

async function searchWithApollo(searchParams: any) {
  const { industries = [], locations = [], maxResults = 50 } = searchParams
  
  // Build biotech-focused Apollo search strategies
  const searchStrategies = [
    {
      q_keywords: 'biotechnology OR biotech OR biopharmaceutical',
      page: 1, per_page: Math.min(maxResults, 25)
    },
    {
      q_keywords: 'pharmaceutical OR therapeutics OR drug discovery',
      page: 1, per_page: Math.min(maxResults, 25)
    },
    {
      q_keywords: 'life sciences OR medical device OR gene therapy',
      page: 1, per_page: Math.min(maxResults, 25)
    }
  ]

  // Add location filter if specified
  if (locations.length > 0) {
    searchStrategies.forEach(strategy => {
      strategy.organization_locations = locations
    })
  }

  const allCompanies = []

  for (const strategy of searchStrategies) {
    try {
      const response = await fetch('https://api.apollo.io/v1/organizations/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': apolloApiKey
        },
        body: JSON.stringify(strategy)
      })

      if (response.ok) {
        const data = await response.json()
        const organizations = data.organizations || []
        
        // Process and filter for biotech relevance
        const processedCompanies = organizations
          .filter((org: any) => {
            const text = `${org.name} ${org.industry || ''} ${org.short_description || ''}`.toLowerCase()
            return text.includes('biotech') || text.includes('biotechnology') || 
                   text.includes('pharmaceutical') || text.includes('therapeutics') ||
                   text.includes('drug') || text.includes('life sciences') ||
                   text.includes('gene') || text.includes('medical device')
          })
          .map((org: any) => ({
            id: org.id,
            name: org.name,
            website: org.website_url,
            industry: org.industry,
            description: org.short_description,
            funding_stage: org.latest_funding_stage,
            total_funding: org.total_funding,
            employee_count: org.estimated_num_employees,
            location: org.city ? `${org.city}, ${org.state || org.country}` : 'Unknown',
            founded_year: org.founded_year,
            logo_url: org.logo_url,
            ai_score: calculateAIScore(org),
            source: 'apollo'
          }))

        allCompanies.push(...processedCompanies)
        
        if (allCompanies.length >= maxResults) break
      }
    } catch (strategyError) {
      console.warn('Apollo strategy failed:', strategyError)
    }
  }

  // Remove duplicates and limit results
  const uniqueCompanies = allCompanies.filter((company, index, self) => 
    index === self.findIndex(c => c.name.toLowerCase() === company.name.toLowerCase())
  )

  return uniqueCompanies.slice(0, maxResults)
}

function calculateAIScore(org: any) {
  let score = 50
  
  const text = `${org.name} ${org.short_description} ${org.industry}`.toLowerCase()
  
  // Biotech relevance
  if (text.includes('biotech') || text.includes('biotechnology')) score += 20
  if (text.includes('drug discovery') || text.includes('therapeutics')) score += 15
  if (text.includes('pharmaceutical')) score += 15
  if (text.includes('crispr') || text.includes('gene')) score += 10
  
  // AI/tech boost
  if (text.includes('ai') || text.includes('machine learning')) score += 10
  
  // Recent funding
  if (org.latest_funding_date) {
    const monthsAgo = (Date.now() - new Date(org.latest_funding_date).getTime()) / (1000 * 60 * 60 * 24 * 30)
    if (monthsAgo < 12) score += 15
  }
  
  // Company size sweet spot
  if (org.estimated_num_employees > 25 && org.estimated_num_employees < 500) score += 10
  
  return Math.min(100, Math.max(0, score))
}
EOF

# 3. Create Apollo status checker
echo "📋 Creating Apollo status checker..."
cat > pages/api/debug/apollo-status.ts << 'EOF'
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
EOF

# 4. Create simple test runner script
echo "🧪 Creating test runner..."
cat > test-apollo-setup.js << 'EOF'
const fetch = require('node-fetch');

async function testSetup() {
  const baseUrl = 'http://localhost:3000/api/debug';
  
  console.log('🧪 Testing Apollo Setup...\n');
  
  try {
    // Test 1: Apollo Status
    console.log('1. Testing Apollo API status...');
    const statusRes = await fetch(`${baseUrl}/apollo-status`);
    const statusData = await statusRes.json();
    console.log(`   Status: ${statusData.diagnosis}`);
    console.log(`   Working: ${statusData.working}`);
    console.log(`   Companies returned: ${statusData.companiesReturned}\n`);
    
    // Test 2: Paid Plan Test
    console.log('2. Testing paid plan functionality...');
    const paidRes = await fetch(`${baseUrl}/apollo-paid-test`);
    const paidData = await paidRes.json();
    console.log(`   Status: ${paidData.status}`);
    console.log(`   Unique companies: ${paidData.uniqueCompaniesAcrossSearches}`);
    console.log(`   Biotech companies found: ${paidData.biotechCompaniesFound}`);
    console.log(`   Recommendation: ${paidData.recommendation}\n`);
    
    // Test 3: Discovery API
    console.log('3. Testing discovery search...');
    const discoveryRes = await fetch('http://localhost:3000/api/discovery/search', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        industries: ['Biotechnology'],
        fundingStages: ['Series A', 'Series B', 'Series C'],
        maxResults: 10
      })
    });
    const discoveryData = await discoveryRes.json();
    console.log(`   Companies found: ${discoveryData.totalCount}`);
    console.log(`   Data source: ${discoveryData.source}`);
    console.log(`   Message: ${discoveryData.message}\n`);
    
    // Summary
    console.log('📊 SUMMARY:');
    console.log(`   Apollo API: ${statusData.working ? 'Working' : 'Not working'}`);
    console.log(`   Paid Plan: ${paidData.isPaidPlanWorking ? 'Active' : 'Not active'}`);
    console.log(`   Discovery: ${discoveryData.totalCount} companies available`);
    console.log(`   Data Source: ${discoveryData.source}`);
    
  } catch (error) {
    console.error('Test failed:', error.message);
    console.log('\nMake sure your dev server is running: npm run dev');
  }
}

testSetup();
EOF

echo ""
echo "✅ All files created! Now running tests..."
echo ""

# Check if Node.js is available and dev server is running
if command -v node >/dev/null 2>&1; then
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo "🧪 Running automated tests..."
        node test-apollo-setup.js
    else
        echo "⚠️  Dev server not running. Start it with: npm run dev"
        echo "   Then run: node test-apollo-setup.js"
    fi
else
    echo "📝 Manual testing URLs:"
    echo "   1. Apollo Status: http://localhost:3000/api/debug/apollo-status"
    echo "   2. Paid Plan Test: http://localhost:3000/api/debug/apollo-paid-test"
    echo "   3. Discovery Test: http://localhost:3000/discovery"
fi

echo ""
echo "🎯 What this script created:"
echo "   ✅ Comprehensive Apollo paid plan test"
echo "   ✅ Smart discovery API (Apollo + demo fallback)"
echo "   ✅ Apollo status checker"
echo "   ✅ Automated test runner"
echo ""
echo "📊 Next steps:"
echo "   1. Check test results above"
echo "   2. If Apollo paid plan is working: Great! You'll get real biotech companies"
echo "   3. If not: You'll get curated demo companies while Apollo activates"
echo "   4. Visit /discovery page to test lead discovery"
echo ""
echo "🔧 Your lead discovery system now works regardless of Apollo status!"
