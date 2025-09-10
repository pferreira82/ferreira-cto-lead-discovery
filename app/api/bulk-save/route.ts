import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const { 
      companies = [], 
      contacts = [], 
      vcs = [],
      action = 'save'
    } = await request.json()
    
    const results = {
      companies: { saved: 0, failed: 0 },
      contacts: { saved: 0, failed: 0 },
      vcs: { saved: 0, failed: 0 },
      errors: [] as string[]
    }
    
    // Save companies if provided
    if (companies.length > 0) {
      try {
        const companyResponse = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/api/saved-companies`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ companies, action })
        })
        
        if (companyResponse.ok) {
          results.companies.saved = companies.length
        } else {
          results.companies.failed = companies.length
          results.errors.push('Failed to save companies')
        }
      } catch (error) {
        results.companies.failed = companies.length
        results.errors.push(`Company save error: ${error}`)
      }
    }
    
    // Save contacts if provided
    if (contacts.length > 0) {
      try {
        // Group contacts by company for better organization
        const contactsByCompany = contacts.reduce((acc: any, contact: any) => {
          const companyId = contact.company_id || 'unknown'
          if (!acc[companyId]) acc[companyId] = []
          acc[companyId].push(contact)
          return acc
        }, {})
        
        for (const [companyId, companyContacts] of Object.entries(contactsByCompany)) {
          const contactResponse = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/api/saved-contacts`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
              contacts: companyContacts,
              company_info: {
                company_id: companyId,
                company_name: (companyContacts as any[])[0]?.company_name,
                company_domain: (companyContacts as any[])[0]?.company_domain
              }
            })
          })
          
          if (contactResponse.ok) {
            results.contacts.saved += (companyContacts as any[]).length
          } else {
            results.contacts.failed += (companyContacts as any[]).length
            results.errors.push(`Failed to save contacts for company ${companyId}`)
          }
        }
      } catch (error) {
        results.contacts.failed = contacts.length
        results.errors.push(`Contact save error: ${error}`)
      }
    }
    
    // Save VCs if provided
    if (vcs.length > 0) {
      try {
        const vcResponse = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/api/saved-vcs`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ vcs })
        })
        
        if (vcResponse.ok) {
          results.vcs.saved = vcs.length
        } else {
          results.vcs.failed = vcs.length
          results.errors.push('Failed to save VCs')
        }
      } catch (error) {
        results.vcs.failed = vcs.length
        results.errors.push(`VC save error: ${error}`)
      }
    }
    
    const totalSaved = results.companies.saved + results.contacts.saved + results.vcs.saved
    const totalFailed = results.companies.failed + results.contacts.failed + results.vcs.failed
    
    return NextResponse.json({
      success: totalFailed === 0,
      message: `Saved ${totalSaved} items${totalFailed > 0 ? `, ${totalFailed} failed` : ''}`,
      results,
      total_saved: totalSaved,
      total_failed: totalFailed
    })
    
  } catch (error) {
    console.error('Bulk save error:', error)
    return NextResponse.json(
      { success: false, message: 'Bulk save operation failed' },
      { status: 500 }
    )
  }
}
