import { NextApiRequest, NextApiResponse } from 'next'
import { dataScrapingService } from '../../../lib/scraper'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', ['POST'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    const { 
      industry = ['Biotechnology', 'Pharmaceuticals'],
      funding_stages = ['Series A', 'Series B', 'Series C'],
      locations,
      role_categories = ['CEO', 'CTO', 'Founder', 'VP', 'Director']
    } = req.body

    const results = await dataScrapingService.runAutomatedScraping({
      industry,
      funding_stages,
      locations,
      role_categories
    })

    res.status(200).json({
      success: true,
      message: 'Scraping completed successfully',
      results
    })
  } catch (error) {
    console.error('Scraping API Error:', error)
    res.status(500).json({ 
      success: false, 
      error: 'Failed to run automated scraping' 
    })
  }
}
