-- Add missing columns to email_campaigns table
ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS exclude_contacted BOOLEAN DEFAULT true;

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS target_types TEXT[] DEFAULT '{"companies"}';

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS industries TEXT[] DEFAULT '{}';

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS funding_stages TEXT[] DEFAULT '{}';

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS role_categories TEXT[] DEFAULT '{}';

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS locations TEXT[] DEFAULT '{}';

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS vc_focus_areas TEXT[] DEFAULT '{}';

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS max_results INTEGER DEFAULT 100;

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS company_size_min INTEGER DEFAULT NULL;

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS company_size_max INTEGER DEFAULT NULL;

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS funding_range_min BIGINT DEFAULT NULL;

ALTER TABLE email_campaigns 
ADD COLUMN IF NOT EXISTS funding_range_max BIGINT DEFAULT NULL;

-- Update the status constraint to include new statuses
ALTER TABLE email_campaigns DROP CONSTRAINT IF EXISTS email_campaigns_status_check;
ALTER TABLE email_campaigns ADD CONSTRAINT email_campaigns_status_check 
CHECK (status IN ('draft', 'scheduled', 'sending', 'sent', 'paused', 'completed', 'failed'));

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_email_campaigns_status ON email_campaigns(status);
CREATE INDEX IF NOT EXISTS idx_email_campaigns_created_at ON email_campaigns(created_at);
CREATE INDEX IF NOT EXISTS idx_email_campaigns_template_id ON email_campaigns(template_id);
