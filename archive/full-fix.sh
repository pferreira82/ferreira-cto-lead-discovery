#!/bin/bash

echo "🔧 Fixing Supabase null check issues..."
echo "====================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Find all TypeScript files that use supabaseAdmin
echo "📁 Finding files that use supabaseAdmin..."
files_with_supabase=$(grep -r "supabaseAdmin" --include="*.ts" --include="*.tsx" . | cut -d: -f1 | sort -u)

if [ -z "$files_with_supabase" ]; then
    echo -e "${GREEN}✅ No files found using supabaseAdmin${NC}"
    exit 0
fi

echo "Found files using supabaseAdmin:"
echo "$files_with_supabase"
echo ""

# Backup files before modifying
echo "📦 Creating backups..."
for file in $files_with_supabase; do
    if [ -f "$file" ]; then
        cp "$file" "$file.nullcheck-backup"
        echo "   Backed up: $file"
    fi
done
echo ""

# Fix app/api/companies/[id].ts
echo "🔧 Fixing app/api/companies/[id].ts..."
if [ -f "app/api/companies/[id].ts" ]; then
    cat > app/api/companies/[id].ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin, isSupabaseConfigured } from '../../../lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query

  switch (req.method) {
    case 'GET':
      return getCompany(req, res, id as string)
    case 'PUT':
      return updateCompany(req, res, id as string)
    case 'DELETE':
      return deleteCompany(req, res, id as string)
    default:
      res.setHeader('Allow', ['GET', 'PUT', 'DELETE'])
      res.status(405).end(`Method ${req.method} Not Allowed`)
  }
}

async function getCompany(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return res.status(400).json({ 
        error: 'Database not configured',
        message: 'Supabase configuration is missing'
      })
    }

    const { data, error } = await supabaseAdmin
      .from('companies')
      .select(`
        *,
        contacts (
          id,
          first_name,
          last_name,
          email,
          title,
          role_category,
          contact_status
        )
      `)
      .eq('id', id)
      .single()

    if (error) throw error

    res.status(200).json(data)
  } catch (error) {
    console.error('Get Company Error:', error)
    res.status(500).json({ error: 'Failed to fetch company' })
  }
}

async function updateCompany(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return res.status(400).json({ 
        error: 'Database not configured',
        message: 'Supabase configuration is missing'
      })
    }

    const updateData = req.body

    const { data, error } = await supabaseAdmin
      .from('companies')
      .update({
        ...updateData,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    res.status(200).json(data)
  } catch (error) {
    console.error('Update Company Error:', error)
    res.status(500).json({ error: 'Failed to update company' })
  }
}

async function deleteCompany(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return res.status(400).json({ 
        error: 'Database not configured',
        message: 'Supabase configuration is missing'
      })
    }

    // First delete all associated contacts
    await supabaseAdmin
      .from('contacts')
      .delete()
      .eq('company_id', id)

    // Then delete the company
    const { error } = await supabaseAdmin
      .from('companies')
      .delete()
      .eq('id', id)

    if (error) throw error

    res.status(204).end()
  } catch (error) {
    console.error('Delete Company Error:', error)
    res.status(500).json({ error: 'Failed to delete company' })
  }
}
EOF
    echo -e "${GREEN}✅ Fixed app/api/companies/[id].ts${NC}"
fi

# Fix app/api/contacts/[id].ts
echo "🔧 Fixing app/api/contacts/[id].ts..."
if [ -f "app/api/contacts/[id].ts" ]; then
    cat > app/api/contacts/[id].ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { supabaseAdmin, isSupabaseConfigured } from '../../../lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query

  switch (req.method) {
    case 'GET':
      return getContact(req, res, id as string)
    case 'PUT':
      return updateContact(req, res, id as string)
    case 'DELETE':
      return deleteContact(req, res, id as string)
    default:
      res.setHeader('Allow', ['GET', 'PUT', 'DELETE'])
      res.status(405).end(`Method ${req.method} Not Allowed`)
  }
}

