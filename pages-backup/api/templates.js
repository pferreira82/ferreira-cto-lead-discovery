// API endpoint for email templates
export default async function handler(req, res) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  try {
    // Demo templates - in production this would come from database
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
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              Hi {{first_name}},
            </p>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              I hope this email finds you well. I'm Peter Ferreira, CTO consultant specializing in technology due diligence for biotech companies like {{company_name}}.
            </p>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              I've been following {{company_name}}'s progress in {{industry}} and am impressed by your {{funding_stage}} growth. Companies at your stage often face complex technology challenges around:
            </p>
            
            <div style="background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <ul style="color: #374151; margin: 0; padding-left: 20px;">
                <li style="margin-bottom: 8px;">Scalable cloud infrastructure for {{industry}} applications</li>
                <li style="margin-bottom: 8px;">AI/ML pipeline optimization for research workflows</li>
                <li style="margin-bottom: 8px;">Regulatory compliance and data management systems</li>
                <li style="margin-bottom: 8px;">Strategic technology roadmap planning</li>
              </ul>
            </div>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              I help biotech CTOs and leadership teams navigate these challenges with hands-on expertise in AI, robotics, and SaaS platforms.
            </p>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 30px;">
              Would you be open to a brief 15-minute conversation about {{company_name}}'s technology priorities? I'd be happy to share some insights relevant to your {{industry}} focus.
            </p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="https://calendly.com/peter-ferreira/15min" style="background-color: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: 500;">
                Schedule a Brief Call
              </a>
            </div>
            
            <div style="border-top: 2px solid #e5e7eb; padding-top: 20px; margin-top: 30px;">
              <p style="color: #374151; line-height: 1.6; margin-bottom: 5px;">
                Best regards,<br>
                <strong>Peter Ferreira</strong>
              </p>
              <p style="color: #6b7280; font-size: 14px; line-height: 1.4; margin: 0;">
                CTO Consultant • Technology Due Diligence<br>
                Ferreira CTO<br>
                📧 peter@ferreiracto.com<br>
                🌐 <a href="https://ferreiracto.com" style="color: #2563eb;">www.ferreiracto.com</a>
              </p>
            </div>
          </div>
        `,
        text_content: `Hi {{first_name}},

I hope this email finds you well. I'm Peter Ferreira, CTO consultant specializing in technology due diligence for biotech companies like {{company_name}}.

I've been following {{company_name}}'s progress in {{industry}} and am impressed by your {{funding_stage}} growth. Companies at your stage often face complex technology challenges around:

• Scalable cloud infrastructure for {{industry}} applications  
• AI/ML pipeline optimization for research workflows
• Regulatory compliance and data management systems
• Strategic technology roadmap planning

I help biotech CTOs and leadership teams navigate these challenges with hands-on expertise in AI, robotics, and SaaS platforms.

Would you be open to a brief 15-minute conversation about {{company_name}}'s technology priorities? I'd be happy to share some insights relevant to your {{industry}} focus.

Schedule a call: https://calendly.com/peter-ferreira/15min

Best regards,
Peter Ferreira
CTO Consultant • Technology Due Diligence
Ferreira CTO
📧 peter@ferreiracto.com
🌐 www.ferreiracto.com`,
        variables: ['first_name', 'last_name', 'company_name', 'industry', 'funding_stage', 'title']
      },
      {
        id: 'vc-partnership-1',
        name: 'VC Partnership Proposal',
        category: 'vc_outreach',
        subject_template: 'Technology Due Diligence Partnership - {{vc_firm_name}}',
        html_content: `
          <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #ffffff;">
            <div style="text-align: center; margin-bottom: 30px;">
              <h2 style="color: #7c3aed; margin: 0; font-size: 24px;">Strategic Partnership Opportunity</h2>
              <p style="color: #6b7280; margin: 5px 0 0 0;">Ferreira CTO Consulting</p>
            </div>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              Hi {{first_name}},
            </p>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              I'm Peter Ferreira, a CTO consultant specializing in technology due diligence for biotech investments. I've been following {{vc_firm_name}}'s impressive portfolio in {{focus_area}} and would like to explore a strategic partnership opportunity.
            </p>
            
            <div style="background-color: #faf5ff; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #7c3aed;">
              <h3 style="color: #581c87; margin: 0 0 15px 0; font-size: 18px;">How I Support VC Firms:</h3>
              <ul style="color: #374151; margin: 0; padding-left: 20px;">
                <li style="margin-bottom: 8px;"><strong>Technical Due Diligence:</strong> Deep-dive analysis of portfolio companies' technology stacks</li>
                <li style="margin-bottom: 8px;"><strong>Scaling Assessment:</strong> Evaluate technical readiness for growth and next funding rounds</li>
                <li style="margin-bottom: 8px;"><strong>CTO Network:</strong> Connect portfolio companies with experienced technology leadership</li>
                <li style="margin-bottom: 8px;"><strong>Risk Mitigation:</strong> Identify technical debt and infrastructure bottlenecks early</li>
              </ul>
            </div>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              My background includes AI/robotics expertise and extensive experience with Series A-C biotech companies. I understand the unique challenges of scaling technology in highly regulated industries.
            </p>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 30px;">
              Would you be interested in a 20-minute conversation about how technical due diligence could strengthen {{vc_firm_name}}'s investment process? I'd be happy to share case studies from recent engagements.
            </p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="https://calendly.com/peter-ferreira/20min" style="background-color: #7c3aed; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: 500;">
                Schedule Partnership Discussion
              </a>
            </div>
            
            <div style="border-top: 2px solid #e5e7eb; padding-top: 20px; margin-top: 30px;">
              <p style="color: #374151; line-height: 1.6; margin-bottom: 5px;">
                Best regards,<br>
                <strong>Peter Ferreira</strong>
              </p>
              <p style="color: #6b7280; font-size: 14px; line-height: 1.4; margin: 0;">
                CTO Consultant • Technology Due Diligence<br>
                Ferreira CTO<br>
                📧 peter@ferreiracto.com<br>
                🌐 <a href="https://ferreiracto.com" style="color: #7c3aed;">www.ferreiracto.com</a>
              </p>
            </div>
          </div>
        `,
        text_content: `Hi {{first_name}},

I'm Peter Ferreira, a CTO consultant specializing in technology due diligence for biotech investments. I've been following {{vc_firm_name}}'s impressive portfolio in {{focus_area}} and would like to explore a strategic partnership opportunity.

How I Support VC Firms:

• Technical Due Diligence: Deep-dive analysis of portfolio companies' technology stacks
• Scaling Assessment: Evaluate technical readiness for growth and next funding rounds  
• CTO Network: Connect portfolio companies with experienced technology leadership
• Risk Mitigation: Identify technical debt and infrastructure bottlenecks early

My background includes AI/robotics expertise and extensive experience with Series A-C biotech companies. I understand the unique challenges of scaling technology in highly regulated industries.

Would you be interested in a 20-minute conversation about how technical due diligence could strengthen {{vc_firm_name}}'s investment process? I'd be happy to share case studies from recent engagements.

Schedule a call: https://calendly.com/peter-ferreira/20min

Best regards,
Peter Ferreira
CTO Consultant • Technology Due Diligence
Ferreira CTO
📧 peter@ferreiracto.com
🌐 www.ferreiracto.com`,
        variables: ['first_name', 'last_name', 'vc_firm_name', 'focus_area', 'company_name']
      },
      {
        id: 'followup-meeting-1',
        name: 'Follow-up Meeting Request',
        category: 'followup',
        subject_template: 'Following up on {{company_name}} technology discussion',
        html_content: `
          <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #ffffff;">
            <div style="text-align: center; margin-bottom: 30px;">
              <h2 style="color: #059669; margin: 0; font-size: 24px;">Follow-up Discussion</h2>
              <p style="color: #6b7280; margin: 5px 0 0 0;">Ferreira CTO Consulting</p>
            </div>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              Hi {{first_name}},
            </p>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              I wanted to follow up on my previous email about technology consulting for {{company_name}}. 
            </p>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              I understand that as {{title}} at a {{funding_stage}} {{industry}} company, you're likely focused on scaling operations and preparing for future growth milestones.
            </p>
            
            <div style="background-color: #ecfdf5; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #059669;">
              <p style="color: #374151; line-height: 1.6; margin: 0;">
                <strong style="color: #065f46;">Quick question:</strong> What's your biggest technology challenge as you scale {{company_name}}? Whether it's infrastructure, regulatory compliance, or AI/ML pipelines, I'd be happy to share some quick insights from similar {{industry}} companies I've worked with.
              </p>
            </div>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 20px;">
              Even if you're not looking for external consulting right now, I find these conversations valuable for both parties - you get some free insights, and I stay current with industry challenges.
            </p>
            
            <p style="color: #374151; line-height: 1.6; margin-bottom: 30px;">
              No pressure at all - if the timing isn't right, I completely understand. Just thought I'd reach out one more time.
            </p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="https://calendly.com/peter-ferreira/15min" style="background-color: #059669; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: 500;">
                Quick 15-Minute Chat
              </a>
            </div>
            
            <div style="border-top: 2px solid #e5e7eb; padding-top: 20px; margin-top: 30px;">
              <p style="color: #374151; line-height: 1.6; margin-bottom: 5px;">
                Best regards,<br>
                <strong>Peter Ferreira</strong>
              </p>
              <p style="color: #6b7280; font-size: 14px; line-height: 1.4; margin: 0;">
                CTO Consultant • Technology Due Diligence<br>
                Ferreira CTO<br>
                📧 peter@ferreiracto.com<br>
                🌐 <a href="https://ferreiracto.com" style="color: #059669;">www.ferreiracto.com</a>
              </p>
            </div>
          </div>
        `,
        text_content: `Hi {{first_name}},

I wanted to follow up on my previous email about technology consulting for {{company_name}}.

I understand that as {{title}} at a {{funding_stage}} {{industry}} company, you're likely focused on scaling operations and preparing for future growth milestones.

Quick question: What's your biggest technology challenge as you scale {{company_name}}? Whether it's infrastructure, regulatory compliance, or AI/ML pipelines, I'd be happy to share some quick insights from similar {{industry}} companies I've worked with.

Even if you're not looking for external consulting right now, I find these conversations valuable for both parties - you get some free insights, and I stay current with industry challenges.

No pressure at all - if the timing isn't right, I completely understand. Just thought I'd reach out one more time.

Schedule a quick chat: https://calendly.com/peter-ferreira/15min

Best regards,
Peter Ferreira
CTO Consultant • Technology Due Diligence
Ferreira CTO
📧 peter@ferreiracto.com
🌐 www.ferreiracto.com`,
        variables: ['first_name', 'last_name', 'company_name', 'industry', 'funding_stage', 'title']
      }
    ]

    res.status(200).json({ 
      success: true,
      templates,
      count: templates.length 
    })

  } catch (error) {
    console.error('Templates API Error:', error)
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch templates',
      message: error.message 
    })
  }
}
