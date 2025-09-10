// Using .js instead of .ts to avoid potential TypeScript issues
const sgMail = require('@sendgrid/mail')

export default async function handler(req, res) {
  // Add CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')

  if (req.method === 'OPTIONS') {
    res.status(200).end()
    return
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ 
      success: false,
      error: `Method ${req.method} not allowed. Use POST.` 
    })
  }

  try {
    console.log('📧 Email test API called')
    console.log('📝 Request body:', JSON.stringify(req.body, null, 2))

    const {
      sendgrid_api_key,
      from_name,
      from_email,
      test_recipient,
      company_name
    } = req.body

    // Validate required fields
    if (!sendgrid_api_key) {
      return res.status(400).json({ 
        success: false,
        error: 'SendGrid API key is required' 
      })
    }

    if (!from_email) {
      return res.status(400).json({ 
        success: false,
        error: 'From email is required' 
      })
    }

    if (!test_recipient) {
      return res.status(400).json({ 
        success: false,
        error: 'Test recipient email is required' 
      })
    }

    console.log('✅ All required fields present')

    // Configure SendGrid
    sgMail.setApiKey(sendgrid_api_key)
    console.log('🔑 SendGrid API key configured')

    // Create test email with simpler structure
    const msg = {
      to: test_recipient,
      from: {
        email: from_email,
        name: from_name || 'Test Sender'
      },
      subject: '🧪 Email Configuration Test - Ferreira CTO',
      text: `
Email Configuration Test - SUCCESS!

Your email configuration is working correctly.

Configuration Details:
- From Name: ${from_name || 'Test Sender'}
- From Email: ${from_email}
- Company: ${company_name || 'Test Company'}
- Service: SendGrid
- Test Time: ${new Date().toLocaleString()}

Your SendGrid configuration is properly set up and ready for email campaigns.

This test email was sent from your Biotech Lead Generator system.
Ferreira CTO • Technology Due Diligence
      `,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%); color: white; padding: 20px; text-align: center; border-radius: 8px; margin-bottom: 20px;">
            <h1 style="margin: 0; font-size: 24px;">✅ Test Successful!</h1>
            <p style="margin: 10px 0 0 0; opacity: 0.9;">Your email configuration is working correctly</p>
          </div>
          
          <div style="background: #F8F9FA; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #1F2937; margin-top: 0;">Configuration Details</h2>
            <ul style="color: #4B5563; margin: 0; padding-left: 20px;">
              <li><strong>From Name:</strong> ${from_name || 'Test Sender'}</li>
              <li><strong>From Email:</strong> ${from_email}</li>
              <li><strong>Company:</strong> ${company_name || 'Test Company'}</li>
              <li><strong>Service:</strong> SendGrid</li>
              <li><strong>Test Time:</strong> ${new Date().toLocaleString()}</li>
            </ul>
          </div>
          
          <div style="background: #EFF6FF; border-left: 4px solid #3B82F6; padding: 15px; margin-bottom: 20px;">
            <h3 style="color: #1E40AF; margin-top: 0; font-size: 16px;">What This Means</h3>
            <p style="color: #1F2937; margin: 0; font-size: 14px;">
              Your SendGrid configuration is properly set up and ready for email campaigns. 
              You can now confidently send biotech outreach campaigns through your system.
            </p>
          </div>
          
          <div style="text-align: center; margin: 30px 0;">
            <p style="color: #6B7280; font-size: 14px; margin: 0;">
              This test email was sent from your Biotech Lead Generator system.
            </p>
            <p style="color: #6B7280; font-size: 12px; margin: 5px 0 0 0;">
              Ferreira CTO • Technology Due Diligence
            </p>
          </div>
        </div>
      `
    }

    console.log('📨 Attempting to send test email...')

    // Send the test email
    await sgMail.send(msg)

    console.log('✅ Test email sent successfully')

    return res.status(200).json({
      success: true,
      message: `Test email sent successfully to ${test_recipient}`,
      details: {
        from: `${from_name} <${from_email}>`,
        to: test_recipient,
        subject: msg.subject,
        timestamp: new Date().toISOString()
      }
    })

  } catch (error) {
    console.error('❌ Email test error:', error)
    
    // Handle specific SendGrid errors
    if (error.response && error.response.body) {
      const sgError = error.response.body.errors?.[0]
      if (sgError) {
        console.error('SendGrid Error:', sgError)
        return res.status(400).json({
          success: false,
          error: `SendGrid Error: ${sgError.message}`,
          details: sgError
        })
      }
    }

    // Handle general errors
    return res.status(500).json({
      success: false,
      error: error.message || 'Failed to send test email',
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined
    })
  }
}