async function getContact(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return res.status(400).json({ 
        error: 'Database not configured',
        message: 'Supabase configuration is missing'
      })
    }

    const { data, error } = await supabaseAdmin
      .from('contacts')
      .select(`
        *,
        companies (
          id,
          name,
          industry,
          funding_stage,
          location
        )
      `)
      .eq('id', id)
      .single()

    if (error) throw error

    res.status(200).json(data)
  } catch (error) {
    console.error('Get Contact Error:', error)
    res.status(500).json({ error: 'Failed to fetch contact' })
  }
}

async function updateContact(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return res.status(400).json({ 
        error: 'Database not configured',
        message: 'Supabase configuration is missing'
      })
    }

    const updateData = req.body

    const { data, error } = await supabaseAdmin
      .from('contacts')
      .update({
        ...updateData,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    res.status(200).json(data)
  } catch (error) {
    console.error('Update Contact Error:', error)
    res.status(500).json({ error: 'Failed to update contact' })
  }
}

async function deleteContact(req: NextApiRequest, res: NextApiResponse, id: string) {
  try {
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return res.status(400).json({ 
        error: 'Database not configured',
        message: 'Supabase configuration is missing'
      })
    }

    const { error } = await supabaseAdmin
      .from('contacts')
      .delete()
      .eq('id', id)

    if (error) throw error

    res.status(204).end()
  } catch (error) {
    console.error('Delete Contact Error:', error)
    res.status(500).json({ error: 'Failed to delete contact' })
  }
}
EOF
    echo -e "${GREEN}✅ Fixed app/api/contacts/[id].ts${NC}"
fi

# Fix pages/api/emails/index.ts  
echo "🔧 Fixing pages/api/emails/index.ts..."
if [ -f "pages/api/emails/index.ts" ]; then
    cat > pages/api/emails/index.ts << 'EOF'
import { NextApiRequest, NextApiResponse } from 'next'
import { emailService } from '../../../lib/email'
import { supabaseAdmin, isSupabaseConfigured } from '../../../lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  switch (req.method) {
    case 'POST':
      if (req.query.action === 'send-bulk') {
        return sendBulkEmails(req, res)
      }
      return sendSingleEmail(req, res)
    case 'GET':
      return getEmailTemplates(req, res)
    default:
      res.setHeader('Allow', ['GET', 'POST'])
      res.status(405).end(`Method ${req.method} Not Allowed`)
  }
}

async function sendSingleEmail(req: NextApiRequest, res: NextApiResponse) {
  try {
    if (!isSupabaseConfigured() || !supabaseAdmin) {
      return res.status(400).json({ 
        error: 'Database not configured',
        message: 'Supabase configuration is missing'
      })
    }

    const { contactId, campaignId, customSubject, customContent } = req.body

    // Get contact details
    const { data: contact } = await supabaseAdmin
      .from('contacts')
      .select(`
        *,
        companies (*)
      `)
      .eq('id', contactId)
      .single()

    if (!contact || !contact.email) {
      return res.status(400).json({ error: 'Contact not found or missing email' })
    }

    let subject = customSubject
    let content = customContent

    // If using a campaign template
    if (campaignId && !customSubject && !customContent) {
      const { data: campaign } = await supabaseAdmin
        .from('email_campaigns')
        .select('*')
        .eq('id', campaignId)
        .single()

      if (campaign) {
        subject = await emailService.processEmailTemplate(campaign.subject, contact, contact.companies)
        content = await emailService.processEmailTemplate(campaign.template, contact, contact.companies)
      }
    }

    const success = await emailService.sendEmail({
      to: contact.email,
      subject,
      html: content,
      contactId,
      campaignId
    })

    if (success) {
      res.status(200).json({ success: true, message: 'Email sent successfully' })
    } else {
      res.status(500).json({ success: false, error: 'Failed to send email' })
    }
  } catch (error) {
    console.error('Send Email Error:', error)
    res.status(500).json({ error: 'Failed to send email' })
  }
}

async function sendBulkEmails(req: NextApiRequest, res: NextApiResponse) {
  try {
    const { contactIds, campaignId } = req.body

    if (!contactIds || !Array.isArray(contactIds) || contactIds.length === 0) {
      return res.status(400).json({ error: 'Contact IDs are required' })
    }

    if (!campaignId) {
      return res.status(400).json({ error: 'Campaign ID is required' })
    }

    await emailService.sendBulkEmails(contactIds, campaignId)

    res.status(200).json({ 
      success: true, 
      message: `Bulk email sent to ${contactIds.length} contacts` 
    })
  } catch (error) {
    console.error('Send Bulk Email Error:', error)
    res.status(500).json({ error: 'Failed to send bulk email' })
  }
}

