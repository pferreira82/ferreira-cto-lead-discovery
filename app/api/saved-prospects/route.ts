import { NextRequest, NextResponse } from 'next/server'
import { existingSchemaProspects } from '@/lib/services/existing-schema-prospects'

export async function GET() {
  try {
    const prospects = await existingSchemaProspects.getSavedProspects()
    const stats = await existingSchemaProspects.getProspectStats()
    
    return NextResponse.json({
      success: true,
      prospects,
      ...stats
    })
  } catch (error) {
    console.error('Error fetching saved prospects:', error)
    return NextResponse.json(
      { 
        success: false, 
        message: error instanceof Error ? error.message : 'Failed to fetch saved prospects' 
      },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const { prospects } = await request.json()
    
    if (!prospects || !Array.isArray(prospects) || prospects.length === 0) {
      return NextResponse.json(
        { success: false, message: 'No prospects provided' },
        { status: 400 }
      )
    }

    console.log(`Saving ${prospects.length} prospects to existing schema:`, 
      prospects.map((p: any) => ({
        type: p.type,
        name: p.type === 'company' ? p.data.company : p.data.name
      }))
    )
    
    const result = await existingSchemaProspects.saveProspects(prospects)
    const stats = await existingSchemaProspects.getProspectStats()
    
    return NextResponse.json({
      success: true,
      message: `Saved ${prospects.length} prospects to database`,
      ...stats
    })
    
  } catch (error) {
    console.error('Error saving prospects:', error)
    return NextResponse.json(
      { 
        success: false, 
        message: error instanceof Error ? error.message : 'Failed to save prospects' 
      },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { prospect_ids } = await request.json()
    
    if (!prospect_ids || !Array.isArray(prospect_ids)) {
      return NextResponse.json(
        { success: false, message: 'Invalid prospect IDs provided' },
        { status: 400 }
      )
    }
    
    await existingSchemaProspects.deleteSavedProspects(prospect_ids)
    const stats = await existingSchemaProspects.getProspectStats()
    
    return NextResponse.json({
      success: true,
      message: `Deleted ${prospect_ids.length} prospects`,
      ...stats
    })
    
  } catch (error) {
    console.error('Error deleting prospects:', error)
    return NextResponse.json(
      { 
        success: false, 
        message: error instanceof Error ? error.message : 'Failed to delete prospects' 
      },
      { status: 500 }
    )
  }
}
