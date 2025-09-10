import { NextApiRequest, NextApiResponse } from 'next'
import { isSupabaseConfigured, supabaseAdmin } from '../../../lib/supabase'

// Demo contacts data
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
  },
  {
    id: 'demo-contact-4',
    company_id: 'demo-comp-3',
    first_name: 'Amanda',
    last_name: 'Foster',
    email: 'amanda.foster@neuralbio.com',
    title: 'Co-Founder & CEO',
    role_category: 'Founder',
    contact_status: 'interested',
    last_contacted_at: '2024-09-06T16:15:00Z',
    created_at: '2024-03-10T09:30:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  },
  {
    id: 'demo-contact-5',
    company_id: 'demo-comp-3',
    first_name: 'David',
    last_name: 'Park',
    email: 'd.park@neuralbio.com',
    title: 'Chief Technology Officer',
    role_category: 'Executive',
    contact_status: 'not_contacted',
    created_at: '2024-03-10T10:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  }
]

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    // If Supabase is not configured, return demo data
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      console.log('Supabase not configured, returning demo contacts data')
      return res.status(200).json({
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo'
      })
    }

    // Fetch real contacts from Supabase with company information
    const { data: contacts, error, count } = await supabaseAdmin
      .from('contacts')
      .select(`
        *,
        companies (
          name,
          industry,
          funding_stage
        )
      `, { count: 'exact' })
      .order('created_at', { ascending: false })
      .limit(500)

    if (error) {
      console.error('Supabase query error:', error)
      // Fallback to demo data on error
      return res.status(200).json({
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo_fallback',
        error: 'Database query failed'
      })
    }

    res.status(200).json({
      contacts: contacts || [],
      count: count || 0,
      source: 'production'
    })

  } catch (error) {
    console.error('Contacts API Error:', error)
    // Fallback to demo data on any error
    res.status(200).json({
      contacts: DEMO_CONTACTS,
      count: DEMO_CONTACTS.length,
      source: 'demo_fallback',
      error: 'API error occurred'
    })
  }
}
