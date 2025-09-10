export default async function handler(req, res) {
  // Add CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')

  if (req.method === 'OPTIONS') {
    res.status(200).end()
    return
  }

  try {
    if (req.method === 'GET') {
      // Return default settings for now
      return res.status(200).json({
        success: true,
        settings: {
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
      })
    }

    if (req.method === 'POST') {
      // In a real app, you'd save these to a database or env vars
      // For now, just return success
      console.log('📝 Email settings saved:', req.body)
      
      return res.status(200).json({
        success: true,
        message: 'Email settings saved successfully',
        settings: req.body
      })
    }

    return res.status(405).json({ 
      success: false,
      error: `Method ${req.method} not allowed` 
    })

  } catch (error) {
    console.error('Settings API Error:', error)
    return res.status(500).json({
      success: false,
      error: error.message || 'Server error'
    })
  }
}
