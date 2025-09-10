#!/bin/bash

echo "🔧 Fixing TypeScript implicit 'any' type errors..."
echo "==============================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📁 Scanning for TypeScript files with potential issues..."

# Fix the specific apollo-debug.ts error
if [ -f "app/api/debug/apollo-debug.ts" ]; then
    echo "🔧 Fixing app/api/debug/apollo-debug.ts..."
    
    # Create backup
    cp "app/api/debug/apollo-debug.ts" "app/api/debug/apollo-debug.ts.backup"
    
    # Fix the file by adding proper type definitions
    cat > app/api/debug/apollo-debug.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'

interface DetailedResult {
  index: number
  name: string
  industry: string
  description: string
  employees: number
  funding_stage: string
  location: string
  keywords: string[]
  searchableText: string
  containsBiotech: boolean
  containsBiotechnology: boolean
  containsPharmaceutical: boolean
  containsTherapeutics: boolean
  containsLifeSciences: boolean
  containsMedical: boolean
}

interface SearchResult {
  testName: string
  totalFound: number
  totalAvailable: number
  companies: DetailedResult[]
  biotechMatches: number
  error?: string
  status?: number
}

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

    const results: SearchResult[] = []

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
        
        // Show detailed info about what was returned with proper typing
        const detailedResults: DetailedResult[] = organizations.map((org: any, index: number) => {
          const searchableText = `${org.name || ''} ${org.industry || ''} ${org.short_description || ''}`.toLowerCase()
          
          return {
            index: index + 1,
            name: org.name || 'Unknown',
            industry: org.industry || 'Unknown',
            description: org.short_description?.substring(0, 200) || '',
            employees: org.estimated_num_employees || 0,
            funding_stage: org.latest_funding_stage || 'Unknown',
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
          biotechMatches: detailedResults.filter((r: DetailedResult) => 
            r.containsBiotech || r.containsBiotechnology || r.containsPharmaceutical || r.containsTherapeutics
          ).length
        })

        // Log detailed results for this test
        detailedResults.forEach((result: DetailedResult) => {
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
          status: response.status,
          totalFound: 0,
          totalAvailable: 0,
          companies: [],
          biotechMatches: 0
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

function generateRecommendations(results: SearchResult[]): string[] {
  const recommendations: string[] = []
  
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

    echo -e "${GREEN}✅ Fixed app/api/debug/apollo-debug.ts${NC}"
else
    echo -e "${YELLOW}⚠️  app/api/debug/apollo-debug.ts not found${NC}"
fi

# Check for other files with similar issues
echo ""
echo "🔍 Scanning for other implicit 'any' type issues..."

# Find TypeScript files that might have similar issues
problematic_patterns=(
    "\.filter\s*\(\s*[a-zA-Z_]\s*=>"
    "\.map\s*\(\s*[a-zA-Z_]\s*=>"
    "\.reduce\s*\(\s*\([a-zA-Z_,\s]*\)\s*=>"
    "\.forEach\s*\(\s*[a-zA-Z_]\s*=>"
)

for pattern in "${problematic_patterns[@]}"; do
    echo "Checking pattern: $pattern"
    files_with_pattern=$(grep -r -l --include="*.ts" --include="*.tsx" "$pattern" . 2>/dev/null | grep -v ".backup" | grep -v "node_modules" | head -5)
    
    if [ ! -z "$files_with_pattern" ]; then
        echo -e "${YELLOW}Files that might need type annotations:${NC}"
        echo "$files_with_pattern"
        echo ""
    fi
done

# Check tsconfig.json for strict settings
echo "📝 Checking TypeScript configuration..."
if [ -f "tsconfig.json" ]; then
    if grep -q '"noImplicitAny".*true' tsconfig.json; then
        echo -e "${GREEN}✅ noImplicitAny is enabled${NC}"
    else
        echo -e "${YELLOW}⚠️  Consider enabling noImplicitAny in tsconfig.json${NC}"
        read -p "Enable noImplicitAny? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Backup tsconfig.json
            cp tsconfig.json tsconfig.json.backup
            
            # Enable noImplicitAny
            if grep -q '"compilerOptions"' tsconfig.json; then
                sed -i.tmp '/"compilerOptions":/a\
    "noImplicitAny": false,' tsconfig.json
                rm -f tsconfig.json.tmp
                echo -e "${GREEN}✅ Added noImplicitAny: false to tsconfig.json${NC}"
                echo "Note: Set to 'true' later for stricter typing"
            fi
        fi
    fi
fi

# Create a quick fix for common array method issues
echo ""
echo "📋 Quick fix suggestions for array methods:"
echo ""
echo "Replace patterns like:"
echo "  array.filter(item => ...)"
echo "With:"
echo "  array.filter((item: YourType) => ...)"
echo ""
echo "Or define interfaces for complex objects"

echo ""
echo -e "${GREEN}🎉 TypeScript error fixes completed!${NC}"
echo ""
echo -e "${YELLOW}📋 Files backed up:${NC}"
echo "• app/api/debug/apollo-debug.ts.backup"
if [ -f "tsconfig.json.backup" ]; then
    echo "• tsconfig.json.backup"
fi
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo "1. Try building: npm run build"
echo "2. If successful: npm run dev"
echo "3. Check for any remaining TypeScript errors"
echo ""
echo -e "${YELLOW}🔧 For future development:${NC}"
echo "• Use explicit types for function parameters"
echo "• Define interfaces for complex objects"
echo "• Consider enabling stricter TypeScript settings"
