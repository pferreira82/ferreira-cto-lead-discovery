#!/bin/bash

echo "🔍 Debugging Apollo API Lead Discovery..."
echo "======================================="

# 1. Create Apollo API test endpoint
echo "📡 Creating Apollo API test endpoint..."
mkdir -p pages/api/debug
cat > pages/api/debug/apollo-test.ts << 'EOF'
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
EOF

# 2. Update the discovery search API with better debugging
echo "🔧 Updating discovery search with enhanced debugging..."
cat > pages/api/discovery/search.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'

const apolloApiKey = process.env.APOLLO_API_KEY

// Apollo industry tag mappings
const INDUSTRY_TAGS = {
  'Biotechnology': '5567cd4073696424b10b0000',
  'Pharmaceuticals': '5567cd4173696424b1120000',
  'Life Sciences': '5567cd4173696424b1130000',
  'Medical Device': '5567cd4173696424b1140000'
}

// Apollo funding stage mappings
const FUNDING_STAGES = {
  'Seed': 'Seed',
  'Series A': 'Series A',
  'Series B': 'Series B', 
  'Series C': 'Series C',
  'Series D': 'Series D'
}

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  console.log('🔍 Advanced search started with params:', req.body)

  try {
    const {
      targetTypes = ['companies'],
      industries = [],
      fundingStages = [],
      locations = [],
      excludeExisting = true,
      maxResults = 50,
      companySize = { min: 10, max: 1000 },
      fundingRange = { min: 1000000, max: 500000000 }
    } = req.body

    // Check Apollo API configuration
    if (!apolloApiKey) {
      console.error('❌ Apollo API key not configured')
      return res.status(400).json({
        error: 'Apollo API not configured',
        message: 'Please configure APOLLO_API_KEY environment variable',
        results: [],
        totalCount: 0
      })
    }

    console.log('✅ Apollo API key configured, length:', apolloApiKey.length)

    // Map industries to Apollo industry tag IDs
    const industryTagIds = industries
      .map(industry => INDUSTRY_TAGS[industry as keyof typeof INDUSTRY_TAGS])
      .filter(Boolean)

    console.log('🏭 Industry mapping:', { industries, industryTagIds })

    // Map funding stages
    const mappedFundingStages = fundingStages
      .map(stage => FUNDING_STAGES[stage as keyof typeof FUNDING_STAGES])
      .filter(Boolean)

    console.log('💰 Funding stage mapping:', { fundingStages, mappedFundingStages })

    // Build Apollo search payload
    const searchPayload = {
      page: 1,
      per_page: Math.min(maxResults, 100),
      organization_locations: locations,
      industry_tag_ids: industryTagIds,
      funding_stage_list: mappedFundingStages,
      organization_num_employees_ranges: [`${companySize.min}-${companySize.max}`],
      sort_by_field: 'organization_last_funding_date',
      sort_ascending: false
    }

    console.log('📡 Apollo API payload:', JSON.stringify(searchPayload, null, 2))

    // Call Apollo API
    const apolloResponse = await fetch('https://api.apollo.io/v1/organizations/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'X-Api-Key': apolloApiKey
      },
      body: JSON.stringify(searchPayload)
    })

    console.log('📊 Apollo API response status:', apolloResponse.status)

    if (!apolloResponse.ok) {
      const errorText = await apolloResponse.text()
      console.error('❌ Apollo API error:', errorText)
      
      return res.status(apolloResponse.status).json({
        error: 'Apollo API request failed',
        message: errorText,
        results: [],
        totalCount: 0
      })
    }

    const apolloData = await apolloResponse.json()
    console.log('✅ Apollo API success:', {
      organizationsFound: apolloData.organizations?.length || 0,
      totalCount: apolloData.pagination?.total_entries || 0,
      pagination: apolloData.pagination
    })

    // Process and format the results
    const companies = apolloData.organizations?.map((org: any) => ({
      id: org.id,
      name: org.name,
      website: org.website_url,
      industry: org.industry,
      description: org.short_description,
      funding_stage: org.latest_funding_stage,
      total_funding: org.total_funding,
      employee_count: org.estimated_num_employees,
      location: org.primary_location?.city ? 
        `${org.primary_location.city}, ${org.primary_location.state || org.primary_location.country}` : 
        'Unknown',
      founded_year: org.founded_year,
      apollo_id: org.id,
      logo_url: org.logo_url,
      crunchbase_url: org.crunchbase_url,
      ai_score: calculateAIScore(org),
      source: 'apollo'
    })) || []

    console.log('🎯 Processed companies:', companies.length)
    console.log('🔍 Sample result:', companies[0] || 'No results')

    res.status(200).json({
      results: companies,
      totalCount: apolloData.pagination?.total_entries || 0,
      source: 'apollo',
      searchParams: searchPayload,
      debug: {
        apolloResponseCount: apolloData.organizations?.length || 0,
        industryTagIds,
        mappedFundingStages,
        apolloApiConfigured: true
      }
    })

    console.log(`✅ Advanced search completed: ${companies.length} leads found`)

  } catch (error) {
    console.error('💥 Search error:', error)
    res.status(500).json({
      error: 'Lead discovery failed',
      message: error instanceof Error ? error.message : 'Unknown error',
      results: [],
      totalCount: 0
    })
  }
}

