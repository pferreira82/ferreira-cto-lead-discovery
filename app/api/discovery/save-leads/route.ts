import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    const { leads } = await request.json()

    if (!leads || !Array.isArray(leads)) {
      return NextResponse.json(
        { success: false, error: 'Invalid leads data. Expected array of leads.' },
        { status: 400 }
      )
    }

    console.log(`Saving ${leads.length} leads to database...`)

    if (demoMode) {
      // Simulate save operation in demo mode
      await new Promise(resolve => setTimeout(resolve, 1500))
      
      const companiesCount = leads.length
      const contactsCount = leads.reduce((sum: number, lead: any) => sum + (lead.contacts?.length || 0), 0)
      
      return NextResponse.json({
        success: true,
        results: {
          companies: companiesCount,
          contacts: contactsCount,
          errors: []
        },
        message: `Demo: Simulated save of ${companiesCount} companies and ${contactsCount} contacts`,
        source: 'demo'
      })
    }

    // Production mode - no real database configured
    return NextResponse.json({
      success: false,
      error: 'Save functionality not available in production mode without database configuration',
      message: 'Configure your database connection to save leads',
      source: 'production'
    })

  } catch (error) {
    console.error('Save Leads API Error:', error)
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to save leads',
        message: error instanceof Error ? error.message : 'Unknown error occurred'
      },
      { status: 500 }
    )
  }
}
