import { NextRequest, NextResponse } from 'next/server'

// Simple in-memory storage for demo purposes
let savedContacts: any[] = []

export async function GET() {
  try {
    return NextResponse.json({
      success: true,
      contacts: savedContacts,
      total: savedContacts.length
    })
  } catch (error) {
    console.error('Error fetching saved contacts:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch saved contacts' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const { contacts, company_info } = await request.json()
    
    const contactsWithMetadata = contacts.map((contact: any) => ({
      ...contact,
      company_info: company_info || {
        company_id: contact.company_id,
        company_name: contact.company_name,
        company_domain: contact.company_domain
      },
      saved_at: new Date().toISOString(),
      saved_id: `saved_contact_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    }))
    
    contactsWithMetadata.forEach((newContact: any) => {
      const existingIndex = savedContacts.findIndex(
        (saved: any) => saved.email === newContact.email && saved.company_info?.company_id === newContact.company_info?.company_id
      )
      
      if (existingIndex >= 0) {
        savedContacts[existingIndex] = newContact
      } else {
        savedContacts.push(newContact)
      }
    })
    
    console.log(`Saved ${contactsWithMetadata.length} contacts. Total saved: ${savedContacts.length}`)
    
    return NextResponse.json({
      success: true,
      message: `Saved ${contactsWithMetadata.length} contacts`,
      total_saved: savedContacts.length
    })
    
  } catch (error) {
    console.error('Error saving contacts:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to save contacts' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { contact_ids } = await request.json()
    
    const originalCount = savedContacts.length
    savedContacts = savedContacts.filter(
      (contact: any) => !contact_ids.includes(contact.saved_id)
    )
    const removedCount = originalCount - savedContacts.length
    
    return NextResponse.json({
      success: true,
      message: `Removed ${removedCount} contacts`,
      total_saved: savedContacts.length
    })
    
  } catch (error) {
    console.error('Error removing saved contacts:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to remove contacts' },
      { status: 500 }
    )
  }
}
