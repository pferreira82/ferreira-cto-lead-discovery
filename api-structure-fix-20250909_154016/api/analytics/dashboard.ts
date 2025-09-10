import { NextApiRequest, NextApiResponse } from 'next'
import { createClient } from "@supabase/supabase-js"
import { isSupabaseConfigured } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET'])
    return res.status(405).end(`Method ${req.method} Not Allowed`)
  }

  // Debug logging
  console.log('=== Dashboard API Debug ===')
  console.log('Supabase URL configured:', !!supabaseUrl)
  console.log('Supabase Key configured:', !!supabaseKey)
  console.log('Environment check:', {
    NODE_ENV: process.env.NODE_ENV,
    hasUrl: !!supabaseUrl,
    hasKey: !!supabaseKey
  })

  try {
    // Check if we have Supabase credentials
    if (!supabaseUrl || !supabaseKey) {
      console.warn('⚠️  Supabase credentials not configured, returning mock data')
      const mockData = getMockData()
      return res.status(200).json({
        ...mockData,
        debug: {
          reason: 'missing_credentials',
          hasUrl: !!supabaseUrl,
          hasKey: !!supabaseKey
        }
      })
    }

    console.log('✅ Attempting Supabase connection...')
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Fetch dashboard stats from your existing schema
    const stats = await fetchDashboardStats(supabase)
    const charts = await fetchChartData(supabase)

    console.log('✅ Successfully fetched production data:', { 
      totalContacts: stats.totalContacts,
      totalCompanies: stats.totalCompanies 
    })

    res.status(200).json({ 
      stats, 
      charts,
      debug: {
        reason: 'production_data',
        timestamp: new Date().toISOString()
      }
    })
  } catch (error) {
    console.error('❌ Dashboard API Error:', error)
    
    // Return mock data as fallback
    const fallbackData = getMockData()
    res.status(200).json({
      ...fallbackData,
      debug: {
        reason: 'error_fallback',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      }
    })
  }
}

async function fetchDashboardStats(supabase: any) {
  try {
    console.log('📊 Fetching dashboard stats...')
    
    // Get total contacts
    const { count: totalContacts, error: contactsError } = await supabase
      .from('contacts')
      .select('*', { count: 'exact', head: true })

    if (contactsError) {
      console.error('Contacts query error:', contactsError)
      throw contactsError
    }

    // Get total companies
    const { count: totalCompanies, error: companiesError } = await supabase
      .from('companies')
      .select('*', { count: 'exact', head: true })

    if (companiesError) {
      console.error('Companies query error:', companiesError)
      throw companiesError
    }

    // Get contacts not yet contacted
    const { count: notContactedCount, error: notContactedError } = await supabase
      .from('contacts')
      .select('*', { count: 'exact', head: true })
      .eq('contact_status', 'not_contacted')

    if (notContactedError) {
      console.error('Not contacted query error:', notContactedError)
    }

    // Get emails sent (from your email_logs table)
    const { count: emailsSent, error: emailsError } = await supabase
      .from('email_logs')
      .select('*', { count: 'exact', head: true })

    if (emailsError) {
      console.error('Emails query error:', emailsError)
    }

    // Get emails sent this week
    const oneWeekAgo = new Date()
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7)
    
    const { count: contactedThisWeek, error: weekError } = await supabase
      .from('email_logs')
      .select('*', { count: 'exact', head: true })
      .gte('sent_at', oneWeekAgo.toISOString())

    if (weekError) {
      console.error('This week query error:', weekError)
    }

    // Calculate response rate using your email_logs table
    const { count: totalReplies, error: repliesError } = await supabase
      .from('email_logs')
      .select('*', { count: 'exact', head: true })
      .not('replied_at', 'is', null)

    if (repliesError) {
      console.error('Replies query error:', repliesError)
    }

    const responseRate = emailsSent > 0 ? ((totalReplies / emailsSent) * 100) : 0

    // Get active campaigns
    const { count: activeCampaigns, error: campaignsError } = await supabase
      .from('email_campaigns')
      .select('*', { count: 'exact', head: true })
      .eq('active', true)

    if (campaignsError) {
      console.error('Campaigns query error:', campaignsError)
    }

    // Calculate pipeline value (sum of company funding)
    const { data: companies, error: fundingError } = await supabase
      .from('companies')
      .select('total_funding')
      .not('total_funding', 'is', null)

    if (fundingError) {
      console.error('Funding query error:', fundingError)
    }

    const pipelineValue = companies?.reduce((sum: number, company: any) => 
      sum + (parseFloat(company.total_funding) || 0), 0) || 0

    const result = {
      totalContacts: totalContacts || 0,
      totalCompanies: totalCompanies || 0,
      emailsSent: emailsSent || 0,
      responseRate: Math.round(responseRate * 10) / 10,
      contactedThisWeek: contactedThisWeek || 0,
      notContactedCount: notContactedCount || 0,
      pipeline_value: pipelineValue,
      active_campaigns: activeCampaigns || 0
    }

    console.log('📈 Stats fetched:', result)
    return result
  } catch (error) {
    console.error('Error fetching dashboard stats:', error)
    throw error
  }
}

