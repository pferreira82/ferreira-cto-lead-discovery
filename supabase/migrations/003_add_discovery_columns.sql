-- Add discovery-related columns to existing companies table
ALTER TABLE companies ADD COLUMN IF NOT EXISTS ai_score INTEGER;
ALTER TABLE companies ADD COLUMN IF NOT EXISTS discovered_at TIMESTAMP WITH TIME ZONE;

-- Add discovery-related columns to existing contacts table  
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS discovered_at TIMESTAMP WITH TIME ZONE;

-- Create indexes for the new columns
CREATE INDEX IF NOT EXISTS idx_companies_ai_score ON companies(ai_score);
CREATE INDEX IF NOT EXISTS idx_companies_discovered_at ON companies(discovered_at);
CREATE INDEX IF NOT EXISTS idx_contacts_discovered_at ON contacts(discovered_at);

-- Update RLS policies to ensure they work with new columns
-- No changes needed since policies are already permissive for authenticated users
