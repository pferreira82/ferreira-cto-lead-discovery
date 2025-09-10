import { NextApiRequest, NextApiResponse } from 'next'
import { isSupabaseConfigured, supabaseAdmin } from '../../../lib/supabase'

// Demo companies data
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
    employee_count: 125,
    created_at: '2024-01-15T10:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
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
    employee_count: 67,
    created_at: '2024-02-20T14:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
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
    employee_count: 245,
    created_at: '2024-03-10T09:00:00Z',
    updated_at: '2024-09-08T15:30:00Z'
  }
]

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    if (!supabaseAdmin) {
      return res.status(500).json({ error: "Database not configured", message: "Supabase configuration is missing" })
    }
    // If Supabase is not configured, return demo data
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      console.log('Supabase not configured, returning demo companies data')
      return res.status(200).json({
        companies: DEMO_COMPANIES,
        count: DEMO_COMPANIES.length,
        source: 'demo'
      })
    }

    // Fetch real companies from Supabase
    const { data: companies, error, count } = await supabaseAdmin
      .from('companies')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .limit(100)

    if (error) {
      console.error('Supabase query error:', error)
      // Fallback to demo data on error
      return res.status(200).json({
        companies: DEMO_COMPANIES,
        count: DEMO_COMPANIES.length,
        source: 'demo_fallback',
        error: 'Database query failed'
      })
    }

    res.status(200).json({
      companies: companies || [],
      count: count || 0,
      source: 'production'
    })

  } catch (error) {
    console.error('Companies API Error:', error)
    // Fallback to demo data on any error
    res.status(200).json({
      companies: DEMO_COMPANIES,
      count: DEMO_COMPANIES.length,
      source: 'demo_fallback',
      error: 'API error occurred'
    })
  }
}
