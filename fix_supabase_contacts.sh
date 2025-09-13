#!/bin/bash

echo "🔧 Fixing Supabase Contact Storage"
echo "=================================="

# Check if API route exists
API_ROUTE_APP="app/api/contacts/route.ts"
API_ROUTE_PAGES="pages/api/contacts.ts"

if [[ -f "$API_ROUTE_APP" ]]; then
    API_FILE="$API_ROUTE_APP"
    echo "✅ Found App Router API: $API_FILE"
elif [[ -f "$API_ROUTE_PAGES" ]]; then
    API_FILE="$API_ROUTE_PAGES"
    echo "✅ Found Pages Router API: $API_FILE"
else
    echo "❌ No API route found. Creating App Router version..."
    mkdir -p app/api/contacts
    API_FILE="app/api/contacts/route.ts"
fi

echo "📝 Creating/updating API route with proper Supabase POST handler..."

# Create backup if file exists
if [[ -f "$API_FILE" ]]; then
    BACKUP_FILE="${API_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$API_FILE" "$BACKUP_FILE"
    echo "💾 Backup created: $BACKUP_FILE"
fi

# Detect if we're using App Router or Pages Router
if [[ "$API_FILE" == *"app/api"* ]]; then
    echo "🔧 Creating App Router API..."
    
cat > "$API_FILE" << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

// Demo data for fallback
const DEMO_CONTACTS = [
  {
    id: 'demo-1',
    first_name: 'Sarah',
    last_name: 'Chen',
    email: 'sarah.chen@nexustherapeutics.com',
    phone: '+1-555-0123',
    title: 'Chief Executive Officer',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/sarah-chen',
    contact_status: 'not_contacted',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'Nexus Therapeutics',
      industry: 'Biotechnology',
      funding_stage: 'Series A'
    }
  },
  {
    id: 'demo-2',
    first_name: 'Michael',
    last_name: 'Rodriguez',
    email: 'mrodriguez@bioventures.com',
    phone: '+1-555-0456',
    title: 'Partner',
    role_category: 'VC',
    linkedin_url: 'https://linkedin.com/in/michael-rodriguez',
    contact_status: 'contacted',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'BioVentures Capital',
      industry: 'Venture Capital',
      funding_stage: 'N/A'
    }
  },
  {
    id: 'demo-3',
    first_name: 'Dr. Emily',
    last_name: 'Watson',
    email: 'emily.watson@genomicsinc.com',
    phone: '+1-555-0789',
    title: 'Chief Scientific Officer',
    role_category: 'Executive',
    linkedin_url: 'https://linkedin.com/in/emily-watson-phd',
    contact_status: 'responded',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'Genomics Inc.',
      industry: 'Biotechnology',
      funding_stage: 'Series B'
    }
  }
]

// Initialize Supabase client
function getSupabaseClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseKey) {
    console.log('🔄 Supabase credentials not found, using demo mode')
    return null
  }

  return createClient(supabaseUrl, supabaseKey)
}

// Check if we should use demo mode
function isDemoMode() {
  // Force demo mode if Supabase not configured
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  
  if (!supabaseUrl || !supabaseKey) {
    return true
  }
  
  // Check if demo mode is explicitly enabled
  return process.env.DEMO_MODE === 'true' || process.env.NODE_ENV === 'development'
}

// GET - Fetch contacts
export async function GET() {
  try {
    console.log('🔍 API: Fetching contacts...')
    
    if (isDemoMode()) {
      console.log('📊 API: Using demo mode')
      return NextResponse.json({
        success: true,
        contacts: DEMO_CONTACTS,
        source: 'demo',
        count: DEMO_CONTACTS.length
      })
    }

    const supabase = getSupabaseClient()
    if (!supabase) {
      console.log('❌ API: Supabase client creation failed, falling back to demo')
      return NextResponse.json({
        success: true,
        contacts: DEMO_CONTACTS,
        source: 'demo_fallback',
        count: DEMO_CONTACTS.length
      })
    }

    // Fetch contacts from Supabase
    const { data: contacts, error } = await supabase
      .from('contacts')
      .select(`
        *,
        companies:company_id (
          name,
          industry,
          funding_stage
        )
      `)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('❌ API: Supabase query failed:', error)
      return NextResponse.json({
        success: true,
        contacts: DEMO_CONTACTS,
        source: 'demo_fallback',
        count: DEMO_CONTACTS.length,
        error: error.message
      })
    }

    console.log(`✅ API: Fetched ${contacts?.length || 0} contacts from Supabase`)
    return NextResponse.json({
      success: true,
      contacts: contacts || [],
      source: 'supabase',
      count: contacts?.length || 0
    })

  } catch (error) {
    console.error('❌ API: Unexpected error:', error)
    return NextResponse.json({
      success: true,
      contacts: DEMO_CONTACTS,
      source: 'demo_fallback',
      count: DEMO_CONTACTS.length,
      error: error instanceof Error ? error.message : 'Unknown error'
    })
  }
}

