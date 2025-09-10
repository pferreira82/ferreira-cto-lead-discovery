import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('📊 Returning demo dashboard data')
      
      const stats = {
        totalContacts: 1247,
        totalCompanies: 186,
        emailsSent: 892,
        responseRate: 23.5,
        contactedThisWeek: 47,
        notContactedCount: 723,
        pipeline_value: 2400000,
        active_campaigns: 5
      }

      const charts = {
        emailActivity: [
          { date: 'Sep 1', sent: 45, opened: 25, replied: 6 },
          { date: 'Sep 2', sent: 52, opened: 30, replied: 8 },
          { date: 'Sep 3', sent: 48, opened: 22, replied: 5 },
          { date: 'Sep 4', sent: 61, opened: 35, replied: 12 },
          { date: 'Sep 5', sent: 55, opened: 28, replied: 9 },
          { date: 'Sep 6', sent: 47, opened: 20, replied: 4 },
          { date: 'Sep 7', sent: 38, opened: 15, replied: 3 },
        ],
        contactsByRole: [
          { role: 'Founder', count: 45, color: '#3B82F6' },
          { role: 'Executive', count: 67, color: '#8B5CF6' },
          { role: 'VC', count: 23, color: '#10B981' },
          { role: 'Board Member', count: 18, color: '#F59E0B' },
        ],
        companiesByStage: [
          { stage: 'Series A', count: 75 },
          { stage: 'Series B', count: 64 },
          { stage: 'Series C', count: 47 },
        ]
      }

      return NextResponse.json({ 
        success: true,
        stats, 
        charts,
        source: 'demo'
      })
    }

    // Production mode - try to fetch real data
    console.log('🔍 Production mode: fetching real dashboard data')
    
    // Return minimal stats since no real database is configured
    const stats = {
      totalContacts: 0,
      totalCompanies: 0,
      emailsSent: 0,
      responseRate: 0,
      contactedThisWeek: 0,
      notContactedCount: 0,
      pipeline_value: 0,
      active_campaigns: 0
    }

    const charts = {
      emailActivity: [],
      contactsByRole: [],
      companiesByStage: []
    }

    return NextResponse.json({ 
      success: true,
      stats, 
      charts,
      source: 'production',
      message: 'Configure your database to see real analytics data'
    })

  } catch (error) {
    console.error('Dashboard API Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch dashboard data',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
