import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const demoMode = searchParams.get('demo') === 'true'

  try {
    if (demoMode) {
      console.log('Returning demo templates data')
      const templates = [
        {
          id: 'biotech-intro-1',
          name: 'Biotech CTO Introduction',
          category: 'outreach',
          subject_template: 'Technology Due Diligence for {{company_name}}',
          html_content: `
            <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #ffffff;">
              <div style="text-align: center; margin-bottom: 30px;">
                <h2 style="color: #2563eb; margin: 0; font-size: 24px;">Technology Due Diligence</h2>
                <p style="color: #6b7280; margin: 5px 0 0 0;">Ferreira CTO Consulting</p>
              </div>
              
              <p style="color: #374151; line-height: 1.6;">Hi {{first_name}},</p>
              
              <p style="color: #374151; line-height: 1.6;">I hope this email finds you well. I'm Peter Ferreira, CTO at Ferreira CTO, and I specialize in technology due diligence for biotech companies like {{company_name}}.</p>
              
              <div style="background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <h3 style="color: #1f2937; margin-top: 0;">How I Can Help {{company_name}}</h3>
                <ul style="color: #374151; margin: 0; padding-left: 20px;">
                  <li>Technology stack evaluation and optimization</li>
                  <li>Technical team assessment and scaling strategies</li>
                  <li>Infrastructure review for regulatory compliance</li>
                  <li>Data security and privacy implementation</li>
                </ul>
              </div>
              
              <p style="color: #374151; line-height: 1.6;">Given {{company_name}}'s focus on {{industry}}, I'd love to discuss how we can ensure your technology foundation supports your growth objectives.</p>
              
              <p style="color: #374151; line-height: 1.6;">Would you be available for a brief 15-minute call next week?</p>
              
              <div style="margin: 30px 0; text-align: center;">
                <a href="https://calendly.com/peter-ferreira" style="background-color: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">Schedule a Call</a>
              </div>
              
              <p style="color: #374151; line-height: 1.6;">Best regards,<br>
              Peter Ferreira<br>
              CTO, Ferreira CTO<br>
              <a href="mailto:peter@ferreiracto.com" style="color: #2563eb;">peter@ferreiracto.com</a></p>
            </div>
          `,
          text_content: 'Hi {{first_name}},\\n\\nI hope this email finds you well...',
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-09-08T15:30:00Z'
        }
      ]

      return NextResponse.json({
        success: true,
        templates,
        count: templates.length,
        source: 'demo'
      })
    }

    // Production mode - return empty templates
    console.log('Production mode: No real database configured for templates')
    
    return NextResponse.json({
      success: true,
      templates: [],
      count: 0,
      source: 'production',
      message: 'No templates found. Configure your database connection to see real templates.'
    })

  } catch (error) {
    console.error('Templates API Error:', error)
    return NextResponse.json(
      { 
        error: 'Failed to fetch templates',
        source: demoMode ? 'demo' : 'production'
      },
      { status: 500 }
    )
  }
}
