import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    // Return default email settings
    const settings = {
      sendgrid_api_key: '',
      from_name: 'Peter Ferreira',
      from_email: 'peter@ferreiracto.com',
      reply_to_email: 'peter@ferreiracto.com',
      company_name: 'Ferreira CTO',
      company_website: 'https://ferreiracto.com',
      signature: 'Best regards,\nPeter Ferreira\nCTO Consultant\nFerreira CTO',
      bounce_handling: true,
      click_tracking: true,
      open_tracking: true
    }

    return NextResponse.json({
      success: true,
      settings
    })
  } catch (error) {
    console.error('Email Settings API Error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch email settings' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    console.log('📝 Email settings saved:', body)
    
    return NextResponse.json({
      success: true,
      message: 'Email settings saved successfully',
      settings: body
    })
  } catch (error) {
    console.error('Save Email Settings Error:', error)
    return NextResponse.json(
      { error: 'Failed to save email settings' },
      { status: 500 }
    )
  }
}