function calculateAIScore(org: any) {
  let score = 50 // Base score
  
  // Boost for recent funding
  if (org.latest_funding_date) {
    const fundingDate = new Date(org.latest_funding_date)
    const monthsAgo = (Date.now() - fundingDate.getTime()) / (1000 * 60 * 60 * 24 * 30)
    if (monthsAgo < 12) score += 20
    else if (monthsAgo < 24) score += 10
  }
  
  // Boost for AI/biotech keywords
  const description = (org.short_description || '').toLowerCase()
  const aiKeywords = ['artificial intelligence', 'machine learning', 'ai', 'biotech', 'biotechnology', 'drug discovery', 'therapeutics']
  const keywordBoost = aiKeywords.filter(keyword => description.includes(keyword)).length * 5
  score += keywordBoost
  
  // Employee count factor
  if (org.estimated_num_employees > 50 && org.estimated_num_employees < 500) {
    score += 15 // Sweet spot for consulting engagement
  }
  
  return Math.min(100, Math.max(0, score))
}
EOF

# 3. Test the Apollo API configuration
echo "🧪 Creating test script..."
cat > test-apollo.js << 'EOF'
const fetch = require('node-fetch');
require('dotenv').config({ path: '.env.local' });

async function testApolloAPI() {
  const apiKey = process.env.APOLLO_API_KEY;
  
  console.log('Testing Apollo API...');
  console.log('API Key configured:', !!apiKey);
  console.log('API Key length:', apiKey?.length || 0);
  
  if (!apiKey) {
    console.error('❌ No Apollo API key found in .env.local');
    return;
  }

  try {
    const response = await fetch('https://api.apollo.io/v1/organizations/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': apiKey
      },
      body: JSON.stringify({
        page: 1,
        per_page: 5,
        organization_locations: ['United States'],
        industry_tag_ids: ['5567cd4073696424b10b0000'], // Biotechnology
        organization_num_employees_ranges: ['11-50'],
        funding_stage_list: ['Series A']
      })
    });

    console.log('Response status:', response.status);
    
    if (response.ok) {
      const data = await response.json();
      console.log('✅ Success! Found', data.organizations?.length || 0, 'organizations');
      console.log('Sample company:', data.organizations?.[0]?.name || 'No companies found');
    } else {
      const error = await response.text();
      console.error('❌ Error:', error);
    }
  } catch (error) {
    console.error('❌ Request failed:', error.message);
  }
}

testApolloAPI();
EOF

echo ""
echo "✅ Apollo API Debugging Setup Complete!"
echo ""
echo "🔍 To debug the 0 results issue:"
echo ""
echo "1. Test Apollo API directly:"
echo "   node test-apollo.js"
echo ""
echo "2. Check API endpoint in browser:"
echo "   http://localhost:3000/api/debug/apollo-test"
echo ""
echo "3. Check your .env.local file has:"
echo "   APOLLO_API_KEY=your-actual-apollo-api-key"
echo ""
echo "4. Verify Apollo API key is valid at:"
echo "   https://app.apollo.io/settings/integrations"
echo ""
echo "💡 Common issues causing 0 results:"
echo "   - Missing or invalid Apollo API key"
echo "   - Overly restrictive search parameters"
echo "   - Apollo API rate limiting"
echo "   - Industry tag IDs not matching Apollo's system"
echo ""
echo "Run the tests above to identify the exact issue!"
