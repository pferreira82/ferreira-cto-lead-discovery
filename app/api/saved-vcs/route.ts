import { NextRequest, NextResponse } from 'next/server'

// Simple in-memory storage for demo purposes
let savedVCs: any[] = []

export async function GET() {
  try {
    return NextResponse.json({
      success: true,
      vcs: savedVCs,
      total: savedVCs.length
    })
  } catch (error) {
    console.error('Error fetching saved VCs:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch saved VCs' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const { vcs } = await request.json()
    
    const vcsWithMetadata = vcs.map((vc: any) => ({
      ...vc,
      saved_at: new Date().toISOString(),
      saved_id: `saved_vc_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    }))
    
    vcsWithMetadata.forEach((newVC: any) => {
      const existingIndex = savedVCs.findIndex(
        (saved: any) => saved.email === newVC.email && saved.organization === newVC.organization
      )
      
      if (existingIndex >= 0) {
        savedVCs[existingIndex] = newVC
      } else {
        savedVCs.push(newVC)
      }
    })
    
    console.log(`Saved ${vcsWithMetadata.length} VCs. Total saved: ${savedVCs.length}`)
    
    return NextResponse.json({
      success: true,
      message: `Saved ${vcsWithMetadata.length} VCs/Investors`,
      total_saved: savedVCs.length
    })
    
  } catch (error) {
    console.error('Error saving VCs:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to save VCs' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { vc_ids } = await request.json()
    
    const originalCount = savedVCs.length
    savedVCs = savedVCs.filter(
      (vc: any) => !vc_ids.includes(vc.saved_id)
    )
    const removedCount = originalCount - savedVCs.length
    
    return NextResponse.json({
      success: true,
      message: `Removed ${removedCount} VCs`,
      total_saved: savedVCs.length
    })
    
  } catch (error) {
    console.error('Error removing saved VCs:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to remove VCs' },
      { status: 500 }
    )
  }
}
