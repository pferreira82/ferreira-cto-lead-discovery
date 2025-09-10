import nodemailer from 'nodemailer'
import { supabaseAdmin, isSupabaseConfigured } from './supabase'

interface EmailTemplate {
  id: string
  name: string
  subject: string
  template: string
  target_role_category?: string
}

interface SendEmailParams {
  to: string
  subject: string
  html: string
  contactId: string
  campaignId?: string
}

class EmailService {
  private transporter: nodemailer.Transporter

  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: false,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    })
  }

  async sendEmail(params: SendEmailParams): Promise<boolean> {
    try {
      const mailOptions = {
        from: `"${process.env.COMPANY_NAME}" <${process.env.COMPANY_EMAIL}>`,
        to: params.to,
        subject: params.subject,
        html: params.html,
        headers: {
          'X-Contact-ID': params.contactId,
          'X-Campaign-ID': params.campaignId || ''
        }
      }

      const result = await this.transporter.sendMail(mailOptions)

      // Log email in database
      await this.logEmail({
        contactId: params.contactId,
        campaignId: params.campaignId,
        subject: params.subject,
        content: params.html,
        status: 'sent'
      })

      // Update contact status
      await supabaseAdmin
        .from('contacts')
        .update({
          contact_status: 'contacted',
          last_contacted_at: new Date().toISOString()
        })
        .eq('id', params.contactId)

      return true
    } catch (error) {
      console.error('Email Send Error:', error)
      
      // Log failed email
      await this.logEmail({
        contactId: params.contactId,
        campaignId: params.campaignId,
        subject: params.subject,
        content: params.html,
        status: 'bounced'
      })

      return false
    }
  }

  private async logEmail(emailData: {
    contactId: string
    campaignId?: string
    subject: string
    content: string
    status: string
  }) {
    try {
      await supabaseAdmin
        .from('email_logs')
        .insert({
          contact_id: emailData.contactId,
          campaign_id: emailData.campaignId,
          subject: emailData.subject,
          content: emailData.content,
          status: emailData.status
        })
    } catch (error) {
      console.error('Email Log Error:', error)
    }
  }

  async processEmailTemplate(template: string, contact: any, company: any): Promise<string> {
    let processedTemplate = template

    // Replace contact variables
    processedTemplate = processedTemplate.replace(/{{first_name}}/g, contact.first_name || 'there')
    processedTemplate = processedTemplate.replace(/{{last_name}}/g, contact.last_name || '')
    processedTemplate = processedTemplate.replace(/{{full_name}}/g, `${contact.first_name} ${contact.last_name}`)
    processedTemplate = processedTemplate.replace(/{{title}}/g, contact.title || 'professional')

    // Replace company variables
    if (company) {
      processedTemplate = processedTemplate.replace(/{{company_name}}/g, company.name || '')
      processedTemplate = processedTemplate.replace(/{{company_industry}}/g, company.industry || 'biotechnology')
      processedTemplate = processedTemplate.replace(/{{funding_stage}}/g, company.funding_stage || '')
    }

    // Replace sender info
    processedTemplate = processedTemplate.replace(/{{sender_name}}/g, 'Peter Ferreira')
    processedTemplate = processedTemplate.replace(/{{sender_company}}/g, process.env.COMPANY_NAME || 'Ferreira CTO')
    processedTemplate = processedTemplate.replace(/{{sender_email}}/g, process.env.COMPANY_EMAIL || 'peter@ferreiracto.com')

    return processedTemplate
  }

  async getEmailTemplates(): Promise<EmailTemplate[]> {
    try {
      const { data, error } = await supabaseAdmin
        .from('email_campaigns')
        .select('*')
        .eq('active', true)

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Get Email Templates Error:', error)
      return []
    }
  }

  async sendBulkEmails(contactIds: string[], campaignId: string): Promise<void> {
    try {
      // Get campaign details
      const { data: campaign } = await supabaseAdmin
        .from('email_campaigns')
        .select('*')
        .eq('id', campaignId)
        .single()

      if (!campaign) throw new Error('Campaign not found')

      // Get contacts with company info
      const { data: contacts } = await supabaseAdmin
        .from('contacts')
        .select(`
          *,
          companies (*)
        `)
        .in('id', contactIds)
        .eq('contact_status', 'not_contacted')
        .not('email', 'is', null)

      if (!contacts) return

      // Send emails with delay to avoid rate limiting
      for (const contact of contacts) {
        if (!contact.email) continue

        const processedSubject = await this.processEmailTemplate(campaign.subject, contact, contact.companies)
        const processedContent = await this.processEmailTemplate(campaign.template, contact, contact.companies)

        await this.sendEmail({
          to: contact.email,
          subject: processedSubject,
          html: processedContent,
          contactId: contact.id,
          campaignId: campaign.id
        })

        // Add delay between emails (1 second)
        await new Promise(resolve => setTimeout(resolve, 1000))
      }
    } catch (error) {
      console.error('Bulk Email Error:', error)
      throw error
    }
  }
}

export const emailService = new EmailService()
