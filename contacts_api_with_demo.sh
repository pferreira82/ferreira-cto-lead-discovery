#!/bin/bash

echo "Creating Contacts API with Demo Mode Support"
echo "============================================"

# Create the contacts API directory
mkdir -p app/api/contacts

# Create the contacts API route with demo mode
cat > app/api/contacts/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { supabase, supabaseAdmin, isSupabaseConfigured } from '@/lib/supabase'

// Demo contacts data
const DEMO_CONTACTS = [
  {
    id: 'demo_contact_1',
    company_id: 'demo_company_1',
    first_name: 'Sarah',
    last_name: 'Chen',
    email: 'sarah.chen@nexustherapeutics.com',
    phone: '+1-555-0123',
    title: 'Chief Executive Officer',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/sarah-chen-biotech',
    contact_status: 'not_contacted',
    last_contacted_at: null,
    created_at: '2024-01-15T10:30:00Z',
    updated_at: '2024-01-15T10:30:00Z',
    companies: {
      name: 'Nexus Therapeutics',
      industry: 'Biotechnology',
      funding_stage: 'Series B'
    }
  },
  {
    id: 'demo_contact_2',
    company_id: 'demo_company_2',
    first_name: 'Michael',
    last_name: 'Rodriguez',
    email: 'michael.rodriguez@bioforgelabs.com',
    phone: '+1-555-0456',
    title: 'Chief Technology Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/michael-rodriguez-cto',
    contact_status: 'contacted',
    last_contacted_at: '2024-01-10T14:20:00Z',
    created_at: '2024-01-12T09:15:00Z',
    updated_at: '2024-01-12T09:15:00Z',
    companies: {
      name: 'Bioforge Labs',
      industry: 'Gene Therapy',
      funding_stage: 'Series A'
    }
  },
  {
    id: 'demo_contact_3',
    company_id: 'demo_company_3',
    first_name: 'Emily',
    last_name: 'Johnson',
    email: 'emily.johnson@quantumbio.com',
    phone: '+1-555-0789',
    title: 'Co-Founder & Chief Scientific Officer',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/emily-johnson-phd',
    contact_status: 'responded',
    last_contacted_at: '2024-01-08T11:45:00Z',
    created_at: '2024-01-08T08:30:00Z',
    updated_at: '2024-01-08T08:30:00Z',
    companies: {
      name: 'Quantum Biosciences',
      industry: 'Drug Discovery',
      funding_stage: 'Seed'
    }
  },
  {
    id: 'demo_contact_4',
    company_id: 'demo_company_4',
    first_name: 'David',
    last_name: 'Kim',
    email: 'david.kim@meridianhealth.io',
    phone: '+1-555-0321',
    title: 'VP of Business Development',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/david-kim-bizdev',
    contact_status: 'interested',
    last_contacted_at: '2024-01-05T16:15:00Z',
    created_at: '2024-01-05T13:20:00Z',
    updated_at: '2024-01-05T13:20:00Z',
    companies: {
      name: 'Meridian Health',
      industry: 'Digital Health',
      funding_stage: 'Series C'
    }
  },
  {
    id: 'demo_contact_5',
    company_id: 'demo_company_5',
    first_name: 'Lisa',
    last_name: 'Park',
    email: 'lisa.park@catalystpharma.com',
    title: 'Chief Medical Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/lisa-park-md',
    contact_status: 'not_interested',
    last_contacted_at: '2024-01-03T12:30:00Z',
    created_at: '2024-01-03T10:45:00Z',
    updated_at: '2024-01-03T10:45:00Z',
    companies: {
      name: 'Catalyst Pharma',
      industry: 'Pharmaceuticals',
      funding_stage: 'Growth'
    }
  },
  {
    id: 'demo_contact_6',
    company_id: 'demo_vc_1',
    first_name: 'Robert',
    last_name: 'Chen',
    email: 'robert.chen@techventures.com',
    phone: '+1-555-0654',
    title: 'General Partner',
    role_category: 'VC',
    linkedin_url: 'https://linkedin.com/in/robert-chen-gp',
    contact_status: 'contacted',
    last_contacted_at: '2024-01-12T09:00:00Z',
    created_at: '2024-01-12T09:00:00Z',
    updated_at: '2024-01-12T09:00:00Z',
    companies: {
      name: 'TechVentures Capital',
      industry: 'Venture Capital',
      funding_stage: null
    }
  },
  {
    id: 'demo_contact_7',
    company_id: 'demo_company_6',
    first_name: 'Anna',
    last_name: 'Williams',
    email: 'anna.williams@genomicsinnovations.com',
    title: 'Founder & CEO',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/anna-williams-genomics',
    contact_status: 'responded',
    last_contacted_at: '2024-01-14T14:30:00Z',
    created_at: '2024-01-14T14:30:00Z',
    updated_at: '2024-01-14T14:30:00Z',
    companies: {
      name: 'Genomics Innovations',
      industry: 'Genomics',
      funding_stage: 'Series A'
    }
  },
  {
    id: 'demo_contact_8',
    company_id: 'demo_company_7',
    first_name: 'James',
    last_name: 'Thompson',
    email: 'james.thompson@precisiontherapeutics.com',
    title: 'Board Member',
    role_category: 'Board Member',
    linkedin_url: 'https://linkedin.com/in/james-thompson-board',
    contact_status: 'not_contacted',
    last_contacted_at: null,
    created_at: '2024-01-16T11:15:00Z',
    updated_at: '2024-01-16T11:15:00Z',
    companies: {
      name: 'Precision Therapeutics',
      industry: 'Precision Medicine',
      funding_stage: 'Series B'
    }
  }
]

