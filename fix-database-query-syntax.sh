#!/bin/bash

echo "Fixing Database Query Syntax Error"
echo "=================================="

# Fix the database debug endpoint with proper Supabase syntax
echo "Fixing database connection debug endpoint..."
cat > app/api/debug/database/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'

export async function GET(request: NextRequest) {
  try {
    console.log('=== Database Debug Check ===')
    
    // Check environment variables
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY
    
    console.log('Supabase URL:', supabaseUrl ? `${supabaseUrl.substring(0, 30)}...` : 'NOT SET')
    console.log('Anon Key:', supabaseAnonKey ? `${supabaseAnonKey.substring(0, 20)}...` : 'NOT SET')
    console.log('Service Key:', supabaseServiceKey ? `${supabaseServiceKey.substring(0, 20)}...` : 'NOT SET')
    
    const envCheck = {
      hasUrl: !!supabaseUrl,
      hasAnonKey: !!supabaseAnonKey,
      hasServiceKey: !!supabaseServiceKey,
      isConfigured: isSupabaseConfigured(),
      adminClientExists: !!supabaseAdmin
    }
    
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return NextResponse.json({
        success: false,
        error: 'Supabase not properly configured',
        details: envCheck,
        message: 'Check your environment variables'
      })
    }
    
    // Test database connection with proper Supabase syntax
    console.log('Testing database connection...')
    
    // First, try to get company count using proper syntax
    const { count: companyCount, error: countError } = await supabaseAdmin
      .from('companies')
      .select('*', { count: 'exact', head: true })
    
    if (countError) {
      console.error('Database count error:', countError)
      return NextResponse.json({
        success: false,
        error: 'Database connection failed',
        details: {
          ...envCheck,
          databaseError: countError.message,
          errorCode: countError.code,
          hint: countError.hint
        }
      })
    }
    
    // Get some sample companies
    const { data: sampleCompanies, error: sampleError } = await supabaseAdmin
      .from('companies')
      .select('id, name, industry, funding_stage, location')
      .limit(5)
    
    // Test contacts table too
    const { count: contactCount, error: contactCountError } = await supabaseAdmin
      .from('contacts')
      .select('*', { count: 'exact', head: true })
    
    return NextResponse.json({
      success: true,
      message: 'Database connection successful',
      details: {
        ...envCheck,
        companyCount: companyCount || 0,
        contactCount: contactCount || 0,
        hasCompanies: (companyCount || 0) > 0,
        hasContacts: (contactCount || 0) > 0,
        sampleCompanies: sampleCompanies || [],
        errors: {
          sampleError: sampleError?.message,
          contactCountError: contactCountError?.message
        }
      }
    })
    
  } catch (error) {
    console.error('Database debug error:', error)
    return NextResponse.json({
      success: false,
      error: 'Database debug failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
EOF

# Also fix the discovery search endpoint to use correct syntax
echo "Fixing discovery search endpoint..."
cat > app/api/discovery/search/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'

// Demo biotech companies for discovery (fallback)
const DEMO_DISCOVERY_COMPANIES = [
  {
    id: 'discovery-1',
    company: 'Moderna',
    website: 'https://www.modernatx.com',
    industry: 'mRNA Therapeutics',
    description: 'mRNA therapeutics and vaccines company developing treatments for infectious diseases, immuno-oncology, rare diseases, and cardiovascular disease.',
    fundingStage: 'Public',
    totalFunding: 2600000000,
    employeeCount: 2800,
    location: 'Cambridge, MA, USA',
    foundedYear: 2010,
    ai_score: 95,
    contacts: [
      {
        name: 'Stéphane Bancel',
        title: 'Chief Executive Officer',
        email: 'stephane.bancel@modernatx.com',
        role_category: 'Executive',
        linkedin: 'https://linkedin.com/in/stephanebancel'
      }
    ]
  },
  {
    id: 'discovery-2',
    company: 'Ginkgo Bioworks',
    website: 'https://www.ginkgobioworks.com',
    industry: 'Synthetic Biology',
    description: 'Platform biotechnology company enabling customers to program cells as easily as we can program computers.',
    fundingStage: 'Public',
    totalFunding: 719000000,
    employeeCount: 1200,
    location: 'Boston, MA, USA',
    foundedYear: 2009,
    ai_score: 88,
    contacts: [
      {
        name: 'Jason Kelly',
        title: 'CEO & Co-Founder',
        email: 'jason.kelly@ginkgobioworks.com',
        role_category: 'Founder',
        linkedin: 'https://linkedin.com/in/jasonkelly'
      }
    ]
  }
]

export async function POST(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    const searchCriteria = await request.json()
    console.log('Discovery search criteria:', searchCriteria)
    console.log('Demo mode:', demoMode)

    if (demoMode) {
      console.log('Returning demo discovery results')
      
      // Filter demo results based on search criteria
      let filteredResults = [...DEMO_DISCOVERY_COMPANIES]
      
      if (searchCriteria.industries && searchCriteria.industries.length > 0) {
        filteredResults = filteredResults.filter(company => 
          searchCriteria.industries.some((industry: string) => 
            company.industry.toLowerCase().includes(industry.toLowerCase()) ||
            company.description.toLowerCase().includes(industry.toLowerCase())
          )
        )
      }
      
      if (searchCriteria.fundingStages && searchCriteria.fundingStages.length > 0) {
        filteredResults = filteredResults.filter(company => 
          searchCriteria.fundingStages.includes(company.fundingStage)
        )
      }
      
      const maxResults = searchCriteria.maxResults || 10
      filteredResults = filteredResults.slice(0, maxResults)
      
      return NextResponse.json({
        success: true,
        leads: filteredResults,
        totalCount: filteredResults.length,
        source: 'demo',
        message: `Found ${filteredResults.length} demo companies matching your criteria`
      })
    }

    // Production mode - query real database
    console.log('Production mode: Querying real database...')
    
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      console.log('Supabase not configured, falling back to demo data')
      return NextResponse.json({
        success: true,
        leads: DEMO_DISCOVERY_COMPANIES.slice(0, searchCriteria.maxResults || 10),
        totalCount: DEMO_DISCOVERY_COMPANIES.length,
        source: 'fallback_demo',
        message: 'Database not configured, showing demo data. Configure Supabase to see real companies.'
      })
    }
    
    // Build query with proper Supabase syntax
    let query = supabaseAdmin
      .from('companies')
      .select(`
        id,
        name,
        website,
        industry,
        description,
        funding_stage,
        total_funding,
        employee_count,
        location,
        created_at,
        contacts (
          id,
          first_name,
          last_name,
          email,
          title,
          role_category,
          linkedin_url
        )
      `)
    
    // Apply filters
    if (searchCriteria.industries && searchCriteria.industries.length > 0) {
      query = query.in('industry', searchCriteria.industries)
    }
    
    if (searchCriteria.fundingStages && searchCriteria.fundingStages.length > 0) {
      query = query.in('funding_stage', searchCriteria.fundingStages)
    }
    
    if (searchCriteria.locations && searchCriteria.locations.length > 0) {
      // Use ilike for partial location matching
      const locationFilter = searchCriteria.locations
        .map((loc: string) => `location.ilike.%${loc}%`)
        .join(',')
      query = query.or(locationFilter)
    }
    
    // Limit results
    const maxResults = Math.min(searchCriteria.maxResults || 50, 100)
    query = query.limit(maxResults)
    
    console.log('Executing database query...')
    const { data: companies, error } = await query
    
    if (error) {
      console.error('Database query error:', error)
      return NextResponse.json({
        success: false,
        error: 'Database query failed',
        message: error.message,
        details: {
          code: error.code,
          hint: error.hint
        },
        source: 'production'
      }, { status: 500 })
    }
    
    console.log(`Found ${companies?.length || 0} companies in database`)
    
    // Transform data to match expected format
    const leads = (companies || []).map(company => ({
      id: company.id,
      company: company.name,
      website: company.website,
      industry: company.industry,
      description: company.description,
      fundingStage: company.funding_stage,
      totalFunding: company.total_funding,
      employeeCount: company.employee_count,
      location: company.location,
      foundedYear: new Date(company.created_at).getFullYear(),
      ai_score: Math.floor(Math.random() * 30) + 70, // Random score for demo
      contacts: (company.contacts || []).map((contact: any) => ({
        name: `${contact.first_name} ${contact.last_name}`,
        title: contact.title,
        email: contact.email,
        role_category: contact.role_category,
        linkedin: contact.linkedin_url
      }))
    }))
    
    return NextResponse.json({
      success: true,
      leads,
      totalCount: leads.length,
      source: 'production',
      message: `Found ${leads.length} companies in your database`
    })

  } catch (error) {
    console.error('Discovery Search Error:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Search failed. Please try again.',
        message: error instanceof Error ? error.message : 'Unknown error occurred',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
EOF

echo ""
echo "Database Query Syntax Fixed!"
echo "============================"
echo ""
echo "Fixed issues:"
echo "• Corrected Supabase count() query syntax"
echo "• Used proper { count: 'exact', head: true } format"
echo "• Removed invalid select('count(*)') syntax"
echo "• Added proper error handling with hints"
echo ""
echo "Now restart your server and test again:"
echo "1. npm run dev"
echo "2. Visit /discovery"
echo "3. Click 'Test Database Connection'"
echo ""
echo "This should now work properly!"
