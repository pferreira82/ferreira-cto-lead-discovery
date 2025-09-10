import { NextRequest, NextResponse } from 'next/server'

// Simple in-memory storage for demo purposes
// In production, you'd use a database
let savedProspects: any[] = []

export async function GET() {
  try {
    return NextResponse.json({
      success: true,
      prospects: savedProspects,
      total: savedProspects.length,
      companies: savedProspects.filter(p => p.type === 'company').length,
      vcs: savedProspects.filter(p => p.type === 'vc').length,
      total_contacts: savedProspects
        .filter(p => p.type === 'company')
        .reduce((sum, p) => sum + (p.data.contacts?.length || 0), 0) +
        savedProspects.filter(p => p.type === 'vc').length
    })
  } catch (error) {
    console.error('Error fetching saved prospects:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch saved prospects' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const { prospects } = await request.json()
    
    console.log(`Saving ${prospects.length} prospects:`, prospects.map((p: any) => ({
      type: p.type,
      name: p.type === 'company' ? p.data.company : p.data.name
    })))
    
    // Add timestamp and ID to each prospect
    const prospectsWithMetadata = prospects.map((prospect: any) => ({
      type: prospect.type, // 'company' or 'vc'
      data: prospect.data,
      saved_at: new Date().toISOString(),
      saved_id: `saved_${prospect.type}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    }))
    
    // Add to saved prospects (avoid duplicates based on type and ID)
    prospectsWithMetadata.forEach((newProspect: any) => {
      const existingIndex = savedProspects.findIndex((saved: any) => {
        if (saved.type !== newProspect.type) return false
        
        if (newProspect.type === 'company') {
          return saved.data.id === newProspect.data.id
        } else if (newProspect.type === 'vc') {
          // For VCs, use name + organization as unique identifier
          return saved.data.name === newProspect.data.name && 
                 saved.data.organization === newProspect.data.organization
        }
        
        return false
      })
      
      if (existingIndex >= 0) {
        // Update existing
        savedProspects[existingIndex] = newProspect
        console.log(`Updated existing ${newProspect.type}: ${newProspect.type === 'company' ? newProspect.data.company : newProspect.data.name}`)
      } else {
        // Add new
        savedProspects.push(newProspect)
        console.log(`Added new ${newProspect.type}: ${newProspect.type === 'company' ? newProspect.data.company : newProspect.data.name}`)
      }
    })
    
    const companyCount = savedProspects.filter(p => p.type === 'company').length
    const vcCount = savedProspects.filter(p => p.type === 'vc').length
    const totalContacts = savedProspects
      .filter(p => p.type === 'company')
      .reduce((sum, p) => sum + (p.data.contacts?.length || 0), 0) + vcCount
    
    console.log(`Save complete. Total saved: ${savedProspects.length} prospects (${companyCount} companies, ${vcCount} VCs, ${totalContacts} total contacts)`)
    
    return NextResponse.json({
      success: true,
      message: `Saved ${prospectsWithMetadata.length} prospects (${prospectsWithMetadata.filter((p: any) => p.type === 'company').length} companies, ${prospectsWithMetadata.filter((p: any) => p.type === 'vc').length} VCs)`,
      total_saved: savedProspects.length,
      companies: companyCount,
      vcs: vcCount,
      total_contacts: totalContacts
    })
    
  } catch (error) {
    console.error('Error saving prospects:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to save prospects' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { prospect_ids } = await request.json()
    
    const originalCount = savedProspects.length
    savedProspects = savedProspects.filter(
      (prospect: any) => !prospect_ids.includes(prospect.saved_id)
    )
    const removedCount = originalCount - savedProspects.length
    
    return NextResponse.json({
      success: true,
      message: `Removed ${removedCount} prospects`,
      total_saved: savedProspects.length
    })
    
  } catch (error) {
    console.error('Error removing saved prospects:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to remove prospects' },
      { status: 500 }
    )
  }
}
