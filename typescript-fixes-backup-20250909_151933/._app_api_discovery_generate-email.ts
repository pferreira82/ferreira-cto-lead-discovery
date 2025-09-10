import { NextApiRequest, NextApiResponse } from 'next'
import { aiLeadScorer } from '../../../lib/discovery/ai-lead-scorer'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    const { leadData, contactRole } = req.body

    if (!leadData || !contactRole) {
      return res.status(400).json({ error: 'Lead data and contact role required' })
    }

    const personalizedEmail = await aiLeadScorer.generatePersonalizedOutreach(leadData, contactRole)

    res.status(200).json({
      success: true,
      email: personalizedEmail
    })
  } catch (error) {
    console.error('Email Generation API Error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to generate email'
    })
  }
}