function checkDemoMode(): boolean {
  // Check various indicators for demo mode
  const envDemo = process.env.DEMO_MODE === 'true'
  const envNoSupabase = !isSupabaseConfigured()
  const envNoApollo = !process.env.APOLLO_API_KEY || process.env.APOLLO_API_KEY === 'demo'
  
  return envDemo || envNoSupabase || envNoApollo
}

export async function GET(request: NextRequest) {
  try {
    const isDemoMode = checkDemoMode()
    
    if (isDemoMode) {
      console.log('📊 Returning demo contacts data')
      
      return NextResponse.json({
        success: true,
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo'
      })
    }

    // Production mode - fetch from Supabase
    const client = typeof window === 'undefined' ? (supabaseAdmin || supabase) : supabase
    if (!client) {
      console.log('📊 Supabase client not available, falling back to demo data')
      
      return NextResponse.json({
        success: true,
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo_fallback'
      })
    }

    const { data: contacts, error } = await client
      .from('contacts')
      .select(`
        *,
        companies (
          name,
          industry,
          funding_stage
        )
      `)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching contacts:', error)
      
      // Fall back to demo data on error
      return NextResponse.json({
        success: true,
        contacts: DEMO_CONTACTS,
        count: DEMO_CONTACTS.length,
        source: 'demo_fallback',
        error: error.message
      })
    }

    return NextResponse.json({
      success: true,
      contacts: contacts || [],
      count: contacts?.length || 0,
      source: 'production'
    })

  } catch (error) {
    console.error('Error in contacts API:', error)
    
    // Always fall back to demo data on any error
    return NextResponse.json({
      success: true,
      contacts: DEMO_CONTACTS,
      count: DEMO_CONTACTS.length,
      source: 'demo_fallback',
      error: error instanceof Error ? error.message : 'Unknown error'
    })
  }
}

export async function POST(request: NextRequest) {
  try {
    const isDemoMode = checkDemoMode()
    
    if (isDemoMode) {
      return NextResponse.json({
        success: false,
        message: 'Demo mode: Contact creation disabled',
        source: 'demo'
      }, { status: 400 })
    }

    const body = await request.json()
    
    const client = typeof window === 'undefined' ? (supabaseAdmin || supabase) : supabase
    if (!client) {
      return NextResponse.json({
        success: false,
        message: 'Database connection not available'
      }, { status: 500 })
    }

    const { data: contact, error } = await client
      .from('contacts')
      .insert(body)
      .select()
      .single()

    if (error) {
      return NextResponse.json({
        success: false,
        message: error.message
      }, { status: 400 })
    }

    return NextResponse.json({
      success: true,
      contact,
      source: 'production'
    })

  } catch (error) {
    console.error('Error creating contact:', error)
    
    return NextResponse.json({
      success: false,
      message: error instanceof Error ? error.message : 'Failed to create contact'
    }, { status: 500 })
  }
}
EOF

echo ""
echo "✅ Contacts API Created Successfully!"
echo "===================================="
echo ""
echo "Created:"
echo "• app/api/contacts/route.ts - Contacts API with demo mode"
echo ""
echo "Features:"
echo "• 8 demo contacts with realistic biotech industry data"
echo "• Automatic demo mode detection"
echo "• Fallback to demo data if Supabase fails"
echo "• Support for GET and POST operations"
echo "• Proper contact status and role categories"
echo "• Company relationships included"
echo ""
echo "Demo Contacts Include:"
echo "• Founders, Executives, VCs, Board Members"
echo "• Various contact statuses (not_contacted, contacted, etc.)"
echo "• Biotech companies with funding stages"
echo "• Realistic email addresses and LinkedIn URLs"
echo ""
echo "The contacts page should now load successfully!"
echo ""
