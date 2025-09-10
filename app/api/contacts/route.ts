import { NextRequest, NextResponse } from 'next/server'

const DEMO_CONTACTS = [
  {
    id: 'demo-contact-1',
    company_id: 'demo-comp-1',
    first_name: 'Sarah',
    last_name: 'Chen',
    email: 'sarah.chen@biotechinnovations.com',
    title: 'CEO & Co-Founder',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/sarahchen-biotech',
    contact_status: 'not_contacted',
    created_at: '2024-01-15T10:30:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-2',
    company_id: 'demo-comp-1',
    first_name: 'Michael',
    last_name: 'Rodriguez',
    email: 'm.rodriguez@biotechinnovations.com',
    title: 'Chief Technology Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/mrodriguez-cto',
    contact_status: 'contacted',
    last_contacted_at: '2024-09-05T10:30:00Z',
    created_at: '2024-01-15T11:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-3',
    company_id: 'demo-comp-2',
    first_name: 'James',
    last_name: 'Liu',
    email: 'james.liu@genometherapeutics.com',
    title: 'CEO',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/jamesliu-genomics',
    contact_status: 'responded',
    last_contacted_at: '2024-09-04T14:22:00Z',
    created_at: '2024-02-20T14:30:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  }
]

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('📊 Returning demo contacts data')
      return NextResponse.json({
        success: true,
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo'
      })
    }

    // Production mode - try to fetch real data
    console.log('🔍 Production mode: No real database configured')
    
    return NextResponse.json({
      success: true,
      contacts: [],
      count: 0,
      source: 'production',
      message: 'No contacts found. Configure your database connection to see real data.'
    })

  } catch (error) {
    console.error('Contacts API Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch contacts',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
