-- Add apollo_id columns to track API IDs and prevent duplicates
ALTER TABLE companies ADD COLUMN IF NOT EXISTS apollo_id TEXT;
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS apollo_id TEXT;

-- Create indexes for apollo_id lookups
CREATE INDEX IF NOT EXISTS idx_companies_apollo_id ON companies(apollo_id);
CREATE INDEX IF NOT EXISTS idx_contacts_apollo_id ON contacts(apollo_id);

-- Create unique constraints to prevent duplicate Apollo IDs
-- Use partial indexes to allow NULL values but ensure uniqueness for non-NULL values
CREATE UNIQUE INDEX IF NOT EXISTS unique_companies_apollo_id 
    ON companies(apollo_id) WHERE apollo_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS unique_contacts_apollo_id 
    ON contacts(apollo_id) WHERE apollo_id IS NOT NULL;
