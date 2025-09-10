-- Email Campaigns Schema
CREATE TABLE email_campaigns (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  subject VARCHAR NOT NULL,
  from_name VARCHAR DEFAULT 'Peter Ferreira',
  from_email VARCHAR DEFAULT 'peter@ferreiracto.com',
  reply_to VARCHAR DEFAULT 'peter@ferreiracto.com',
  template_id UUID REFERENCES email_templates(id),
  status VARCHAR DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'sending', 'sent', 'paused', 'completed')),
  scheduled_at TIMESTAMP WITH TIME ZONE,
  sent_at TIMESTAMP WITH TIME ZONE,
  recipient_count INTEGER DEFAULT 0,
  sent_count INTEGER DEFAULT 0,
  delivered_count INTEGER DEFAULT 0,
  opened_count INTEGER DEFAULT 0,
  clicked_count INTEGER DEFAULT 0,
  replied_count INTEGER DEFAULT 0,
  unsubscribed_count INTEGER DEFAULT 0,
  bounced_count INTEGER DEFAULT 0,
  settings JSONB DEFAULT '{}',
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Email Templates
CREATE TABLE email_templates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  category VARCHAR DEFAULT 'outreach' CHECK (category IN ('outreach', 'followup', 'nurture', 'meeting', 'thank_you')),
  subject_template VARCHAR NOT NULL,
  html_content TEXT NOT NULL,
  text_content TEXT,
  variables JSONB DEFAULT '[]',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign Recipients (tracks individual sends)
CREATE TABLE campaign_recipients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  campaign_id UUID REFERENCES email_campaigns(id) ON DELETE CASCADE,
  contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
  email VARCHAR NOT NULL,
  status VARCHAR DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'opened', 'clicked', 'replied', 'bounced', 'unsubscribed')),
  sent_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  opened_at TIMESTAMP WITH TIME ZONE,
  clicked_at TIMESTAMP WITH TIME ZONE,
  replied_at TIMESTAMP WITH TIME ZONE,
  bounced_at TIMESTAMP WITH TIME ZONE,
  unsubscribed_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  personalized_subject VARCHAR,
  personalized_content TEXT,
  tracking_data JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Email Events (detailed tracking)
CREATE TABLE email_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  campaign_id UUID REFERENCES email_campaigns(id),
  recipient_id UUID REFERENCES campaign_recipients(id),
  contact_id UUID REFERENCES contacts(id),
  event_type VARCHAR NOT NULL CHECK (event_type IN ('sent', 'delivered', 'opened', 'clicked', 'replied', 'bounced', 'unsubscribed', 'spam')),
  event_data JSONB DEFAULT '{}',
  user_agent TEXT,
  ip_address INET,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Unsubscribe List
