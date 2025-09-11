-- Add discovery-related columns to your existing companies table
ALTER TABLE companies ADD COLUMN IF NOT EXISTS ai_score INTEGER;
ALTER TABLE companies ADD COLUMN IF NOT EXISTS discovered_at TIMESTAMP WITH TIME ZONE;

-- Add discovery-related columns to your existing contacts table  
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS discovered_at TIMESTAMP WITH TIME ZONE;

-- Create indexes for the new columns
CREATE INDEX IF NOT EXISTS idx_companies_ai_score ON companies(ai_score);
CREATE INDEX IF NOT EXISTS idx_companies_discovered_at ON companies(discovered_at);
CREATE INDEX IF NOT EXISTS idx_contacts_discovered_at ON contacts(discovered_at);

-- Create a simple saved_selections table to track what you've saved from discovery
-- This table just tracks which companies/contacts you've "saved" without duplicating data
CREATE TABLE IF NOT EXISTS saved_selections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    selection_type TEXT NOT NULL CHECK (selection_type IN ('company', 'contact', 'vc')),
    
    -- References to existing tables
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    
    -- For VCs that don't fit in companies table
    vc_data JSONB,
    
    -- Discovery metadata
    discovery_source TEXT DEFAULT 'apollo_search',
    search_criteria JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for saved_selections
CREATE INDEX IF NOT EXISTS idx_saved_selections_type ON saved_selections(selection_type);
CREATE INDEX IF NOT EXISTS idx_saved_selections_company_id ON saved_selections(company_id);
CREATE INDEX IF NOT EXISTS idx_saved_selections_contact_id ON saved_selections(contact_id);

-- Enable RLS on saved_selections (keep existing tables' RLS as is)
ALTER TABLE saved_selections ENABLE ROW LEVEL SECURITY;

-- Create permissive policy for development (no auth required for now)
CREATE POLICY "Allow all operations on saved_selections for development" ON saved_selections
    FOR ALL USING (true) WITH CHECK (true);

-- Create trigger for updated_at on saved_selections
CREATE TRIGGER update_saved_selections_updated_at 
    BEFORE UPDATE ON saved_selections 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
