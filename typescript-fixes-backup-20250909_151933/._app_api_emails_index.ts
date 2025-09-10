import { NextApiRequest, NextApiResponse } from 'next'
import { emailService } from '../../../lib/email'
import { supabaseAdmin } from '../../../lib/supabase'

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
