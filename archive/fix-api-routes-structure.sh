#!/bin/bash

echo "🔧 Fixing App Router API Route Structure"
echo "========================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create backup
backup_dir="api-structure-fix-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

if [ -d "app/api" ]; then
    cp -r "app/api" "$backup_dir/"
    echo "📦 Backed up app/api to $backup_dir"
fi

echo ""
echo "🔧 Restructuring API routes for App Router..."

# Remove existing app/api and recreate with proper structure
rm -rf app/api
mkdir -p app/api

# Create each API endpoint with proper App Router structure
# Each endpoint needs to be in its own directory with route.ts

echo "📁 Creating /api/analytics/dashboard/route.ts..."
mkdir -p app/api/analytics/dashboard
cat > app/api/analytics/dashboard/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    // Mock dashboard data - replace with real database queries when available
    const stats = {
      totalContacts: 1247,
      totalCompanies: 186,
      emailsSent: 892,
      responseRate: 23.5,
      contactedThisWeek: 47,
      notContactedCount: 723,
      pipeline_value: 2400000,
      active_campaigns: 5
    }

    const charts = {
      emailActivity: [
        { date: 'Sep 1', sent: 45, opened: 25, replied: 6 },
        { date: 'Sep 2', sent: 52, opened: 30, replied: 8 },
        { date: 'Sep 3', sent: 48, opened: 22, replied: 5 },
        { date: 'Sep 4', sent: 61, opened: 35, replied: 12 },
        { date: 'Sep 5', sent: 55, opened: 28, replied: 9 },
        { date: 'Sep 6', sent: 47, opened: 20, replied: 4 },
        { date: 'Sep 7', sent: 38, opened: 15, replied: 3 },
      ],
      contactsByRole: [
        { role: 'Founder', count: 45, color: '#3B82F6' },
        { role: 'Executive', count: 67, color: '#8B5CF6' },
        { role: 'VC', count: 23, color: '#10B981' },
        { role: 'Board Member', count: 18, color: '#F59E0B' },
      ],
      companiesByStage: [
        { stage: 'Series A', count: 75 },
        { stage: 'Series B', count: 64 },
        { stage: 'Series C', count: 47 },
      ]
    }

    return NextResponse.json({ 
      success: true,
      stats, 
      charts,
      source: 'demo'
    })
  } catch (error) {
    console.error('Dashboard API Error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch dashboard data' },
      { status: 500 }
    )
  }
}
EOF

echo "📁 Creating /api/settings/email/route.ts..."
mkdir -p app/api/settings/email
cat > app/api/settings/email/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    // Return default email settings
    const settings = {
      sendgrid_api_key: '',
      from_name: 'Peter Ferreira',
      from_email: 'peter@ferreiracto.com',
      reply_to_email: 'peter@ferreiracto.com',
      company_name: 'Ferreira CTO',
      company_website: 'https://ferreiracto.com',
      signature: 'Best regards,\nPeter Ferreira\nCTO Consultant\nFerreira CTO',
      bounce_handling: true,
      click_tracking: true,
      open_tracking: true
    }

    return NextResponse.json({
      success: true,
      settings
    })
  } catch (error) {
    console.error('Email Settings API Error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch email settings' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    console.log('📝 Email settings saved:', body)
    
    return NextResponse.json({
      success: true,
      message: 'Email settings saved successfully',
      settings: body
    })
  } catch (error) {
    console.error('Save Email Settings Error:', error)
    return NextResponse.json(
      { error: 'Failed to save email settings' },
      { status: 500 }
    )
  }
}
EOF

echo "📁 Creating /api/campaigns/route.ts..."
mkdir -p app/api/campaigns
cat > app/api/campaigns/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

