import { NextApiRequest, NextApiResponse } from 'next'
import { createClient } from '@supabase/supabase-js'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    console.log('Testing Supabase connection...')
    console.log('URL configured:', !!supabaseUrl)
    console.log('Key configured:', !!supabaseKey)

    if (!supabaseUrl || !supabaseKey) {
      return res.status(400).json({
        error: 'Missing environment variables',
        hasUrl: !!supabaseUrl,
        hasKey: !!supabaseKey,
        urlValue: supabaseUrl ? 'SET' : 'MISSING',
        keyValue: supabaseKey ? 'SET' : 'MISSING'
      })
    }

    const supabase = createClient(supabaseUrl, supabaseKey)

    // Test basic connection
    const { data, error, count } = await supabase
      .from('contacts')
      .select('id', { count: 'exact', head: true })

    if (error) {
      console.error('Supabase query error:', error)
      return res.status(500).json({
        error: 'Database query failed',
        details: error.message,
        code: error.code
      })
    }

    return res.status(200).json({
      status: 'success',
      message: 'Supabase connection working',
      contactCount: count,
      timestamp: new Date().toISOString()
    })

  } catch (error) {
    console.error('API test error:', error)
    return res.status(500).json({
      error: 'Test failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    })
  }
}
