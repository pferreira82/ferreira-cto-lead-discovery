-- Optional enhancements to your existing schema
-- Run these if you want additional functionality

-- Add some helpful indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_email_logs_status ON email_logs(status);
CREATE INDEX IF NOT EXISTS idx_email_logs_campaign_id ON email_logs(campaign_id);
CREATE INDEX IF NOT EXISTS idx_companies_total_funding ON companies(total_funding);

-- Add a simple system settings table for storing app configuration
CREATE TABLE IF NOT EXISTS app_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    setting_key VARCHAR UNIQUE NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for the new table
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable all operations for authenticated users" ON app_settings FOR ALL USING (auth.role() = 'authenticated');

-- Insert some useful settings
INSERT INTO app_settings (setting_key, setting_value) VALUES 
('last_data_refresh', NOW()::text),
('app_version', '1.0.0'),
('demo_mode', 'false')
ON CONFLICT (setting_key) DO NOTHING;

-- Create trigger for app_settings updated_at
CREATE TRIGGER update_app_settings_updated_at 
    BEFORE UPDATE ON app_settings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
