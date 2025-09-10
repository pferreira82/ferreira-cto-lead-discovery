import { NextApiRequest, NextApiResponse } from 'next'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

function isSupabaseConfigured(): boolean {
  return !!(supabaseUrl && supabaseKey && supabaseUrl !== 'your-project-url' && supabaseKey !== 'your-service-role-key')
}

const DEMO_CAMPAIGNS = [
  {
    id: 'demo-1',
    name: 'Biotech CTO Outreach - Q4 2024',
    subject: 'Technology Due Diligence for {{company_name}}',
    status: 'completed',
    sent_at: '2024-09-01T10:00:00Z',
    recipient_count: 150,
    sent_count: 148,
    delivered_count: 145,
    opened_count: 89,
    clicked_count: 23,
    replied_count: 12,
    created_at: '2024-08-28T09:00:00Z',
    template_name: 'Biotech Introduction'
  },
  {
    id: 'demo-2',
    name: 'VC Partnership Series A-C',
    subject: 'Technology Due Diligence Partnership - {{vc_firm_name}}',
    status: 'sending',
    scheduled_at: '2024-09-08T14:00:00Z',
    recipient_count: 45,
    sent_count: 32,
    delivered_count: 31,
    opened_count: 18,
    clicked_count: 7,
    replied_count: 3,
    created_at: '2024-09-05T11:30:00Z',
    template_name: 'VC Partnership'
  }
]

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  switch (req.method) {
    case 'GET':
      return getCampaigns(req, res)
    case 'POST':
      return createCampaign(req, res)
    default:
      res.setHeader('Allow', ['GET', 'POST'])
      res.status(405).end(`Method ${req.method} Not Allowed`)
  }
}

async function getCampaigns(req: NextApiRequest, res: NextApiResponse) {
  try {
    if (!isSupabaseConfigured()) {
      return res.status(200).json({
        campaigns: DEMO_CAMPAIGNS,
        source: 'demo'
      })
    }

    const supabase = createClient(supabaseUrl, supabaseKey)
    
    const { data: campaigns, error } = await supabase
      .from('email_campaigns')
      .select(`
        *,
        email_templates (
          name
        )
      `)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Supabase error:', error)
      return res.status(200).json({
        campaigns: DEMO_CAMPAIGNS,
        source: 'demo_fallback'
      })
    }

    const formattedCampaigns = campaigns?.map(campaign => ({
      ...campaign,
      template_name: campaign.email_templates?.name
    })) || []

    res.status(200).json({
      campaigns: formattedCampaigns,
      source: 'production'
    })
  } catch (error) {
    console.error('Campaigns API Error:', error)
    res.status(200).json({
      campaigns: DEMO_CAMPAIGNS,
      source: 'error_fallback'
    })
  }
}

async function createCampaign(req: NextApiRequest, res: NextApiResponse) {
  try {
    if (!isSupabaseConfigured()) {
      return res.status(200).json({
        message: 'Demo mode: Campaign would be created',
        campaign: { id: 'demo-new', ...req.body }
      })
    }

    const supabase = createClient(supabaseUrl, supabaseKey)
    const campaignData = req.body

    const { data, error } = await supabase
      .from('email_campaigns')
      .insert(campaignData)
      .select()
      .single()

    if (error) throw error

    res.status(201).json(data)
  } catch (error) {
    console.error('Create Campaign Error:', error)
    res.status(500).json({ error: 'Failed to create campaign' })
  }
}