CREATE TABLE unsubscribe_list (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR UNIQUE NOT NULL,
  contact_id UUID REFERENCES contacts(id),
  reason VARCHAR,
  unsubscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign Segments (for targeting)
CREATE TABLE campaign_segments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT,
  filters JSONB NOT NULL,
  contact_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_email_campaigns_status ON email_campaigns(status);
CREATE INDEX idx_email_campaigns_scheduled ON email_campaigns(scheduled_at) WHERE status = 'scheduled';
CREATE INDEX idx_campaign_recipients_campaign ON campaign_recipients(campaign_id);
CREATE INDEX idx_campaign_recipients_contact ON campaign_recipients(contact_id);
CREATE INDEX idx_campaign_recipients_status ON campaign_recipients(status);
CREATE INDEX idx_email_events_campaign ON email_events(campaign_id);
CREATE INDEX idx_email_events_type ON email_events(event_type);
CREATE INDEX idx_email_events_created ON email_events(created_at);
CREATE INDEX idx_unsubscribe_email ON unsubscribe_list(email);

-- RLS Policies
ALTER TABLE email_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_recipients ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE unsubscribe_list ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_segments ENABLE ROW LEVEL SECURITY;

-- Insert default email templates
INSERT INTO email_templates (name, category, subject_template, html_content, text_content, variables) VALUES
('Biotech Introduction', 'outreach', 'Technology Due Diligence for {{company_name}}', 
'<!DOCTYPE html><html><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
<h2>Hi {{first_name}},</h2>
<p>I hope this email finds you well. I''m Peter Ferreira, CTO consultant specializing in technology due diligence for biotech companies like {{company_name}}.</p>
<p>I''ve been following {{company_name}}''s progress in {{industry}} and am impressed by your {{funding_stage}} growth. Companies at your stage often face complex technology challenges around:</p>
<ul>
  <li>Scalable cloud infrastructure for {{industry}} applications</li>
  <li>AI/ML pipeline optimization for research workflows</li>
  <li>Regulatory compliance and data management systems</li>
  <li>Strategic technology roadmap planning</li>
</ul>
<p>I help biotech CTOs and leadership teams navigate these challenges with hands-on expertise in AI, robotics, and SaaS platforms.</p>
<p>Would you be open to a brief 15-minute conversation about {{company_name}}''s technology priorities? I''d be happy to share some insights relevant to your {{industry}} focus.</p>
<p>Best regards,<br>Peter Ferreira<br>Ferreira CTO - Technology Due Diligence<br>peter@ferreiracto.com<br>www.ferreiracto.com</p>
</body></html>',
'Hi {{first_name}},

I hope this email finds you well. I''m Peter Ferreira, CTO consultant specializing in technology due diligence for biotech companies like {{company_name}}.

I''ve been following {{company_name}}''s progress in {{industry}} and am impressed by your {{funding_stage}} growth. Companies at your stage often face complex technology challenges around:

• Scalable cloud infrastructure for {{industry}} applications
• AI/ML pipeline optimization for research workflows  
• Regulatory compliance and data management systems
• Strategic technology roadmap planning

I help biotech CTOs and leadership teams navigate these challenges with hands-on expertise in AI, robotics, and SaaS platforms.

Would you be open to a brief 15-minute conversation about {{company_name}}''s technology priorities? I''d be happy to share some insights relevant to your {{industry}} focus.

Best regards,
Peter Ferreira
Ferreira CTO - Technology Due Diligence
peter@ferreiracto.com
www.ferreiracto.com',
'["first_name", "company_name", "industry", "funding_stage"]'),

('Follow-up Meeting', 'followup', 'Following up on {{company_name}} technology discussion', 
'<!DOCTYPE html><html><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
<h2>Hi {{first_name}},</h2>
<p>I wanted to follow up on my previous email about technology consulting for {{company_name}}.</p>
<p>Many {{industry}} companies at the {{funding_stage}} stage find value in having an experienced CTO consultant review their technology strategy, especially around:</p>
<ul>
  <li>Scaling challenges as your team grows</li>
  <li>Technology due diligence for investors</li>
  <li>AI/ML implementation for research acceleration</li>
  <li>Cloud infrastructure optimization</li>
</ul>
<p>Would you have 15 minutes this week for a brief call? I''d be happy to share some specific insights relevant to {{company_name}}''s focus in {{industry}}.</p>
<p>Best regards,<br>Peter Ferreira<br>Ferreira CTO</p>
</body></html>',
'Hi {{first_name}},

I wanted to follow up on my previous email about technology consulting for {{company_name}}.

Many {{industry}} companies at the {{funding_stage}} stage find value in having an experienced CTO consultant review their technology strategy, especially around:

• Scaling challenges as your team grows
• Technology due diligence for investors
• AI/ML implementation for research acceleration
• Cloud infrastructure optimization

Would you have 15 minutes this week for a brief call? I''d be happy to share some specific insights relevant to {{company_name}}''s focus in {{industry}}.

Best regards,
Peter Ferreira
Ferreira CTO',
'["first_name", "company_name", "industry", "funding_stage"]'),

('VC Partnership', 'outreach', 'Technology Due Diligence Partnership - {{vc_firm_name}}', 
'<!DOCTYPE html><html><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
<h2>Hi {{first_name}},</h2>
<p>I''m Peter Ferreira, a CTO consultant specializing in technology due diligence for biotech investments.</p>
<p>I''ve been following {{vc_firm_name}}''s impressive portfolio in {{focus_area}} and believe there could be strong synergy for technology due diligence services.</p>
<p>I provide independent technology assessments for VC firms, helping evaluate:</p>
<ul>
  <li>Technical feasibility and scalability of biotech platforms</li>
  <li>AI/ML implementation quality and potential</li>
  <li>Technology team strength and roadmap viability</li>
  <li>Infrastructure and security assessments</li>
</ul>
<p>My background includes hands-on experience with AI, robotics, and SaaS platforms, specifically in the biotech sector.</p>
<p>Would you be interested in discussing how technology due diligence could add value to {{vc_firm_name}}''s investment process?</p>
<p>Best regards,<br>Peter Ferreira<br>Ferreira CTO - Technology Due Diligence<br>peter@ferreiracto.com</p>
</body></html>',
'Hi {{first_name}},

I''m Peter Ferreira, a CTO consultant specializing in technology due diligence for biotech investments.

I''ve been following {{vc_firm_name}}''s impressive portfolio in {{focus_area}} and believe there could be strong synergy for technology due diligence services.

I provide independent technology assessments for VC firms, helping evaluate:

• Technical feasibility and scalability of biotech platforms
• AI/ML implementation quality and potential
• Technology team strength and roadmap viability
• Infrastructure and security assessments

My background includes hands-on experience with AI, robotics, and SaaS platforms, specifically in the biotech sector.

Would you be interested in discussing how technology due diligence could add value to {{vc_firm_name}}''s investment process?

Best regards,
Peter Ferreira
Ferreira CTO - Technology Due Diligence
peter@ferreiracto.com',
'["first_name", "vc_firm_name", "focus_area"]');
