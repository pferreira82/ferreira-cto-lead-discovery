import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

// Check if Supabase is properly configured
export function isSupabaseConfigured(): boolean {
  return !!(supabaseUrl && supabaseAnonKey && 
    supabaseUrl !== 'undefined' && 
    supabaseAnonKey !== 'undefined' &&
    supabaseUrl.startsWith('http'))
}

// Client-side Supabase client
export const supabase = isSupabaseConfigured() 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null

// For server-side operations
export function createServiceRoleClient() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  
  if (!serviceRoleKey || !supabaseUrl) {
    return null
  }
  
  return createClient(supabaseUrl, serviceRoleKey)
}

// Server-side client for API routes
export const supabaseAdmin = createServiceRoleClient()

// Database Types based on your existing schema
export interface Company {
  id: string
  name: string
  website?: string
  industry?: string
  funding_stage?: 'Series A' | 'Series B' | 'Series C'
  location?: string
  description?: string
  total_funding?: number
  last_funding_date?: string
  employee_count?: number
  crunchbase_url?: string
  linkedin_url?: string
  ai_score?: number
  discovered_at?: string
  created_at: string
  updated_at: string
}

export interface Contact {
  id: string
  company_id?: string
  first_name: string
  last_name: string
  email?: string
  phone?: string
  title?: string
  role_category?: 'VC' | 'Founder' | 'Board Member' | 'Executive'
  linkedin_url?: string
  address?: string
  bio?: string
  contact_status?: 'not_contacted' | 'contacted' | 'responded' | 'interested' | 'not_interested'
  last_contacted_at?: string
  discovered_at?: string
  created_at: string
  updated_at: string
}

export interface SavedItem {
  id: string
  user_id: string
  item_type: 'company' | 'contact' | 'vc'
  company_id?: string
  contact_id?: string
  vc_data?: any
  ai_score?: number
  discovery_source?: string
  search_criteria?: any
  created_at: string
  updated_at: string
}
