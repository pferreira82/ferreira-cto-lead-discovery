import { NextRequest, NextResponse } from 'next/server'

// Simple in-memory storage for demo purposes
// In production, you'd use a database
let savedCompanies: any[] = []

export async function GET() {
  try {
    return NextResponse.json({
      success: true,
      companies: savedCompanies,
      total: savedCompanies.length
    })
  } catch (error) {
    console.error('Error fetching saved companies:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch saved companies' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const { companies } = await request.json()
    
    // Add timestamp and ID to each company
    const companiesWithMetadata = companies.map((company: any) => ({
      ...company,
      saved_at: new Date().toISOString(),
      saved_id: `saved_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    }))
    
    // Add to saved companies (avoid duplicates based on company ID)
    companiesWithMetadata.forEach((newCompany: any) => {
      const existingIndex = savedCompanies.findIndex(
        (saved: any) => saved.id === newCompany.id
      )
      
      if (existingIndex >= 0) {
        // Update existing
        savedCompanies[existingIndex] = newCompany
      } else {
        // Add new
        savedCompanies.push(newCompany)
      }
    })
    
    console.log(`Saved ${companiesWithMetadata.length} companies. Total saved: ${savedCompanies.length}`)
    
    return NextResponse.json({
      success: true,
      message: `Saved ${companiesWithMetadata.length} companies`,
      total_saved: savedCompanies.length
    })
    
  } catch (error) {
    console.error('Error saving companies:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to save companies' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { company_ids } = await request.json()
    
    const originalCount = savedCompanies.length
    savedCompanies = savedCompanies.filter(
      (company: any) => !company_ids.includes(company.id)
    )
    const removedCount = originalCount - savedCompanies.length
    
    return NextResponse.json({
      success: true,
      message: `Removed ${removedCount} companies`,
      total_saved: savedCompanies.length
    })
    
  } catch (error) {
    console.error('Error removing saved companies:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to remove companies' },
      { status: 500 }
    )
  }
}
