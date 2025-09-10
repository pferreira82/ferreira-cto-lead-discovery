import { NextApiRequest, NextApiResponse } from 'next'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

function isSupabaseConfigured(): boolean {
  return !!(supabaseUrl && supabaseKey && supabaseUrl !== 'your-project-url' && supabaseKey !== 'your-service-role-key')
}

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    const {
      target_types,
      industries,
      funding_stages,
      role_categories,
      locations,
      exclude_contacted
    } = req.body

    if (!isSupabaseConfigured()) {
      // Mock estimation for demo mode
      let estimate = 50
      if (target_types?.includes('vc_firms')) estimate += 15
      if (industries?.length > 3) estimate += 25
      if (locations?.length > 2) estimate += 30
      
      return res.status(200).json({
        count: Math.min(estimate, 150),
        source: 'demo'
      })
    }

    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // Build the query based on targeting criteria
    let contactsQuery = supabase
      .from('contacts')
      .select('id', { count: 'exact', head: true })

    // Filter by role categories
    if (role_categories && role_categories.length > 0) {
      contactsQuery = contactsQuery.in('role_category', role_categories)
    }

    // Exclude contacted if requested
    if (exclude_contacted) {
      contactsQuery = contactsQuery.eq('contact_status', 'not_contacted')
    }

    // For company/vc filtering, we need to join with companies table
    if (target_types && (industries?.length > 0 || funding_stages?.length > 0 || locations?.length > 0)) {
      // This would require more complex query building based on your schema
      // For now, we'll do a simplified count
    }

    const { count, error } = await contactsQuery

    if (error) {
      console.error('Supabase error:', error)
      return res.status(200).json({
        count: 25, // Fallback estimate
        source: 'error_fallback'
      })
    }

    res.status(200).json({
      count: count || 0,
      source: 'production'
    })
  } catch (error) {
    console.error('Estimate Recipients API Error:', error)
    res.status(500).json({ error: 'Failed to estimate recipients' })
  }
}
