import { NextRequest, NextResponse } from 'next/server'
import { supabase, supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'

export async function POST(request: NextRequest) {
  try {
    if (!isSupabaseConfigured()) {
      return NextResponse.json({
        success: false,
        message: 'Supabase not configured',
        companies: [],
        contacts: []
      }, { status: 500 })
    }

    const client = typeof window === 'undefined' ? (supabaseAdmin || supabase) : supabase
    if (!client) {
      return NextResponse.json({
        success: false,
        message: 'Supabase client not available',
        companies: [],
        contacts: []
      }, { status: 500 })
    }

    // Get existing companies (with Apollo IDs if they exist)
    const { data: companies, error: companiesError } = await client
      .from('companies')
      .select('id, name, apollo_id')
      .not('name', 'is', null)

    if (companiesError) {
      console.error('Error fetching existing companies:', companiesError)
      throw companiesError
    }

    // Get existing contacts (with Apollo IDs if they exist)
    const { data: contacts, error: contactsError } = await client
      .from('contacts')
      .select('id, email, apollo_id, first_name, last_name')

    if (contactsError) {
      console.error('Error fetching existing contacts:', contactsError)
      throw contactsError
    }

    console.log(`Retrieved ${companies?.length || 0} existing companies and ${contacts?.length || 0} existing contacts for duplicate detection`)

    return NextResponse.json({
      success: true,
      companies: companies || [],
      contacts: contacts || []
    })

  } catch (error) {
    console.error('Error getting existing data:', error)
    
    return NextResponse.json({
      success: false,
      message: error instanceof Error ? error.message : 'Failed to get existing data',
      companies: [],
      contacts: []
    }, { status: 500 })
  }
}
