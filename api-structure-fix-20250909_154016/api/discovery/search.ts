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

  const allCompanies: any[] = []

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
