import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'

export async function GET(request: NextRequest) {
  try {
    console.log('=== Database Debug Check ===')
    
    // Check environment variables
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY
    
    console.log('Supabase URL:', supabaseUrl ? `${supabaseUrl.substring(0, 30)}...` : 'NOT SET')
    console.log('Anon Key:', supabaseAnonKey ? `${supabaseAnonKey.substring(0, 20)}...` : 'NOT SET')
    console.log('Service Key:', supabaseServiceKey ? `${supabaseServiceKey.substring(0, 20)}...` : 'NOT SET')
    
    const envCheck = {
      hasUrl: !!supabaseUrl,
      hasAnonKey: !!supabaseAnonKey,
      hasServiceKey: !!supabaseServiceKey,
      isConfigured: isSupabaseConfigured(),
      adminClientExists: !!supabaseAdmin
    }
    
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return NextResponse.json({
        success: false,
        error: 'Supabase not properly configured',
        details: envCheck,
        message: 'Check your environment variables'
      })
    }
    
    // Test database connection
    console.log('Testing database connection...')
    const { data: testData, error: testError } = await supabaseAdmin
      .from('companies')
      .select('count(*)', { count: 'exact' })
      .limit(1)
    
    if (testError) {
      console.error('Database test error:', testError)
      return NextResponse.json({
        success: false,
        error: 'Database connection failed',
        details: {
          ...envCheck,
          databaseError: testError.message,
          errorCode: testError.code
        }
      })
    }
    
    // Get actual company count
    const { count: companyCount, error: countError } = await supabaseAdmin
      .from('companies')
      .select('*', { count: 'exact', head: true })
    
    // Get some sample companies
    const { data: sampleCompanies, error: sampleError } = await supabaseAdmin
      .from('companies')
      .select('id, name, industry, funding_stage, location')
      .limit(5)
    
    return NextResponse.json({
      success: true,
      message: 'Database connection successful',
      details: {
        ...envCheck,
        companyCount: companyCount || 0,
        hasCompanies: (companyCount || 0) > 0,
        sampleCompanies: sampleCompanies || [],
        errors: {
          countError: countError?.message,
          sampleError: sampleError?.message
        }
      }
    })
    
  } catch (error) {
    console.error('Database debug error:', error)
    return NextResponse.json({
      success: false,
      error: 'Database debug failed',
      message: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
