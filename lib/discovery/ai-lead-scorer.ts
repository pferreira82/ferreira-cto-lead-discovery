import OpenAI from 'openai'

interface LeadData {
  company: string
  industry: string
  fundingStage: string
  description: string
  recentNews?: string[]
  competitors?: string[]
  technologies?: string[]
  teamSize?: number
  location?: string
}

interface LeadScore {
  overallScore: number
  relevanceScore: number
  growthPotential: number
  techMaturity: number
  reasoning: string
  actionRecommendation: string
  urgencyLevel: 'low' | 'medium' | 'high' | 'critical'
  contactPriority: string[]
}

class AILeadScorer {
  private openai: OpenAI

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    })
  }

  async scoreLeadRelevance(leadData: LeadData): Promise<LeadScore> {
    try {
      const prompt = `
You are an expert technology due diligence consultant for biotech companies. Analyze this lead and provide a comprehensive score.

Company: ${leadData.company}
Industry: ${leadData.industry}
Funding Stage: ${leadData.fundingStage}
Description: ${leadData.description}
Team Size: ${leadData.teamSize || 'Unknown'}
Location: ${leadData.location || 'Unknown'}
Recent News: ${leadData.recentNews?.join(', ') || 'None'}
Technologies: ${leadData.technologies?.join(', ') || 'Unknown'}

As Peter Ferreira, CTO consultant specializing in biotech technology due diligence, evaluate this lead based on:

1. RELEVANCE (0-100): How well does this match biotech technology consulting needs?
2. GROWTH POTENTIAL (0-100): Likelihood of needing technology leadership/consulting
3. TECH MATURITY (0-100): How sophisticated their technology challenges likely are
4. URGENCY (low/medium/high/critical): How soon they might need consulting

Consider:
- Funding stage indicates growth phase and technology needs
- Biotech companies need specialized technology leadership
- Recent developments suggest immediate opportunities
- Team size indicates scale of technology challenges

Respond with JSON:
{
  "overallScore": number (0-100),
  "relevanceScore": number (0-100),
  "growthPotential": number (0-100),
  "techMaturity": number (0-100),
  "reasoning": "detailed explanation of scoring",
  "actionRecommendation": "specific next steps",
  "urgencyLevel": "low|medium|high|critical",
  "contactPriority": ["role1", "role2", "role3"] // who to contact first
}
`

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.3,
        max_tokens: 1000,
      })

      const content = response.choices[0]?.message?.content
      if (!content) throw new Error('No response from AI')

      return JSON.parse(content) as LeadScore
    } catch (error) {
      console.error('AI Lead Scoring Error:', error)
      // Fallback scoring
      return {
        overallScore: 50,
        relevanceScore: 50,
        growthPotential: 50,
        techMaturity: 50,
        reasoning: 'AI scoring unavailable, manual review recommended',
        actionRecommendation: 'Review manually and score based on biotech technology needs',
        urgencyLevel: 'medium',
        contactPriority: ['CTO', 'CEO', 'Head of Technology']
      }
    }
  }

  async generatePersonalizedOutreach(leadData: LeadData, contactRole: string): Promise<string> {
    try {
      const prompt = `
Generate a personalized cold email for Peter Ferreira (Ferreira CTO) reaching out to a ${contactRole} at ${leadData.company}.

Company Context:
- ${leadData.company} (${leadData.fundingStage})
- Industry: ${leadData.industry}
- Description: ${leadData.description}

Peter's Background:
- Fractional CTO specializing in AI, Robotics & SaaS for biotech
- Expert in technology due diligence and strategic consulting
- Helps biotech companies with technical architecture and leadership

Create a professional, concise email that:
1. Shows specific knowledge of their company
2. Highlights relevant technology challenges they likely face
3. Offers clear value proposition
4. Includes subtle social proof
5. Has a clear, low-pressure call to action

Keep it under 150 words, professional but personable.
`

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7,
        max_tokens: 500,
      })

      return response.choices[0]?.message?.content || 'Error generating email'
    } catch (error) {
      console.error('Email Generation Error:', error)
      return 'Error generating personalized email. Please create manually.'
    }
  }
}

export const aiLeadScorer = new AILeadScorer()
