import { NextRequest, NextResponse } from 'next/server'

const DEMO_COMPANIES = [
  {
    id: 'demo-comp-1',
    name: 'BioTech Innovations Inc.',
    website: 'https://biotechinnovations.com',
    industry: 'Biotechnology',
    funding_stage: 'Series B',
    location: 'Boston, MA, USA',
    description: 'AI-powered drug discovery platform leveraging machine learning to accelerate pharmaceutical development.',
    total_funding: 45000000,
    last_funding_date: '2024-06-15',
    employee_count: 125,
    crunchbase_url: 'https://crunchbase.com/organization/biotech-innovations',
    linkedin_url: 'https://linkedin.com/company/biotech-innovations',
    created_at: '2024-01-15T10:00:00Z',
    updated_at: '2024-09-07T15:30:00Z'
  },
  {
    id: 'demo-comp-2',
    name: 'GenomeTherapeutics',
    website: 'https://genometherapeutics.com',
    industry: 'Gene Therapy',
    funding_stage: 'Series A',
    location: 'San Francisco, CA, USA',
    description: 'Revolutionary gene therapy platform developing treatments for rare genetic diseases using CRISPR.',
    total_funding: 28000000,
    last_funding_date: '2024-03-20',
    employee_count: 67,
    created_at: '2024-02-20T14:00:00Z',
    updated_at: '2024-09-07T15:30:00Z'
  },
  {
    id: 'demo-comp-3',
    name: 'NeuralBio Systems',
    website: 'https://neuralbio.com',
    industry: 'Neurotechnology',
    funding_stage: 'Series C',
    location: 'Cambridge, MA, USA',
    description: 'Brain-computer interface technology for treating neurological disorders.',
    total_funding: 125000000,
    last_funding_date: '2024-01-10',
    employee_count: 245,
    created_at: '2024-03-10T09:00:00Z',
    updated_at: '2024-09-07T15:30:00Z'
  }
]

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('📊 Returning demo companies data')
      return NextResponse.json({
        success: true,
        companies: DEMO_COMPANIES,
        count: DEMO_COMPANIES.length,
        source: 'demo'
      })
    }

    // In production mode, try to fetch real data
    // For now, return empty since no real database is configured
    console.log('🔍 Production mode: No real database configured')
    
    return NextResponse.json({
      success: true,
      companies: [],
      count: 0,
      source: 'production',
      message: 'No companies found. Configure your database connection to see real data.'
    })

  } catch (error) {
    console.error('Companies API Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch companies',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