const DEMO_CAMPAIGNS = [
  {
    id: 'demo-campaign-1',
    name: 'Q4 Biotech CTO Outreach',
    subject: 'Technology Due Diligence for {{company_name}}',
    template_id: 'biotech-intro-1',
    status: 'sent',
    recipients_count: 45,
    sent_count: 45,
    delivered_count: 43,
    opened_count: 18,
    clicked_count: 7,
    replied_count: 3,
    bounced_count: 2,
    created_at: '2024-12-01T10:00:00Z',
    updated_at: '2024-12-15T14:30:00Z',
    sent_at: '2024-12-01T10:30:00Z'
  },
  {
    id: 'demo-campaign-2',
    name: 'VC Partnership Series B Focus',
    subject: 'Strategic Partnership - {{vc_firm_name}}',
    template_id: 'vc-partnership-1',
    status: 'sending',
    recipients_count: 25,
    sent_count: 12,
    delivered_count: 11,
    opened_count: 4,
    clicked_count: 2,
    replied_count: 1,
    bounced_count: 1,
    created_at: '2024-12-10T15:00:00Z',
    updated_at: '2024-12-15T16:00:00Z',
    sent_at: '2024-12-10T15:30:00Z'
  }
]

export async function GET(request: NextRequest) {
  try {
    const campaigns = DEMO_CAMPAIGNS.map(campaign => ({
      ...campaign,
      open_rate: campaign.sent_count > 0 ? ((campaign.opened_count / campaign.sent_count) * 100).toFixed(1) : '0.0',
      click_rate: campaign.sent_count > 0 ? ((campaign.clicked_count / campaign.sent_count) * 100).toFixed(1) : '0.0',
      reply_rate: campaign.sent_count > 0 ? ((campaign.replied_count / campaign.sent_count) * 100).toFixed(1) : '0.0'
    }))

    return NextResponse.json({ 
      success: true,
      campaigns,
      count: campaigns.length 
    })
  } catch (error) {
    console.error('Get Campaigns Error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch campaigns' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const campaignData = await request.json()
    console.log('📤 Creating campaign:', campaignData)

    if (!campaignData.name) {
      return NextResponse.json(
        { error: 'Campaign name is required' },
        { status: 400 }
      )
    }

    const newCampaign = {
      id: `demo-campaign-${Date.now()}`,
      ...campaignData,
      recipients_count: 0,
      sent_count: 0,
      delivered_count: 0,
      opened_count: 0,
      clicked_count: 0,
      replied_count: 0,
      bounced_count: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      sent_at: campaignData.status === 'sending' ? new Date().toISOString() : null
    }

    return NextResponse.json({ 
      success: true,
      campaign: newCampaign,
      message: `Demo: Created "${campaignData.name}" campaign successfully`
    })
  } catch (error) {
    console.error('Create Campaign Error:', error)
    return NextResponse.json(
      { error: 'Failed to create campaign' },
      { status: 500 }
    )
  }
}
EOF

echo "📁 Creating /api/campaigns/estimate-recipients/route.ts..."
mkdir -p app/api/campaigns/estimate-recipients
cat > app/api/campaigns/estimate-recipients/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const searchParams = await request.json()
    console.log('🔢 Estimating recipients for params:', searchParams)

    let estimate = 50 // Base estimate

    if (searchParams.target_types) {
      if (searchParams.target_types.includes('companies')) {
        estimate += 40
      }
      if (searchParams.target_types.includes('vc_firms')) {
        estimate += 15
      }
    }

    if (searchParams.industries && searchParams.industries.length > 3) {
      estimate += 25
    }

    if (searchParams.locations && searchParams.locations.length > 2) {
      estimate += 30
    }

    if (searchParams.funding_stages && searchParams.funding_stages.length > 4) {
      estimate += 20
    }

    const variation = Math.floor(Math.random() * 20) - 10
    estimate += variation
    estimate = Math.max(10, Math.min(estimate, 150))

    console.log('📊 Estimated recipients:', estimate)

    return NextResponse.json({
      success: true,
      count: estimate,
      breakdown: {
        companies: Math.floor(estimate * 0.7),
        vc_firms: Math.floor(estimate * 0.3)
      },
      message: `Estimated ${estimate} recipients based on your criteria`
    })
  } catch (error) {
    console.error('Estimate Recipients Error:', error)
    return NextResponse.json(
      { error: 'Failed to estimate recipients' },
      { status: 500 }
    )
  }
}
EOF

