import sgMail from '@sendgrid/mail'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY!
const supabase = createClient(supabaseUrl, supabaseKey)

// Initialize SendGrid
if (process.env.SENDGRID_API_KEY) {
  sgMail.setApiKey(process.env.SENDGRID_API_KEY)
}

export interface EmailData {
  to: string
  from: string
  fromName?: string
  replyTo?: string
  subject: string
  html: string
  text?: string
  campaignId?: string
  contactId?: string
  trackingData?: any
}

export interface BulkEmailData {
  campaignId: string
  templateId: string
  fromName: string
  fromEmail: string
  replyTo: string
  recipients: Array<{
    contactId: string
    email: string
    personalizations: Record<string, any>
  }>
}

class EmailService {
  async sendSingleEmail(emailData: EmailData): Promise<boolean> {
    try {
      const msg = {
        to: emailData.to,
        from: {
          email: emailData.from,
          name: emailData.fromName || 'Peter Ferreira'
        },
        replyTo: emailData.replyTo || emailData.from,
        subject: emailData.subject,
        html: emailData.html,
        text: emailData.text || this.stripHtml(emailData.html),
        trackingSettings: {
          clickTracking: { enable: true },
          openTracking: { enable: true },
          subscriptionTracking: { enable: false }
        },
        customArgs: {
          campaign_id: emailData.campaignId || '',
          contact_id: emailData.contactId || ''
        }
      }

      await sgMail.send(msg)
      
      // Log the send event
      if (emailData.campaignId && emailData.contactId) {
        await this.logEmailEvent({
          campaignId: emailData.campaignId,
          contactId: emailData.contactId,
          eventType: 'sent',
          eventData: { email: emailData.to }
        })
      }

      return true
    } catch (error) {
      console.error('Email send error:', error)
      
      // Log the error
      if (emailData.campaignId && emailData.contactId) {
        await this.logEmailEvent({
          campaignId: emailData.campaignId,
          contactId: emailData.contactId,
          eventType: 'bounced',
          eventData: { error: error.message, email: emailData.to }
        })
      }
      
      return false
    }
  }

  async sendBulkCampaign(bulkData: BulkEmailData): Promise<{
    sent: number
    failed: number
    errors: string[]
  }> {
    const results = { sent: 0, failed: 0, errors: [] as string[] }
    
    try {
      // Get template
      const { data: template } = await supabase
        .from('email_templates')
        .select('*')
        .eq('id', bulkData.templateId)
        .single()

      if (!template) {
        throw new Error('Template not found')
      }

      // Process recipients in batches
      const batchSize = 100
      for (let i = 0; i < bulkData.recipients.length; i += batchSize) {
        const batch = bulkData.recipients.slice(i, i + batchSize)
        
        for (const recipient of batch) {
          try {
            // Personalize content
            const personalizedSubject = this.personalizeContent(
              template.subject_template, 
              recipient.personalizations
            )
            const personalizedHtml = this.personalizeContent(
              template.html_content, 
              recipient.personalizations
            )
            const personalizedText = this.personalizeContent(
              template.text_content || '', 
              recipient.personalizations
            )

            // Send email
            const success = await this.sendSingleEmail({
              to: recipient.email,
              from: bulkData.fromEmail,
              fromName: bulkData.fromName,
              replyTo: bulkData.replyTo,
              subject: personalizedSubject,
              html: personalizedHtml,
              text: personalizedText,
              campaignId: bulkData.campaignId,
              contactId: recipient.contactId
            })

            if (success) {
              results.sent++
              
              // Update recipient status
              await supabase
                .from('campaign_recipients')
                .update({
                  status: 'sent',
                  sent_at: new Date().toISOString(),
                  personalized_subject: personalizedSubject,
                  personalized_content: personalizedHtml
                })
                .eq('campaign_id', bulkData.campaignId)
                .eq('contact_id', recipient.contactId)
            } else {
              results.failed++
            }
          } catch (error) {
            results.failed++
            results.errors.push(`${recipient.email}: ${error.message}`)
          }
          
          // Rate limiting - pause between sends
          await this.delay(100)
        }
      }

      // Update campaign stats
      await this.updateCampaignStats(bulkData.campaignId)

    } catch (error) {
      console.error('Bulk email error:', error)
      results.errors.push(error.message)
    }

    return results
  }

  private personalizeContent(content: string, variables: Record<string, any>): string {
    let personalized = content
    
    Object.entries(variables).forEach(([key, value]) => {
      const regex = new RegExp(`{{${key}}}`, 'g')
      personalized = personalized.replace(regex, value || '')
    })
    
    return personalized
  }

  private stripHtml(html: string): string {
    return html.replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim()
  }

  private async delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  private async logEmailEvent(eventData: {
    campaignId: string
    contactId: string
    eventType: string
    eventData: any
  }): Promise<void> {
    try {
      await supabase
        .from('email_events')
        .insert({
          campaign_id: eventData.campaignId,
          contact_id: eventData.contactId,
          event_type: eventData.eventType,
          event_data: eventData.eventData
        })
    } catch (error) {
      console.error('Failed to log email event:', error)
    }
  }

  private async updateCampaignStats(campaignId: string): Promise<void> {
    try {
      const { data: stats } = await supabase
        .from('campaign_recipients')
        .select('status')
        .eq('campaign_id', campaignId)

      if (stats) {
        const sentCount = stats.filter(r => r.status === 'sent').length
        const deliveredCount = stats.filter(r => r.status === 'delivered').length
        const openedCount = stats.filter(r => r.status === 'opened').length
        const clickedCount = stats.filter(r => r.status === 'clicked').length
        const bouncedCount = stats.filter(r => r.status === 'bounced').length

        await supabase
          .from('email_campaigns')
          .update({
            sent_count: sentCount,
            delivered_count: deliveredCount,
            opened_count: openedCount,
            clicked_count: clickedCount,
            bounced_count: bouncedCount,
            updated_at: new Date().toISOString()
          })
          .eq('id', campaignId)
      }
    } catch (error) {
      console.error('Failed to update campaign stats:', error)
    }
  }

  async checkUnsubscribed(email: string): Promise<boolean> {
    try {
      const { data } = await supabase
        .from('unsubscribe_list')
        .select('id')
        .eq('email', email.toLowerCase())
        .limit(1)

      return !!data && data.length > 0
    } catch (error) {
      console.error('Failed to check unsubscribe status:', error)
      return false
    }
  }

  async unsubscribe(email: string, reason?: string): Promise<void> {
    try {
      await supabase
        .from('unsubscribe_list')
        .upsert({
          email: email.toLowerCase(),
          reason: reason || 'User requested',
          unsubscribed_at: new Date().toISOString()
        })
    } catch (error) {
      console.error('Failed to unsubscribe:', error)
    }
  }
}

export const emailService = new EmailService()
