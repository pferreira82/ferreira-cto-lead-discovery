import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

let supabase = null
if (supabaseUrl && supabaseKey) {
  supabase = createClient(supabaseUrl, supabaseKey)
}

// Demo campaigns for testing
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

export default async function handler(req, res) {
  // Handle different methods
  switch (req.method) {
    case 'GET':
      return getCampaigns(req, res)
    case 'POST':
      return createCampaign(req, res)
    case 'PUT':
      return updateCampaign(req, res)
    default:
      res.setHeader('Allow', ['GET', 'POST', 'PUT'])
      res.status(405).end(`Method ${req.method} Not Allowed`)
  }
}

async function getCampaigns(req, res) {
  try {
    console.log('📥 GET /api/campaigns - Fetching campaigns')
    
    // Always return demo data for now
    const campaigns = DEMO_CAMPAIGNS.map(campaign => ({
      ...campaign,
      // Calculate rates
      open_rate: campaign.sent_count > 0 ? ((campaign.opened_count / campaign.sent_count) * 100).toFixed(1) : '0.0',
      click_rate: campaign.sent_count > 0 ? ((campaign.clicked_count / campaign.sent_count) * 100).toFixed(1) : '0.0',
      reply_rate: campaign.sent_count > 0 ? ((campaign.replied_count / campaign.sent_count) * 100).toFixed(1) : '0.0'
    }))

    console.log('✅ Returning campaigns:', campaigns.length)
    res.status(200).json({ 
      success: true,
      campaigns,
      count: campaigns.length 
    })

  } catch (error) {
    console.error('❌ Get Campaigns Error:', error)
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch campaigns',
      message: error.message 
    })
  }
}

async function createCampaign(req, res) {
  try {
    console.log('📤 POST /api/campaigns - Creating campaign')
    console.log('📝 Request body:', req.body)

    const campaignData = req.body

    // Validate required fields
    if (!campaignData.name) {
      return res.status(400).json({ 
        success: false,
        error: 'Campaign name is required' 
      })
    }

    if (!campaignData.template_id) {
      return res.status(400).json({ 
        success: false,
        error: 'Template ID is required' 
      })
    }

    // Simulate successful creation in demo mode
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

    console.log('✅ Demo campaign created:', newCampaign.id)

    res.status(201).json({ 
      success: true,
      campaign: newCampaign,
      message: `Demo: Created "${campaignData.name}" campaign successfully`
    })

  } catch (error) {
    console.error('❌ Create Campaign Error:', error)
    res.status(500).json({ 
      success: false,
      error: 'Failed to create campaign',
      message: error.message 
    })
  }
}

async function updateCampaign(req, res) {
  try {
    const { id } = req.query
    const updateData = req.body

    console.log('🔄 PUT /api/campaigns - Updating campaign:', id)

    // In demo mode, just return success
    res.status(200).json({ 
      success: true,
      message: `Demo: Campaign ${id} updated successfully`
    })

  } catch (error) {
    console.error('❌ Update Campaign Error:', error)
    res.status(500).json({ 
      success: false,
      error: 'Failed to update campaign',
      message: error.message 
    })
  }
}