async function getEmailTemplates(req: NextApiRequest, res: NextApiResponse) {
  try {
    const templates = await emailService.getEmailTemplates()
    res.status(200).json(templates)
  } catch (error) {
    console.error('Get Email Templates Error:', error)
    res.status(500).json({ error: 'Failed to fetch email templates' })
  }
}
EOF
    echo -e "${GREEN}✅ Fixed pages/api/emails/index.ts${NC}"
fi

# Update lib/supabase.ts to have better null handling
echo "🔧 Updating lib/supabase.ts with better null handling..."
if [ -f "lib/supabase.ts" ]; then
    cat > lib/supabase.ts << 'EOF'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

// Check if Supabase is properly configured
export function isSupabaseConfigured(): boolean {
  return !!(supabaseUrl && supabaseAnonKey && 
    supabaseUrl !== 'undefined' && 
    supabaseAnonKey !== 'undefined' &&
    supabaseUrl.startsWith('http'))
}

// Client-side Supabase client
export const supabase = isSupabaseConfigured() 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null

// Service role client for server-side operations
export function createServiceRoleClient() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  
  if (!serviceRoleKey || !supabaseUrl || !isSupabaseConfigured()) {
    return null
  }
  
  return createClient(supabaseUrl, serviceRoleKey)
}

// Admin client for API routes - can be null if not configured
export const supabaseAdmin = createServiceRoleClient()

// Helper function to ensure supabaseAdmin is available
export function requireSupabaseAdmin() {
  if (!supabaseAdmin) {
    throw new Error('Supabase admin client is not configured. Please check your environment variables.')
  }
  return supabaseAdmin
}

// Type definitions based on your existing schema
export interface Company {
  id: string
  name: string
  website?: string
  industry?: string
  funding_stage?: 'Series A' | 'Series B' | 'Series C'
  location?: string
  description?: string
  total_funding?: number
  last_funding_date?: string
  employee_count?: number
  crunchbase_url?: string
  linkedin_url?: string
  created_at: string
  updated_at: string
}

export interface Contact {
  id: string
  company_id?: string
  first_name: string
  last_name: string
  email?: string
  phone?: string
  title?: string
  role_category?: 'VC' | 'Founder' | 'Board Member' | 'Executive'
  linkedin_url?: string
  address?: string
  bio?: string
  contact_status?: 'not_contacted' | 'contacted' | 'responded' | 'interested' | 'not_interested'
  last_contacted_at?: string
  created_at: string
  updated_at: string
}

export interface EmailCampaign {
  id: string
  name: string
  subject: string
  template: string
  target_role_category?: string
  active: boolean
  created_at: string
  updated_at: string
}

export interface EmailLog {
  id: string
  contact_id?: string
  campaign_id?: string
  subject: string
  content: string
  sent_at: string
  opened_at?: string
  clicked_at?: string
  replied_at?: string
  bounced: boolean
  status: 'sent' | 'delivered' | 'opened' | 'clicked' | 'replied' | 'bounced'
}
EOF
    echo -e "${GREEN}✅ Updated lib/supabase.ts${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Null check fixes completed!${NC}"
echo ""
echo -e "${YELLOW}📋 Summary of changes:${NC}"
echo "• Added null checks for supabaseAdmin in all API routes"
echo "• Updated lib/supabase.ts with better error handling"
echo "• Added requireSupabaseAdmin() helper function"
echo "• Created backups of all modified files (.nullcheck-backup)"
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo "1. Try building: npm run build"
echo "2. If successful, test dev server: npm run dev"
echo "3. Configure Supabase environment variables if needed"
echo ""
echo -e "${YELLOW}🔑 Required environment variables:${NC}"
echo "• NEXT_PUBLIC_SUPABASE_URL"
echo "• NEXT_PUBLIC_SUPABASE_ANON_KEY" 
echo "• SUPABASE_SERVICE_ROLE_KEY"