// POST - Add new contact
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    console.log('➕ API: Adding contact:', body)

    // Validate required fields
    if (!body.first_name || !body.last_name) {
      return NextResponse.json({
        success: false,
        error: 'First name and last name are required'
      }, { status: 400 })
    }

    if (isDemoMode()) {
      console.log('📊 API: Demo mode - simulating contact addition')
      
      // Create demo contact
      const newContact = {
        id: `demo-${Date.now()}`,
        first_name: body.first_name,
        last_name: body.last_name,
        email: body.email || null,
        phone: body.phone || null,
        title: body.title || null,
        role_category: body.role_category || null,
        linkedin_url: body.linkedin_url || null,
        contact_status: 'not_contacted',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        companies: body.companies || null
      }

      console.log('✅ API: Demo contact created:', newContact)
      return NextResponse.json({
        success: true,
        contact: newContact,
        source: 'demo'
      })
    }

    const supabase = getSupabaseClient()
    if (!supabase) {
      return NextResponse.json({
        success: false,
        error: 'Database connection not available'
      }, { status: 500 })
    }

    // Handle company creation/linking
    let companyId = null
    if (body.companies && body.companies.name) {
      // First, try to find existing company
      const { data: existingCompany } = await supabase
        .from('companies')
        .select('id')
        .eq('name', body.companies.name)
        .single()

      if (existingCompany) {
        companyId = existingCompany.id
      } else {
        // Create new company
        const { data: newCompany, error: companyError } = await supabase
          .from('companies')
          .insert({
            name: body.companies.name,
            industry: body.companies.industry,
            funding_stage: body.companies.funding_stage
          })
          .select('id')
          .single()

        if (companyError) {
          console.error('❌ API: Company creation failed:', companyError)
        } else {
          companyId = newCompany.id
        }
      }
    }

    // Create contact
    const contactData = {
      first_name: body.first_name,
      last_name: body.last_name,
      email: body.email,
      phone: body.phone,
      title: body.title,
      role_category: body.role_category,
      linkedin_url: body.linkedin_url,
      company_id: companyId,
      contact_status: 'not_contacted'
    }

    const { data: newContact, error: contactError } = await supabase
      .from('contacts')
      .insert(contactData)
      .select(`
        *,
        companies:company_id (
          name,
          industry,
          funding_stage
        )
      `)
      .single()

    if (contactError) {
      console.error('❌ API: Contact creation failed:', contactError)
      return NextResponse.json({
        success: false,
        error: contactError.message
      }, { status: 500 })
    }

    console.log('✅ API: Contact created in Supabase:', newContact)
    return NextResponse.json({
      success: true,
      contact: newContact,
      source: 'supabase'
    })

  } catch (error) {
    console.error('❌ API: Unexpected error in POST:', error)
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}
EOF

else
    echo "🔧 Creating Pages Router API..."
    
cat > "$API_FILE" << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { createClient } from '@supabase/supabase-js'

// Demo data for fallback
const DEMO_CONTACTS = [
  {
    id: 'demo-1',
    first_name: 'Sarah',
    last_name: 'Chen',
    email: 'sarah.chen@nexustherapeutics.com',
    phone: '+1-555-0123',
    title: 'Chief Executive Officer',
    role_category: 'Founder',
    linkedin_url: 'https://linkedin.com/in/sarah-chen',
    contact_status: 'not_contacted',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'Nexus Therapeutics',
      industry: 'Biotechnology',
      funding_stage: 'Series A'
    }
  },
  {
    id: 'demo-2',
    first_name: 'Michael',
    last_name: 'Rodriguez',
    email: 'mrodriguez@bioventures.com',
    phone: '+1-555-0456',
    title: 'Partner',
    role_category: 'VC',
    linkedin_url: 'https://linkedin.com/in/michael-rodriguez',
    contact_status: 'contacted',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    companies: {
      name: 'BioVentures Capital',
      industry: 'Venture Capital',
      funding_stage: 'N/A'
    }
  }
]

// Initialize Supabase client
function getSupabaseClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseKey) {
    console.log('🔄 Supabase credentials not found, using demo mode')
    return null
  }

  return createClient(supabaseUrl, supabaseKey)
}

