import { NextRequest, NextResponse } from 'next/server'

export async function GET() {
  try {
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'
    
    // Fetch all saved data in parallel
    const [companiesRes, contactsRes, vcsRes] = await Promise.allSettled([
      fetch(`${baseUrl}/api/saved-companies`),
      fetch(`${baseUrl}/api/saved-contacts`),
      fetch(`${baseUrl}/api/saved-vcs`)
    ])
    
    const companies = companiesRes.status === 'fulfilled' && companiesRes.value.ok 
      ? (await companiesRes.value.json()).companies 
      : []
      
    const contacts = contactsRes.status === 'fulfilled' && contactsRes.value.ok 
      ? (await contactsRes.value.json()).contacts 
      : []
      
    const vcs = vcsRes.status === 'fulfilled' && vcsRes.value.ok 
      ? (await vcsRes.value.json()).vcs 
      : []
    
    return NextResponse.json({
      success: true,
      data: {
        companies: {
          items: companies,
          count: companies.length
        },
        contacts: {
          items: contacts,
          count: contacts.length
        },
        vcs: {
          items: vcs,
          count: vcs.length
        }
      },
      totals: {
        companies: companies.length,
        contacts: contacts.length,
        vcs: vcs.length,
        all: companies.length + contacts.length + vcs.length
      }
    })
    
  } catch (error) {
    console.error('Error fetching all saved data:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch saved data' },
      { status: 500 }
    )
  }
}