async function fetchChartData(supabase: any) {
  try {
    console.log('📊 Fetching chart data...')
    
    // Email activity for last 7 days using your email_logs table
    const emailActivity: Array<{date: string; sent: number; opened: number; replied: number}> = []
    for (let i = 6; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - i)
      const dateStr = date.toISOString().split('T')[0]
      
      const { count: sent } = await supabase
        .from('email_logs')
        .select('*', { count: 'exact', head: true })
        .gte('sent_at', `${dateStr}T00:00:00.000Z`)
        .lt('sent_at', `${dateStr}T23:59:59.999Z`)

      const { count: opened } = await supabase
        .from('email_logs')
        .select('*', { count: 'exact', head: true })
        .gte('opened_at', `${dateStr}T00:00:00.000Z`)
        .lt('opened_at', `${dateStr}T23:59:59.999Z`)
        .not('opened_at', 'is', null)

      const { count: replied } = await supabase
        .from('email_logs')
        .select('*', { count: 'exact', head: true })
        .gte('replied_at', `${dateStr}T00:00:00.000Z`)
        .lt('replied_at', `${dateStr}T23:59:59.999Z`)
        .not('replied_at', 'is', null)

      emailActivity.push({
        date: date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        sent: (sent as number) || 0,
        opened: (opened as number) || 0,
        replied: (replied as number) || 0
      })
    }

    // Contacts by role using your role_category field
    const { data: roleData, error: roleError } = await supabase
      .from('contacts')
      .select('role_category')
      .not('role_category', 'is', null)

    if (roleError) {
      console.error('Role data error:', roleError)
    }

    const roleCounts = roleData?.reduce((acc: any, contact: any) => {
      acc[contact.role_category] = (acc[contact.role_category] || 0) + 1
      return acc
    }, {}) || {}

    const contactsByRole = Object.entries(roleCounts).map(([role, count], index) => ({
      role,
      count: count as number,
      color: ['#3B82F6', '#8B5CF6', '#10B981', '#F59E0B', '#EF4444'][index % 5]
    }))

    // Companies by funding stage using your funding_stage field
    const { data: stageData, error: stageError } = await supabase
      .from('companies')
      .select('funding_stage')
      .not('funding_stage', 'is', null)

    if (stageError) {
      console.error('Stage data error:', stageError)
    }

    const stageCounts = stageData?.reduce((acc: any, company: any) => {
      acc[company.funding_stage] = (acc[company.funding_stage] || 0) + 1
      return acc
    }, {}) || {}

    const companiesByStage = Object.entries(stageCounts).map(([stage, count]) => ({
      stage,
      count: count as number
    }))

    const result = {
      emailActivity,
      contactsByRole,
      companiesByStage
    }

    console.log('📊 Chart data fetched:', {
      emailActivityDays: emailActivity.length,
      roleCount: contactsByRole.length,
      stageCount: companiesByStage.length
    })

    return result
  } catch (error) {
    console.error('Error fetching chart data:', error)
    throw error
  }
}

function getMockData() {
  return {
    stats: {
      totalContacts: 1247,
      totalCompanies: 186,
      emailsSent: 892,
      responseRate: 23.5,
      contactedThisWeek: 47,
      notContactedCount: 723,
      pipeline_value: 2400000,
      active_campaigns: 5
    },
    charts: {
      emailActivity: [
        { date: 'Sep 1', sent: 45, opened: 25, replied: 6 },
        { date: 'Sep 2', sent: 52, opened: 30, replied: 8 },
        { date: 'Sep 3', sent: 48, opened: 22, replied: 5 },
        { date: 'Sep 4', sent: 61, opened: 35, replied: 12 },
        { date: 'Sep 5', sent: 55, opened: 28, replied: 9 },
        { date: 'Sep 6', sent: 47, opened: 20, replied: 4 },
        { date: 'Sep 7', sent: 38, opened: 15, replied: 3 },
      ],
      contactsByRole: [
        { role: 'Founder', count: 45, color: '#3B82F6' },
        { role: 'Executive', count: 67, color: '#8B5CF6' },
        { role: 'VC', count: 23, color: '#10B981' },
        { role: 'Board Member', count: 18, color: '#F59E0B' },
      ],
      companiesByStage: [
        { stage: 'Series A', count: 75 },
        { stage: 'Series B', count: 64 },
        { stage: 'Series C', count: 47 },
      ]
    }
  }
}
