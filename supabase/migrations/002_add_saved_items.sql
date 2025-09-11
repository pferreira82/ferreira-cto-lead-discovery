-- Create saved_items table to track what users have saved from discovery
CREATE TABLE IF NOT EXISTS saved_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    item_type TEXT NOT NULL CHECK (item_type IN ('company', 'contact', 'vc')),
    
    -- References to existing tables
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    
    -- For VCs that might not be in companies table yet
    vc_data JSONB, -- Store VC data if not in existing schema
    
    -- Discovery metadata
    ai_score INTEGER,
    discovery_source TEXT DEFAULT 'apollo_search',
    search_criteria JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_saved_items_user_id ON saved_items(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_items_type ON saved_items(item_type);
CREATE INDEX IF NOT EXISTS idx_saved_items_company_id ON saved_items(company_id);
CREATE INDEX IF NOT EXISTS idx_saved_items_contact_id ON saved_items(contact_id);

-- Enable RLS
ALTER TABLE saved_items ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own saved items" ON saved_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own saved items" ON saved_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own saved items" ON saved_items
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own saved items" ON saved_items
    FOR DELETE USING (auth.uid() = user_id);

-- Create trigger for updated_at
CREATE TRIGGER update_saved_items_updated_at 
    BEFORE UPDATE ON saved_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add saved_at column to existing tables (optional, for tracking when discovered)
ALTER TABLE companies ADD COLUMN IF NOT EXISTS discovered_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE companies ADD COLUMN IF NOT EXISTS ai_score INTEGER;
ALTER TABLE contacts ADD COLUMN IF NOT EXISTS discovered_at TIMESTAMP WITH TIME ZONE;

-- Add indexes for new columns
CREATE INDEX IF NOT EXISTS idx_companies_ai_score ON companies(ai_score);
CREATE INDEX IF NOT EXISTS idx_companies_discovered_at ON companies(discovered_at);