echo "📁 Creating /api/templates/route.ts..."
mkdir -p app/api/templates
cat > app/api/templates/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    const templates = [
      {
        id: 'biotech-intro-1',
        name: 'Biotech CTO Introduction',
        category: 'outreach',
        subject_template: 'Technology Due Diligence for {{company_name}}',
        html_content: `
          <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #ffffff;">
            <div style="text-align: center; margin-bottom: 30px;">
              <h2 style="color: #2563eb; margin: 0; font-size: 24px;">Technology Due Diligence</h2>
              <p style="color: #6b7280; margin: 5px 0 0 0;">Ferreira CTO Consulting</p>
            </div>
            
            <p style="color: #374151; line-height: 1.6;">Hi {{first_name}},</p>
            
            <p style="color: #374151; line-height: 1.6;">I hope this email finds you well. I'm Peter Ferreira, CTO at Ferreira CTO, and I specialize in technology due diligence for biotech companies like {{company_name}}.</p>
            
            <div style="background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3 style="color: #1f2937; margin-top: 0;">How I Can Help {{company_name}}</h3>
              <ul style="color: #374151; margin: 0; padding-left: 20px;">
                <li>Technology stack evaluation and optimization</li>
                <li>Technical team assessment and scaling strategies</li>
                <li>Infrastructure review for regulatory compliance</li>
                <li>Data security and privacy implementation</li>
              </ul>
            </div>
            
            <p style="color: #374151; line-height: 1.6;">Given {{company_name}}'s focus on {{industry}}, I'd love to discuss how we can ensure your technology foundation supports your growth objectives.</p>
            
            <p style="color: #374151; line-height: 1.6;">Would you be available for a brief 15-minute call next week?</p>
            
            <div style="margin: 30px 0; text-align: center;">
              <a href="https://calendly.com/peter-ferreira" style="background-color: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">Schedule a Call</a>
            </div>
            
            <p style="color: #374151; line-height: 1.6;">Best regards,<br>
            Peter Ferreira<br>
            CTO, Ferreira CTO<br>
            <a href="mailto:peter@ferreiracto.com" style="color: #2563eb;">peter@ferreiracto.com</a></p>
          </div>
        `,
        text_content: `Hi {{first_name}},

I hope this email finds you well. I'm Peter Ferreira, CTO at Ferreira CTO, and I specialize in technology due diligence for biotech companies like {{company_name}}.

How I Can Help {{company_name}}:
• Technology stack evaluation and optimization
• Technical team assessment and scaling strategies
• Infrastructure review for regulatory compliance
• Data security and privacy implementation

Given {{company_name}}'s focus on {{industry}}, I'd love to discuss how we can ensure your technology foundation supports your growth objectives.

Would you be available for a brief 15-minute call next week?

Schedule a call: https://calendly.com/peter-ferreira

Best regards,
Peter Ferreira
CTO, Ferreira CTO
peter@ferreiracto.com`,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-09-08T15:30:00Z'
      }
    ]

    return NextResponse.json({
      success: true,
      templates,
      count: templates.length
    })
  } catch (error) {
    console.error('Templates API Error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch templates' },
      { status: 500 }
    )
  }
}
EOF

echo "📁 Creating /api/contacts/route.ts..."
mkdir -p app/api/contacts
cat > app/api/contacts/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

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
  }
]

export async function GET(request: NextRequest) {
  try {
    return NextResponse.json({
      success: true,
      contacts: DEMO_CONTACTS,
      count: DEMO_CONTACTS.length,
      source: 'demo'
    })
  } catch (error) {
    console.error('Contacts API Error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch contacts' },
      { status: 500 }
    )
  }
}
EOF

echo "📁 Creating /api/test/route.ts..."
mkdir -p app/api/test
cat > app/api/test/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  return NextResponse.json({ 
    success: true, 
    message: 'API is working!',
    timestamp: new Date().toISOString(),
    structure: 'App Router'
  })
}
EOF

echo ""
echo -e "${GREEN}✅ API Routes Structure Fixed!${NC}"
echo "=================================="
echo ""
echo "Created App Router API endpoints:"
echo "• /api/analytics/dashboard (GET)"
echo "• /api/settings/email (GET, POST)"
echo "• /api/campaigns (GET, POST)"
echo "• /api/campaigns/estimate-recipients (POST)"
echo "• /api/templates (GET)"
echo "• /api/contacts (GET)"
echo "• /api/test (GET)"
echo ""
echo -e "${YELLOW}📦 Backup saved to: $backup_dir${NC}"
echo ""
echo "🚀 Restart your dev server:"
echo "   npm run dev"
echo ""
echo "🧪 Test an API endpoint:"
echo "   curl http://localhost:3000/api/test"
