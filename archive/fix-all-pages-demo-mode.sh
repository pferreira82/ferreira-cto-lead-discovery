#!/bin/bash

echo "Fixing All Pages to Respect Demo Mode"
echo "====================================="

# Create backup
backup_dir="pages-demo-fix-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Update campaigns API to properly respect demo mode
echo "Updating campaigns API..."
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
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('Returning demo campaigns data')
      const campaigns = DEMO_CAMPAIGNS.map(campaign => ({
        ...campaign,
        open_rate: campaign.sent_count > 0 ? ((campaign.opened_count / campaign.sent_count) * 100).toFixed(1) : '0.0',
        click_rate: campaign.sent_count > 0 ? ((campaign.clicked_count / campaign.sent_count) * 100).toFixed(1) : '0.0',
        reply_rate: campaign.sent_count > 0 ? ((campaign.replied_count / campaign.sent_count) * 100).toFixed(1) : '0.0'
      }))

      return NextResponse.json({ 
        success: true,
        campaigns,
        count: campaigns.length,
        source: 'demo'
      })
    }

    // Production mode - return empty campaigns
    console.log('Production mode: No real database configured for campaigns')
    
    return NextResponse.json({ 
      success: true,
      campaigns: [],
      count: 0,
      source: 'production',
      message: 'No campaigns found. Configure your database connection to see real campaigns.'
    })

  } catch (error) {
    console.error('Get Campaigns Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch campaigns',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    const campaignData = await request.json()
    console.log('Creating campaign:', campaignData)

    if (!campaignData.name) {
      return NextResponse.json(
        { error: 'Campaign name is required' },
        { status: 400 }
      )
    }

    if (demoMode) {
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
        message: `Demo: Created "${campaignData.name}" campaign successfully`,
        source: 'demo'
      })
    }

    // Production mode
    return NextResponse.json({ 
      success: false,
      error: 'Campaign creation not available in production mode without database configuration',
      source: 'production'
    })

  } catch (error) {
    console.error('Create Campaign Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to create campaign',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
EOF

# Update templates API to respect demo mode
echo "Updating templates API..."
cat > app/api/templates/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('Returning demo templates data')
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
          text_content: 'Hi {{first_name}},\\n\\nI hope this email finds you well...',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-09-08T15:30:00Z'
        }
      ]

      return NextResponse.json({
        success: true,
        templates,
        count: templates.length,
        source: 'demo'
      })
    }

    // Production mode - return empty templates
    console.log('Production mode: No real database configured for templates')
    
    return NextResponse.json({
      success: true,
      templates: [],
      count: 0,
      source: 'production',
      message: 'No templates found. Configure your database connection to see real templates.'
    })

  } catch (error) {
    console.error('Templates API Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch templates',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
EOF

# Find and update all pages that might be using API calls
echo "Searching for pages that need demo mode fixes..."

# Check if emails page exists and update it
if [ -f "app/emails/page.tsx" ]; then
    echo "Updating emails page..."
    cp "app/emails/page.tsx" "$backup_dir/emails-page.tsx.backup"
    
    # Check if it imports useDemoMode but not useDemoAPI
    if grep -q "useDemoMode" "app/emails/page.tsx" && ! grep -q "useDemoAPI" "app/emails/page.tsx"; then
        # Add the import
        sed -i.tmp "s/import { useDemoMode } from '@\/lib\/demo-context'/import { useDemoMode } from '@\/lib\/demo-context'\nimport { useDemoAPI } from '@\/lib\/hooks\/use-demo-api'/" "app/emails/page.tsx"
        
        # Replace fetch calls with fetchWithDemo
        sed -i.tmp "s/const { isDemoMode }/const { isDemoMode } = useDemoMode()\n  const { fetchWithDemo }/" "app/emails/page.tsx"
        sed -i.tmp "s/fetch('/fetchWithDemo('/g" "app/emails/page.tsx"
        
        rm -f "app/emails/page.tsx.tmp"
        echo "Updated emails page to use demo-aware API calls"
    fi
fi

# Check if contacts page exists and update it
if [ -f "app/contacts/page.tsx" ]; then
    echo "Updating contacts page..."
    cp "app/contacts/page.tsx" "$backup_dir/contacts-page.tsx.backup"
    
    if grep -q "useDemoMode" "app/contacts/page.tsx" && ! grep -q "useDemoAPI" "app/contacts/page.tsx"; then
        sed -i.tmp "s/import { useDemoMode } from '@\/lib\/demo-context'/import { useDemoMode } from '@\/lib\/demo-context'\nimport { useDemoAPI } from '@\/lib\/hooks\/use-demo-api'/" "app/contacts/page.tsx"
        sed -i.tmp "s/const { isDemoMode }/const { isDemoMode } = useDemoMode()\n  const { fetchWithDemo }/" "app/contacts/page.tsx"
        sed -i.tmp "s/fetch('/fetchWithDemo('/g" "app/contacts/page.tsx"
        
        rm -f "app/contacts/page.tsx.tmp"
        echo "Updated contacts page to use demo-aware API calls"
    fi
fi

# Check if email-settings page exists and update it
if [ -f "app/email-settings/page.tsx" ]; then
    echo "Updating email-settings page..."
    cp "app/email-settings/page.tsx" "$backup_dir/email-settings-page.tsx.backup"
    
    if grep -q "useDemoMode" "app/email-settings/page.tsx" && ! grep -q "useDemoAPI" "app/email-settings/page.tsx"; then
        sed -i.tmp "s/import { useDemoMode } from '@\/lib\/demo-context'/import { useDemoMode } from '@\/lib\/demo-context'\nimport { useDemoAPI } from '@\/lib\/hooks\/use-demo-api'/" "app/email-settings/page.tsx"
        sed -i.tmp "s/const { isDemoMode }/const { isDemoMode } = useDemoMode()\n  const { fetchWithDemo }/" "app/email-settings/page.tsx"
        sed -i.tmp "s/fetch('/fetchWithDemo('/g" "app/email-settings/page.tsx"
        
        rm -f "app/email-settings/page.tsx.tmp"
        echo "Updated email-settings page to use demo-aware API calls"
    fi
fi

# Check if discovery page exists and update it
if [ -f "app/discovery/page.tsx" ]; then
    echo "Updating discovery page..."
    cp "app/discovery/page.tsx" "$backup_dir/discovery-page.tsx.backup"
    
    if grep -q "useDemoMode" "app/discovery/page.tsx" && ! grep -q "useDemoAPI" "app/discovery/page.tsx"; then
        sed -i.tmp "s/import { useDemoMode } from '@\/lib\/demo-context'/import { useDemoMode } from '@\/lib\/demo-context'\nimport { useDemoAPI } from '@\/lib\/hooks\/use-demo-api'/" "app/discovery/page.tsx"
        sed -i.tmp "s/const { isDemoMode }/const { isDemoMode } = useDemoMode()\n  const { fetchWithDemo }/" "app/discovery/page.tsx"
        sed -i.tmp "s/fetch('/fetchWithDemo('/g" "app/discovery/page.tsx"
        
        rm -f "app/discovery/page.tsx.tmp"
        echo "Updated discovery page to use demo-aware API calls"
    fi
fi

# Create a comprehensive component to show production mode warnings
echo "Creating production mode warning component..."
mkdir -p components/ui

cat > components/ui/production-mode-warning.tsx << 'EOF'
'use client'

import { AlertCircle } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { useDemoMode } from '@/lib/demo-context'

interface ProductionModeWarningProps {
  feature: string
  hasData: boolean
  className?: string
}

export function ProductionModeWarning({ feature, hasData, className }: ProductionModeWarningProps) {
  const { isDemoMode } = useDemoMode()

  if (isDemoMode || hasData) return null

  return (
    <Card className={`border-orange-200 bg-orange-50 dark:border-orange-800 dark:bg-orange-900/20 ${className}`}>
      <CardContent className="p-4">
        <div className="flex items-start space-x-3">
          <AlertCircle className="h-5 w-5 text-orange-600 dark:text-orange-400 mt-0.5 flex-shrink-0" />
          <div className="flex-1">
            <div className="flex items-center space-x-2 mb-2">
              <Badge variant="outline" className="bg-orange-100 text-orange-800 border-orange-200 dark:bg-orange-900/40 dark:text-orange-300 dark:border-orange-700">
                Production Mode
              </Badge>
            </div>
            <p className="text-sm text-orange-800 dark:text-orange-200">
              <strong>No {feature} data available.</strong> You're in production mode but no database is configured. 
              Enable demo mode to see sample data, or configure your database connection to see real {feature}.
            </p>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
EOF

echo ""
echo "Demo Mode Fixes Applied!"
echo "======================="
echo ""
echo "Updated components:"
echo "• API routes now properly check demo mode parameter"
echo "• Campaigns API returns empty data in production mode"
echo "• Templates API returns empty data in production mode"
echo "• Updated all pages to use demo-aware API calls"
echo "• Created ProductionModeWarning component"
echo ""
echo "Backup saved to: $backup_dir"
echo ""
echo "Now restart your dev server:"
echo "  npm run dev"
echo ""
echo "Test the demo mode toggle:"
echo "• Demo OFF: All pages should show empty data or warnings"
echo "• Demo ON: All pages should show sample data"
echo ""
echo "If emails page still shows demo data in production mode,"
echo "it may need manual updating. Check the file and ensure it:"
echo "1. Imports useDemoAPI hook"
echo "2. Uses fetchWithDemo instead of fetch"
echo "3. Reloads data when demo mode changes"
