import { Client } from '@hubspot/api-client'

class HubSpotService {
  private client: Client

  constructor() {
    this.client = new Client({
      accessToken: process.env.HUBSPOT_API_KEY
    })
  }

  async createContact(contactData: {
    email: string
    firstname: string
    lastname: string
    jobtitle?: string
    company?: string
    phone?: string
    website?: string
  }) {
    try {
      const properties = {
        email: contactData.email,
        firstname: contactData.firstname,
        lastname: contactData.lastname,
        jobtitle: contactData.jobtitle,
        company: contactData.company,
        phone: contactData.phone,
        website: contactData.website
      }

      const response = await this.client.crm.contacts.basicApi.create({
        properties,
        associations: []
      })

      return response
    } catch (error) {
      console.error('HubSpot Create Contact Error:', error)
      throw error
    }
  }

  async updateContactEngagement(contactId: string, engagementData: {
    email_opened?: boolean
    email_clicked?: boolean
    email_replied?: boolean
    last_contacted?: string
  }) {
    try {
      const properties: any = {}
      
      if (engagementData.email_opened) properties.hs_email_last_opened = new Date().toISOString()
      if (engagementData.email_clicked) properties.hs_email_last_clicked = new Date().toISOString()
      if (engagementData.email_replied) properties.hs_email_last_replied = new Date().toISOString()
      if (engagementData.last_contacted) properties.notes_last_contacted = engagementData.last_contacted

      const response = await this.client.crm.contacts.basicApi.update(contactId, {
        properties
      })

      return response
    } catch (error) {
      console.error('HubSpot Update Contact Error:', error)
      throw error
    }
  }

  async createEmailActivity(contactId: string, emailData: {
    subject: string
    html: string
    timestamp: string
  }) {
    try {
      const response = await this.client.crm.objects.emails.basicApi.create({
        properties: {
          hs_email_subject: emailData.subject,
          hs_email_html: emailData.html,
          hs_timestamp: emailData.timestamp
        },
        associations: [
          {
            to: { id: contactId },
            types: [{ associationCategory: 'HUBSPOT_DEFINED', associationTypeId: 198 }]
          }
        ]
      })

      return response
    } catch (error) {
      console.error('HubSpot Create Email Activity Error:', error)
      throw error
    }
  }

  async getContactByEmail(email: string) {
    try {
      const response = await this.client.crm.contacts.basicApi.getById(
        email,
        ['email', 'firstname', 'lastname', 'jobtitle', 'company'],
        undefined,
        undefined,
        undefined,
        'email'
      )

      return response
    } catch (error) {
      if (error.status === 404) {
        return null // Contact not found
      }
      console.error('HubSpot Get Contact Error:', error)
      throw error
    }
  }
}

export const hubspotService = new HubSpotService()
