import { NextRequest, NextResponse } from 'next/server'
import { supabase, supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'

export async function POST(request: NextRequest) {
  try {
    const searchCriteria = await request.json()
    
    console.log('Checking existing data for criteria:', searchCriteria)

    if (!isSupabaseConfigured()) {
      return NextResponse.json({
        success: false,
        message: 'Supabase not configured',
        companiesCount: 0,
        contactsCount: 0
      }, { status: 500 })
    }

    const client = typeof window === 'undefined' ? (supabaseAdmin || supabase) : supabase
    if (!client) {
      return NextResponse.json({
        success: false,
        message: 'Supabase client not available',
        companiesCount: 0,
        contactsCount: 0
      }, { status: 500 })
    }

    // Get existing companies count
    const { count: companiesCount, error: companiesError } = await client
      .from('companies')
      .select('*', { count: 'exact', head: true })
      .not('name', 'is', null)

    if (companiesError) {
      console.error('Error counting companies:', companiesError)
      throw companiesError
    }

    // Get existing contacts count
    const { count: contactsCount, error: contactsError } = await client
      .from('contacts')
      .select('*', { count: 'exact', head: true })

    if (contactsError) {
      console.error('Error counting contacts:', contactsError)
      throw contactsError
    }

    // Get sample company names for display
    const { data: sampleCompanies, error: sampleError } = await client
      .from('companies')
      .select('name')
      .not('name', 'is', null)
      .limit(10)

    if (sampleError) {
      console.error('Error fetching sample companies:', sampleError)
    }

    const sampleNames = (sampleCompanies || []).map(c => c.name)

    console.log(`Found ${companiesCount || 0} existing companies and ${contactsCount || 0} existing contacts`)

    return NextResponse.json({
      success: true,
      companiesCount: companiesCount || 0,
      contactsCount: contactsCount || 0,
      sampleNames: sampleNames,
      message: `Found ${companiesCount || 0} companies and ${contactsCount || 0} contacts in your database`
    })

  } catch (error) {
    console.error('Error checking existing data:', error)
    
    return NextResponse.json({
      success: false,
      message: error instanceof Error ? error.message : 'Failed to check existing data',
      companiesCount: 0,
      contactsCount: 0
    }, { status: 500 })
  }
}
