import { NextRequest, NextResponse } from 'next/server'

const DEMO_CAMPAIGNS = [
  {
    id: 'demo-campaign-1',
    name: 'Q4 Biotech CTO Outreach',
    subject: 'Technology Due Diligence for {{company_name}}',
    template_id: 'biotech-intro-1',
    status: 'sent',
    recipients_count: 45,
    sent_count: 45,
    delivered_count: 43,
    opened_count: 18,
    clicked_count: 7,
    replied_count: 3,
    bounced_count: 2,
    created_at: '2024-12-01T10:00:00Z',
    updated_at: '2024-12-15T14:30:00Z',
    sent_at: '2024-12-01T10:30:00Z'
  },
  {
    id: 'demo-campaign-2',
    name: 'VC Partnership Series B Focus',
    subject: 'Strategic Partnership - {{vc_firm_name}}',
    template_id: 'vc-partnership-1',
    status: 'sending',
    recipients_count: 25,
    sent_count: 12,
    delivered_count: 11,
    opened_count: 4,
    clicked_count: 2,
    replied_count: 1,
    bounced_count: 1,
    created_at: '2024-12-10T15:00:00Z',
    updated_at: '2024-12-15T16:00:00Z',
    sent_at: '2024-12-10T15:30:00Z'
  }
]

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('Returning demo campaigns data')
      const campaigns = DEMO_CAMPAIGNS.map(campaign => ({
        ...campaign,
        open_rate: campaign.sent_count > 0 ? ((campaign.opened_count / campaign.sent_count) * 100).toFixed(1) : '0.0',
        click_rate: campaign.sent_count > 0 ? ((campaign.clicked_count / campaign.sent_count) * 100).toFixed(1) : '0.0',
        reply_rate: campaign.sent_count > 0 ? ((campaign.replied_count / campaign.sent_count) * 100).toFixed(1) : '0.0'
      }))

      return NextResponse.json({ 
        success: true,
        campaigns,
        count: campaigns.length,
        source: 'demo'
      })
    }

    // Production mode - return empty campaigns
    console.log('Production mode: No real database configured for campaigns')
    
    return NextResponse.json({ 
      success: true,
      campaigns: [],
      count: 0,
      source: 'production',
      message: 'No campaigns found. Configure your database connection to see real campaigns.'
    })

  } catch (error) {
    console.error('Get Campaigns Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch campaigns',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    const campaignData = await request.json()
    console.log('Creating campaign:', campaignData)

    if (!campaignData.name) {
      return NextResponse.json(
        { error: 'Campaign name is required' },
        { status: 400 }
      )
    }

    if (demoMode) {
      const newCampaign = {
        id: `demo-campaign-${Date.now()}`,
        ...campaignData,
        recipients_count: 0,
        sent_count: 0,
        delivered_count: 0,
        opened_count: 0,
        clicked_count: 0,
        replied_count: 0,
        bounced_count: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        sent_at: campaignData.status === 'sending' ? new Date().toISOString() : null
      }

      return NextResponse.json({ 
        success: true,
        campaign: newCampaign,
        message: `Demo: Created "${campaignData.name}" campaign successfully`,
        source: 'demo'
      })
    }

    // Production mode
    return NextResponse.json({ 
      success: false,
      error: 'Campaign creation not available in production mode without database configuration',
      source: 'production'
    })

  } catch (error) {
    console.error('Create Campaign Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to create campaign',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