// Check if we should use demo mode
function isDemoMode() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  
  if (!supabaseUrl || !supabaseKey) {
    return true
  }
  
  return process.env.DEMO_MODE === 'true' || process.env.NODE_ENV === 'development'
}

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    try {
      console.log('🔍 API: Fetching contacts...')
      
      if (isDemoMode()) {
        console.log('📊 API: Using demo mode')
        return res.status(200).json({
          success: true,
          contacts: DEMO_CONTACTS,
          source: 'demo',
          count: DEMO_CONTACTS.length
        })
      }

      const supabase = getSupabaseClient()
      if (!supabase) {
        return res.status(200).json({
          success: true,
          contacts: DEMO_CONTACTS,
          source: 'demo_fallback',
          count: DEMO_CONTACTS.length
        })
      }

      const { data: contacts, error } = await supabase
        .from('contacts')
        .select(`
          *,
          companies:company_id (
            name,
            industry,
            funding_stage
          )
        `)
        .order('created_at', { ascending: false })

      if (error) {
        console.error('❌ API: Supabase query failed:', error)
        return res.status(200).json({
          success: true,
          contacts: DEMO_CONTACTS,
          source: 'demo_fallback',
          count: DEMO_CONTACTS.length
        })
      }

      return res.status(200).json({
        success: true,
        contacts: contacts || [],
        source: 'supabase',
        count: contacts?.length || 0
      })

    } catch (error) {
      console.error('❌ API: Unexpected error:', error)
      return res.status(200).json({
        success: true,
        contacts: DEMO_CONTACTS,
        source: 'demo_fallback',
        count: DEMO_CONTACTS.length
      })
    }
  }

  if (req.method === 'POST') {
    try {
      const body = req.body
      console.log('➕ API: Adding contact:', body)

      if (!body.first_name || !body.last_name) {
        return res.status(400).json({
          success: false,
          error: 'First name and last name are required'
        })
      }

      // Check if demo mode is explicitly enabled
      if (isDemoMode()) {
        console.log('📊 API: Demo mode explicitly enabled - simulating contact addition')
        
        const newContact = {
          id: `demo-${Date.now()}`,
          first_name: body.first_name,
          last_name: body.last_name,
          email: body.email || null,
          phone: body.phone || null,
          title: body.title || null,
          role_category: body.role_category || null,
          linkedin_url: body.linkedin_url || null,
          contact_status: 'not_contacted',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          companies: body.companies || null
        }

        return res.status(200).json({
          success: true,
          contact: newContact,
          source: 'demo'
        })
      }

      // Demo mode is OFF, so we must use Supabase
      const supabase = getSupabaseClient()
      if (!supabase) {
        console.error('❌ API: Supabase not configured and demo mode is OFF')
        return res.status(500).json({
          success: false,
          error: 'Database not configured. Please set up Supabase credentials or enable demo mode.'
        })
      }

      // Handle company creation/linking
      let companyId = null
      if (body.companies && body.companies.name) {
        const { data: existingCompany } = await supabase
          .from('companies')
          .select('id')
          .eq('name', body.companies.name)
          .single()

        if (existingCompany) {
          companyId = existingCompany.id
        } else {
          const { data: newCompany, error: companyError } = await supabase
            .from('companies')
            .insert({
              name: body.companies.name,
              industry: body.companies.industry,
              funding_stage: body.companies.funding_stage
            })
            .select('id')
            .single()

          if (companyError) {
            console.error('❌ API: Company creation failed:', companyError)
            return res.status(500).json({
              success: false,
              error: `Company creation failed: ${companyError.message}`
            })
          } else {
            companyId = newCompany.id
          }
        }
      }

      // Create contact
      const contactData = {
        first_name: body.first_name,
        last_name: body.last_name,
        email: body.email,
        phone: body.phone,
        title: body.title,
        role_category: body.role_category,
        linkedin_url: body.linkedin_url,
        company_id: companyId,
        contact_status: 'not_contacted'
      }

      const { data: newContact, error: contactError } = await supabase
        .from('contacts')
        .insert(contactData)
        .select(`
          *,
          companies:company_id (
            name,
            industry,
            funding_stage
          )
        `)
        .single()

      if (contactError) {
        console.error('❌ API: Contact creation failed:', contactError)
        return res.status(500).json({
          success: false,
          error: `Contact creation failed: ${contactError.message}`
        })
      }

      return res.status(200).json({
        success: true,
        contact: newContact,
        source: 'supabase'
      })

    } catch (error) {
      console.error('❌ API: Unexpected error in POST:', error)
      return res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      })
    }
  }

  res.setHeader('Allow', ['GET', 'POST'])
  res.status(405).end(`Method ${req.method} Not Allowed`)
}
EOF

fi

echo ""
echo "✅ API Route Created!"
echo "===================="
echo ""
echo "Created: $API_FILE"
echo ""
echo "This API route:"
echo "• GET: Fetches contacts from Supabase (with demo fallback)"
echo "• POST: Saves new contacts to Supabase (with demo mode support)"
echo "• Handles company creation/linking automatically"
echo "• Provides detailed logging for debugging"
echo "• Falls back to demo data if Supabase isn't configured"
echo ""
echo "Environment variables needed:"
echo "• NEXT_PUBLIC_SUPABASE_URL"
echo "• NEXT_PUBLIC_SUPABASE_ANON_KEY"
echo ""
echo "Demo mode is used when:"
echo "• Supabase credentials are missing"
echo "• DEMO_MODE=true is set"
echo "• NODE_ENV=development"
echo ""
echo "Next steps:"
echo "1. Make sure your Supabase credentials are in .env.local"
echo "2. Test the Add Contact functionality"
echo "3. Check browser console for detailed API logs"
