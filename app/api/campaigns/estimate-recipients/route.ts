import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const searchParams = await request.json()
    console.log('🔢 Estimating recipients for params:', searchParams)

    let estimate = 50 // Base estimate

    if (searchParams.target_types) {
      if (searchParams.target_types.includes('companies')) {
        estimate += 40
      }
      if (searchParams.target_types.includes('vc_firms')) {
        estimate += 15
      }
    }

    if (searchParams.industries && searchParams.industries.length > 3) {
      estimate += 25
    }

    if (searchParams.locations && searchParams.locations.length > 2) {
      estimate += 30
    }

    if (searchParams.funding_stages && searchParams.funding_stages.length > 4) {
      estimate += 20
    }

    const variation = Math.floor(Math.random() * 20) - 10
    estimate += variation
    estimate = Math.max(10, Math.min(estimate, 150))

    console.log('📊 Estimated recipients:', estimate)

    return NextResponse.json({
      success: true,
      count: estimate,
      breakdown: {
        companies: Math.floor(estimate * 0.7),
        vc_firms: Math.floor(estimate * 0.3)
      },
      message: `Estimated ${estimate} recipients based on your criteria`
    })
  } catch (error) {
    console.error('Estimate Recipients Error:', error)
    return NextResponse.json(
      { error: 'Failed to estimate recipients' },
      { status: 500 }
    )
  }
}
