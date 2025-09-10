#!/bin/bash

echo "🔧 Fixing React Hot Toast Info Method Error..."
echo "=============================================="

# The issue is that toast.info() doesn't exist in react-hot-toast
# Let's fix all instances by replacing with toast() or toast.success()

# 1. Fix the campaign creation dialog
echo "📧 Fixing campaign creation dialog toast calls..."
cat > components/email/campaign-creation-dialog.tsx << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Checkbox } from '@/components/ui/checkbox'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { 
  Mail, 
  Users, 
  Calendar,
  Eye,
  Send,
  Save,
  Target,
  FileText,
  Settings,
  Clock,
  Building,
  Briefcase,
  Filter,
  Play,
  X,
  TestTube,
  Globe
} from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { toast } from 'react-hot-toast'

interface EmailTemplate {
  id: string
  name: string
  category: string
  subject_template: string
  html_content: string
  text_content: string
  variables: string[]
}

interface CampaignFormData {
  name: string
  subject: string
  template_id: string
  from_name: string
  from_email: string
  reply_to: string
  target_types: ('companies' | 'vc_firms')[]
  industries: string[]
  funding_stages: string[]
  role_categories: string[]
  locations: string[]
  exclude_contacted: boolean
  schedule_type: 'now' | 'scheduled'
  scheduled_at?: string
  custom_content?: string
}

const DEMO_TEMPLATES: EmailTemplate[] = [
  {
    id: 'demo-template-1',
    name: 'Biotech CTO Introduction',
    category: 'outreach',
    subject_template: 'Technology Due Diligence for {{company_name}}',
    html_content: `<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: white; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
      <div style="background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%); color: white; padding: 20px; text-align: center;">
        <h1 style="margin: 0; font-size: 24px; font-weight: bold;">Ferreira CTO</h1>
        <p style="margin: 5px 0 0 0; opacity: 0.9;">Technology Due Diligence & Strategic Consulting</p>
      </div>
      <div style="padding: 30px; line-height: 1.6; color: #374151;">
        <p>Hi {{first_name}},</p>
        
        <p>I hope this email finds you well. I am <strong>Peter Ferreira</strong>, CTO consultant specializing in technology due diligence for biotech companies like <strong>{{company_name}}</strong>.</p>
        
        <p>I have been following {{company_name}}'s progress in <strong>{{industry}}</strong> and am impressed by your {{funding_stage}} growth. Companies at your stage often face complex technology challenges around:</p>
        
        <ul style="margin: 20px 0; padding-left: 20px;">
          <li style="margin-bottom: 8px;">🚀 <strong>Scalable cloud infrastructure</strong> for {{industry}} applications</li>
          <li style="margin-bottom: 8px;">🤖 <strong>AI/ML pipeline optimization</strong> for research workflows</li>
          <li style="margin-bottom: 8px;">📊 <strong>Regulatory compliance</strong> and data management systems</li>
          <li style="margin-bottom: 8px;">🎯 <strong>Strategic technology roadmap</strong> planning for rapid scaling</li>
        </ul>
        
        <p>I help biotech CTOs and leadership teams navigate these challenges with hands-on expertise in:</p>
        
        <div style="background: #F3F4F6; padding: 20px; border-radius: 6px; margin: 20px 0;">
          <p style="margin: 0 0 10px 0; font-weight: bold; color: #1F2937;">Technical Expertise:</p>
          <p style="margin: 0; color: #4B5563;">AI/ML • Cloud Architecture • SaaS Platforms • Regulatory Tech • Data Infrastructure</p>
        </div>
        
        <p>Would you be open to a brief <strong>15-minute conversation</strong> about {{company_name}}'s technology priorities? I'd be happy to share some insights relevant to your {{industry}} focus.</p>
        
        <div style="text-align: center; margin: 30px 0;">
          <a href="mailto:peter@ferreiracto.com" style="display: inline-block; background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%); color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold;">Schedule a Brief Call</a>
        </div>
        
        <p>Best regards,</p>
        <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #E5E7EB;">
          <p style="margin: 0; font-weight: bold; color: #1F2937;">Peter Ferreira</p>
          <p style="margin: 5px 0 0 0; color: #6B7280;">CTO Consultant • Technology Due Diligence</p>
          <p style="margin: 5px 0 0 0; color: #6B7280;">📧 peter@ferreiracto.com • 🌐 www.ferreiracto.com</p>
        </div>
      </div>
    </div>`,
    text_content: `Hi {{first_name}},

I hope this email finds you well. I am Peter Ferreira, CTO consultant specializing in technology due diligence for biotech companies like {{company_name}}.

I have been following {{company_name}}'s progress in {{industry}} and am impressed by your {{funding_stage}} growth. Companies at your stage often face complex technology challenges around:

• Scalable cloud infrastructure for {{industry}} applications
• AI/ML pipeline optimization for research workflows  
• Regulatory compliance and data management systems
• Strategic technology roadmap planning for rapid scaling

I help biotech CTOs and leadership teams navigate these challenges with hands-on expertise in AI, cloud architecture, SaaS platforms, regulatory tech, and data infrastructure.

Would you be open to a brief 15-minute conversation about {{company_name}}'s technology priorities? I'd be happy to share some insights relevant to your {{industry}} focus.

Best regards,
Peter Ferreira
CTO Consultant • Technology Due Diligence
peter@ferreiracto.com
www.ferreiracto.com`,
    variables: ['first_name', 'company_name', 'industry', 'funding_stage']
  },
  {
    id: 'demo-template-2',
    name: 'VC Partnership Proposal',
    category: 'outreach',
    subject_template: 'Technology Due Diligence Partnership - {{vc_firm_name}}',
    html_content: `<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: white; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
      <div style="background: linear-gradient(135deg, #8B5CF6 0%, #3B82F6 100%); color: white; padding: 20px; text-align: center;">
        <h1 style="margin: 0; font-size: 24px; font-weight: bold;">Strategic Partnership Opportunity</h1>
        <p style="margin: 5px 0 0 0; opacity: 0.9;">Technology Due Diligence for Biotech Investments</p>
      </div>
      <div style="padding: 30px; line-height: 1.6; color: #374151;">
        <p>Hi {{first_name}},</p>
        
        <p>I am <strong>Peter Ferreira</strong>, a CTO consultant specializing in technology due diligence for biotech investments. I've been following <strong>{{vc_firm_name}}</strong>'s impressive portfolio in {{focus_area}} and believe there's a strong alignment for collaboration.</p>
        
        <div style="background: #F0F9FF; border-left: 4px solid #3B82F6; padding: 20px; margin: 25px 0;">
          <p style="margin: 0 0 15px 0; font-weight: bold; color: #1E40AF;">Why Partner with Ferreira CTO?</p>
          <ul style="margin: 0; padding-left: 20px;">
            <li style="margin-bottom: 8px;">Deep technical expertise in biotech technology stacks</li>
            <li style="margin-bottom: 8px;">Proven track record in Series A-C company assessments</li>
            <li style="margin-bottom: 8px;">Rapid turnaround on due diligence reports (48-72 hours)</li>
            <li style="margin-bottom: 8px;">Post-investment technology consulting for portfolio companies</li>
          </ul>
        </div>
        
        <p><strong>Services for {{vc_firm_name}}:</strong></p>
        <ul style="margin: 15px 0 25px 20px;">
          <li style="margin-bottom: 8px;">🔬 <strong>Technology Due Diligence:</strong> Comprehensive technical assessments</li>
          <li style="margin-bottom: 8px;">📊 <strong>Portfolio Support:</strong> Ongoing CTO consulting for investments</li>
          <li style="margin-bottom: 8px;">🚀 <strong>Scaling Advisory:</strong> Technology roadmaps for rapid growth</li>
          <li style="margin-bottom: 8px;">🤖 <strong>AI/ML Evaluation:</strong> Assessment of machine learning implementations</li>
        </ul>
        
        <p>I'd welcome the opportunity to discuss how we can support {{vc_firm_name}}'s investment process and portfolio company success.</p>
        
        <div style="text-align: center; margin: 30px 0;">
          <a href="mailto:peter@ferreiracto.com" style="display: inline-block; background: linear-gradient(135deg, #8B5CF6 0%, #3B82F6 100%); color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold;">Schedule Partnership Discussion</a>
        </div>
        
        <p>Best regards,</p>
        <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #E5E7EB;">
          <p style="margin: 0; font-weight: bold; color: #1F2937;">Peter Ferreira</p>
          <p style="margin: 5px 0 0 0; color: #6B7280;">CTO Consultant • Biotech Investment Due Diligence</p>
          <p style="margin: 5px 0 0 0; color: #6B7280;">📧 peter@ferreiracto.com • 🌐 www.ferreiracto.com</p>
        </div>
      </div>
    </div>`,
    text_content: `Hi {{first_name}},

I am Peter Ferreira, a CTO consultant specializing in technology due diligence for biotech investments. I've been following {{vc_firm_name}}'s impressive portfolio in {{focus_area}} and believe there's a strong alignment for collaboration.

Why Partner with Ferreira CTO?
• Deep technical expertise in biotech technology stacks
• Proven track record in Series A-C company assessments  
• Rapid turnaround on due diligence reports (48-72 hours)
• Post-investment technology consulting for portfolio companies

Services for {{vc_firm_name}}:
• Technology Due Diligence: Comprehensive technical assessments
• Portfolio Support: Ongoing CTO consulting for investments
• Scaling Advisory: Technology roadmaps for rapid growth
• AI/ML Evaluation: Assessment of machine learning implementations

I'd welcome the opportunity to discuss how we can support {{vc_firm_name}}'s investment process and portfolio company success.

Best regards,
Peter Ferreira
CTO Consultant • Biotech Investment Due Diligence
peter@ferreiracto.com
www.ferreiracto.com`,
    variables: ['first_name', 'vc_firm_name', 'focus_area']
  },
  {
    id: 'demo-template-3',
    name: 'Follow-up Meeting Request',
    category: 'followup',
    subject_template: 'Following up on {{company_name}} technology discussion',
    html_content: `<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: white; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
      <div style="background: linear-gradient(135deg, #10B981 0%, #059669 100%); color: white; padding: 20px; text-align: center;">
        <h1 style="margin: 0; font-size: 24px; font-weight: bold;">Follow-up Discussion</h1>
        <p style="margin: 5px 0 0 0; opacity: 0.9;">Technology Consulting for {{company_name}}</p>
      </div>
      <div style="padding: 30px; line-height: 1.6; color: #374151;">
        <p>Hi {{first_name}},</p>
        
        <p>I wanted to follow up on my previous email about technology consulting for <strong>{{company_name}}</strong>. I understand how busy things can get in the {{industry}} space, especially during {{funding_stage}} scaling.</p>
        
        <div style="background: #F0FDF4; border-left: 4px solid #10B981; padding: 20px; margin: 25px 0;">
          <p style="margin: 0 0 15px 0; font-weight: bold; color: #065F46;">Quick Value Proposition:</p>
          <p style="margin: 0;">I help {{funding_stage}} biotech companies like {{company_name}} navigate critical technology decisions without the overhead of a full-time CTO hire. Think of it as "CTO-as-a-Service" for strategic technology initiatives.</p>
        </div>
        
        <p><strong>Immediate areas where I can help {{company_name}}:</strong></p>
        <ul style="margin: 15px 0 25px 20px;">
          <li style="margin-bottom: 8px;">⚡ <strong>Technology Assessment:</strong> Audit current systems and identify scaling bottlenecks</li>
          <li style="margin-bottom: 8px;">📈 <strong>Growth Planning:</strong> Technology roadmap for next 12-18 months</li>
          <li style="margin-bottom: 8px;">🔒 <strong>Compliance Review:</strong> Ensure regulatory and security requirements are met</li>
          <li style="margin-bottom: 8px;">🎯 <strong>Vendor Selection:</strong> Choose the right technology partners and platforms</li>
        </ul>
        
        <p>Rather than another lengthy meeting, how about a <strong>quick 10-minute call</strong> this week? I can share 2-3 specific insights relevant to {{industry}} companies at your stage, with no strings attached.</p>
        
        <div style="text-align: center; margin: 30px 0;">
          <a href="mailto:peter@ferreiracto.com" style="display: inline-block; background: linear-gradient(135deg, #10B981 0%, #059669 100%); color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold;">Grab 10 Minutes This Week</a>
        </div>
        
        <p>Thanks for your time, {{first_name}}.</p>
        
        <p>Best regards,</p>
        <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #E5E7EB;">
          <p style="margin: 0; font-weight: bold; color: #1F2937;">Peter Ferreira</p>
          <p style="margin: 5px 0 0 0; color: #6B7280;">CTO Consultant • {{industry}} Technology Advisory</p>
          <p style="margin: 5px 0 0 0; color: #6B7280;">📧 peter@ferreiracto.com • 🌐 www.ferreiracto.com</p>
        </div>
      </div>
    </div>`,
    text_content: `Hi {{first_name}},

I wanted to follow up on my previous email about technology consulting for {{company_name}}. I understand how busy things can get in the {{industry}} space, especially during {{funding_stage}} scaling.

Quick Value Proposition:
I help {{funding_stage}} biotech companies like {{company_name}} navigate critical technology decisions without the overhead of a full-time CTO hire. Think of it as "CTO-as-a-Service" for strategic technology initiatives.

Immediate areas where I can help {{company_name}}:
• Technology Assessment: Audit current systems and identify scaling bottlenecks
• Growth Planning: Technology roadmap for next 12-18 months  
• Compliance Review: Ensure regulatory and security requirements are met
• Vendor Selection: Choose the right technology partners and platforms

Rather than another lengthy meeting, how about a quick 10-minute call this week? I can share 2-3 specific insights relevant to {{industry}} companies at your stage, with no strings attached.

Thanks for your time, {{first_name}}.

Best regards,
Peter Ferreira
CTO Consultant • {{industry}} Technology Advisory
peter@ferreiracto.com
www.ferreiracto.com`,
    variables: ['first_name', 'company_name', 'industry', 'funding_stage']
  }
]

const INDUSTRIES = [
  'Biotechnology', 'Gene Therapy', 'Neurotechnology', 'Medical Devices',
  'Pharmaceuticals', 'Diagnostics', 'Synthetic Biology', 'Cell Therapy',
  'Genomics', 'AI Drug Discovery', 'Digital Health', 'Biomanufacturing'
]

const FUNDING_STAGES = [
  'Seed', 'Series A', 'Series B', 'Series C', 'Series D+', 'Growth', 'Public'
]

const ROLE_CATEGORIES = ['VC', 'Founder', 'Board Member', 'Executive']

const LOCATIONS = [
  'United States', 'Canada', 'United Kingdom', 'Portugal', 'Germany', 
  'France', 'Switzerland', 'Netherlands', 'Sweden'
]

interface CampaignCreationDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onCampaignCreated?: () => void
}

export function CampaignCreationDialog({ 
  open, 
  onOpenChange, 
  onCampaignCreated 
}: CampaignCreationDialogProps) {
  const { isDemoMode } = useDemoMode()
  const [activeTab, setActiveTab] = useState('details')
  const [templates, setTemplates] = useState<EmailTemplate[]>([])
  const [selectedTemplate, setSelectedTemplate] = useState<EmailTemplate | null>(null)
  const [estimatedRecipients, setEstimatedRecipients] = useState(0)
  const [isCreating, setIsCreating] = useState(false)
  const [showPreviewDialog, setShowPreviewDialog] = useState(false)
  const [previewContent, setPreviewContent] = useState('')
  const [isTesting, setIsTesting] = useState(false)
  
  const [formData, setFormData] = useState<CampaignFormData>({
    name: '',
    subject: '',
    template_id: '',
    from_name: 'Peter Ferreira',
    from_email: 'peter@ferreiracto.com',
    reply_to: 'peter@ferreiracto.com',
    target_types: ['companies'],
    industries: ['Biotechnology', 'Gene Therapy'],
    funding_stages: ['Series A', 'Series B', 'Series C'],
    role_categories: ['Founder', 'Executive'],
    locations: ['United States', 'Canada', 'United Kingdom'],
    exclude_contacted: true,
    schedule_type: 'now'
  })

  useEffect(() => {
    if (open) {
      loadTemplates()
      estimateRecipients()
    }
  }, [open, isDemoMode])

  useEffect(() => {
    estimateRecipients()
  }, [formData.target_types, formData.industries, formData.funding_stages, formData.role_categories, formData.locations])

  const loadTemplates = async () => {
    try {
      if (isDemoMode) {
        setTemplates(DEMO_TEMPLATES)
        return
      }

      const response = await fetch('/api/templates')
      if (response.ok) {
        const data = await response.json()
        setTemplates(data.templates || [])
      } else {
        setTemplates(DEMO_TEMPLATES)
      }
    } catch (error) {
      console.error('Error loading templates:', error)
      setTemplates(DEMO_TEMPLATES)
    }
  }

  const estimateRecipients = async () => {
    try {
      if (isDemoMode) {
        let estimate = 50
        if (formData.target_types.includes('vc_firms')) estimate += 15
        if (formData.industries.length > 3) estimate += 25
        if (formData.locations.length > 2) estimate += 30
        setEstimatedRecipients(Math.min(estimate, 150))
        return
      }

      const response = await fetch('/api/campaigns/estimate-recipients', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          target_types: formData.target_types,
          industries: formData.industries,
          funding_stages: formData.funding_stages,
          role_categories: formData.role_categories,
          locations: formData.locations,
          exclude_contacted: formData.exclude_contacted
        })
      })

      if (response.ok) {
        const data = await response.json()
        setEstimatedRecipients(data.count || 0)
      }
    } catch (error) {
      console.error('Error estimating recipients:', error)
    }
  }

  const handleTemplateSelect = (templateId: string) => {
    const template = templates.find(t => t.id === templateId)
    if (template) {
      setSelectedTemplate(template)
      setFormData(prev => ({
        ...prev,
        template_id: templateId,
        subject: template.subject_template,
        name: prev.name || `${template.name} Campaign - ${new Date().toLocaleDateString()}`
      }))
    }
  }

  const handlePreviewEmail = () => {
    if (!selectedTemplate) {
      toast.error('Please select a template first')
      return
    }

    // Create a preview with sample data
    let preview = selectedTemplate.html_content
    const sampleData = {
      first_name: 'Sarah',
      last_name: 'Chen',
      company_name: 'BioTech Innovations',
      industry: 'Biotechnology',
      funding_stage: 'Series B',
      vc_firm_name: 'Andreessen Horowitz Bio Fund',
      focus_area: 'Biotechnology and Digital Health'
    }

    // Replace variables with sample data
    Object.entries(sampleData).forEach(([key, value]) => {
      const regex = new RegExp(`{{${key}}}`, 'g')
      preview = preview.replace(regex, value)
    })

    setPreviewContent(preview)
    setShowPreviewDialog(true)
  }

  const handleTestEmail = async () => {
    if (!selectedTemplate || !formData.from_email) {
      toast.error('Please select a template and configure sender email')
      return
    }

    setIsTesting(true)
    try {
      if (isDemoMode) {
        // Simulate email testing in demo mode
        await new Promise(resolve => setTimeout(resolve, 2000))
        toast.success('Demo: Test email sent successfully! Check your inbox.')
        // Using regular toast instead of toast.info
        toast('Demo Mode: No actual email was sent. This is a simulation.', {
          icon: 'ℹ️',
          style: {
            background: '#3B82F6',
            color: 'white',
          }
        })
      } else {
        // In production, send actual test email
        const response = await fetch('/api/email/test', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            template_id: formData.template_id,
            to_email: formData.from_email, // Send test to sender's own email
            from_name: formData.from_name,
            from_email: formData.from_email,
            subject: formData.subject
          })
        })

        if (response.ok) {
          toast.success('Test email sent successfully! Check your inbox.')
        } else {
          throw new Error('Failed to send test email')
        }
      }
    } catch (error) {
      console.error('Test email error:', error)
      toast.error('Failed to send test email')
    } finally {
      setIsTesting(false)
    }
  }

  const handleCreateCampaign = async () => {
    if (!formData.name.trim()) {
      toast.error('Please enter a campaign name')
      return
    }
    if (!formData.template_id) {
      toast.error('Please select an email template')
      return
    }
    if (estimatedRecipients === 0) {
      toast.error('No recipients match your targeting criteria')
      return
    }

    setIsCreating(true)
    try {
      if (isDemoMode) {
        await new Promise(resolve => setTimeout(resolve, 2000))
        toast.success(`Demo: Created "${formData.name}" campaign targeting ${estimatedRecipients} recipients`)
        // Using regular toast instead of toast.info
        toast('Demo Mode: No actual emails sent. Campaign saved for testing.', {
          icon: 'ℹ️',
          style: {
            background: '#3B82F6',
            color: 'white',
          }
        })
      } else {
        const response = await fetch('/api/campaigns', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            ...formData,
            status: formData.schedule_type === 'now' ? 'sending' : 'scheduled'
          })
        })

        if (response.ok) {
          const campaign = await response.json()
          toast.success(`Created "${formData.name}" campaign successfully`)
        } else {
          throw new Error('Failed to create campaign')
        }
      }
      
      onCampaignCreated?.()
      onOpenChange(false)
      
      // Reset form
      setFormData(prev => ({
        ...prev,
        name: '',
        subject: '',
        template_id: ''
      }))
      setSelectedTemplate(null)
    } catch (error) {
      console.error('Error creating campaign:', error)
      toast.error('Failed to create campaign')
    } finally {
      setIsCreating(false)
    }
  }

  // Simple tab navigation
  const TabButton = ({ value, label, icon: Icon, isActive, onClick }) => (
    <button
      onClick={onClick}
      className={`flex items-center space-x-2 px-4 py-2 rounded-md text-sm font-medium transition-colors ${
        isActive 
          ? 'bg-blue-100 text-blue-700 border-blue-200' 
          : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
      }`}
    >
      <Icon className="w-4 h-4" />
      <span>{label}</span>
    </button>
  )

  return (
    <>
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent className="max-w-6xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center space-x-2">
              <Mail className="w-5 h-5" />
              <span>Create Email Campaign</span>
              {isDemoMode && (
                <Badge className="bg-blue-100 text-blue-800">Demo Mode</Badge>
              )}
            </DialogTitle>
            <DialogDescription>
              Create a targeted email campaign for biotech outreach
            </DialogDescription>
          </DialogHeader>

          {/* Tab Navigation */}
          <div className="flex space-x-2 border-b">
            <TabButton 
              value="details" 
              label="Details" 
              icon={Settings}
              isActive={activeTab === 'details'}
              onClick={() => setActiveTab('details')}
            />
            <TabButton 
              value="template" 
              label="Template" 
              icon={FileText}
              isActive={activeTab === 'template'}
              onClick={() => setActiveTab('template')}
            />
            <TabButton 
              value="targeting" 
              label="Targeting" 
              icon={Target}
              isActive={activeTab === 'targeting'}
              onClick={() => setActiveTab('targeting')}
            />
            <TabButton 
              value="schedule" 
              label="Schedule" 
              icon={Clock}
              isActive={activeTab === 'schedule'}
              onClick={() => setActiveTab('schedule')}
            />
          </div>

          {/* Tab Content */}
          <div className="mt-6">
            {activeTab === 'details' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Campaign Details</CardTitle>
                    <CardDescription>Basic campaign information and sender settings</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium mb-2">Campaign Name *</label>
                        <Input
                          value={formData.name}
                          onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                          placeholder="Biotech CTO Outreach Q4 2024"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-2">Subject Line *</label>
                        <Input
                          value={formData.subject}
                          onChange={(e) => setFormData(prev => ({ ...prev, subject: e.target.value }))}
                          placeholder="Technology Due Diligence for {{company_name}}"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div>
                        <label className="block text-sm font-medium mb-2">From Name</label>
                        <Input
                          value={formData.from_name}
                          onChange={(e) => setFormData(prev => ({ ...prev, from_name: e.target.value }))}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-2">From Email</label>
                        <Input
                          value={formData.from_email}
                          onChange={(e) => setFormData(prev => ({ ...prev, from_email: e.target.value }))}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-2">Reply To</label>
                        <Input
                          value={formData.reply_to}
                          onChange={(e) => setFormData(prev => ({ ...prev, reply_to: e.target.value }))}
                        />
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
            )}

            {activeTab === 'template' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Email Template</CardTitle>
                    <CardDescription>Choose a template for your campaign</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
                      {templates.map((template) => (
                        <Card 
                          key={template.id}
                          className={`cursor-pointer transition-all ${
                            selectedTemplate?.id === template.id 
                              ? 'ring-2 ring-blue-500 bg-blue-50' 
                              : 'hover:shadow-md'
                          }`}
                          onClick={() => handleTemplateSelect(template.id)}
                        >
                          <CardContent className="p-4">
                            <div className="flex items-center justify-between mb-2">
                              <h4 className="font-semibold">{template.name}</h4>
                              <Badge variant="outline">{template.category}</Badge>
                            </div>
                            <p className="text-sm text-gray-600 mb-3">{template.subject_template}</p>
                            <div className="flex flex-wrap gap-1">
                              {template.variables.map((variable) => (
                                <Badge key={variable} variant="secondary" className="text-xs">
                                  {variable}
                                </Badge>
                              ))}
                            </div>
                          </CardContent>
                        </Card>
                      ))}
                    </div>

                    {selectedTemplate && (
                      <Card>
                        <CardHeader className="flex flex-row items-center justify-between">
                          <div>
                            <CardTitle className="text-lg">Template Preview</CardTitle>
                            <CardDescription>Preview of {selectedTemplate.name}</CardDescription>
                          </div>
                          <div className="flex space-x-2">
                            <Button 
                              variant="outline" 
                              onClick={handlePreviewEmail}
                              className="flex items-center space-x-2"
                            >
                              <Eye className="w-4 h-4" />
                              <span>Full Preview</span>
                            </Button>
                            <Button 
                              variant="outline" 
                              onClick={handleTestEmail}
                              disabled={isTesting}
                              className="flex items-center space-x-2"
                            >
                              <TestTube className="w-4 h-4" />
                              <span>{isTesting ? 'Sending...' : 'Test Email'}</span>
                            </Button>
                          </div>
                        </CardHeader>
                        <CardContent>
                          <div className="bg-gray-50 p-4 rounded-lg max-h-64 overflow-y-auto">
                            <div className="text-sm text-gray-600 mb-2">
                              <strong>Subject:</strong> {selectedTemplate.subject_template}
                            </div>
                            <div className="text-sm text-gray-600 mb-4">
                              <strong>Preview:</strong> (Sample data used for variables)
                            </div>
                            <div 
                              className="prose prose-sm max-w-none"
                              dangerouslySetInnerHTML={{ 
                                __html: selectedTemplate.html_content
                                  .replace(/{{first_name}}/g, 'Sarah')
                                  .replace(/{{company_name}}/g, 'BioTech Innovations')
                                  .replace(/{{industry}}/g, 'Biotechnology')
                                  .replace(/{{funding_stage}}/g, 'Series B')
                                  .replace(/{{vc_firm_name}}/g, 'Andreessen Horowitz Bio Fund')
                                  .replace(/{{focus_area}}/g, 'Biotechnology and Digital Health')
                              }}
                            />
                          </div>
                        </CardContent>
                      </Card>
                    )}
                  </CardContent>
                </Card>
              </div>
            )}

            {activeTab === 'targeting' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Audience Targeting</CardTitle>
                    <CardDescription>Define who should receive this campaign</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    {/* Target Types */}
                    <div>
                      <label className="block text-sm font-medium mb-3">Target Types</label>
                      <div className="flex gap-4">
                        <div className="flex items-center space-x-2">
                          <Checkbox
                            checked={formData.target_types.includes('companies')}
                            onCheckedChange={(checked) => {
                              if (checked) {
                                setFormData(prev => ({
                                  ...prev,
                                  target_types: [...prev.target_types.filter(t => t !== 'companies'), 'companies']
                                }))
                              } else {
                                setFormData(prev => ({
                                  ...prev,
                                  target_types: prev.target_types.filter(t => t !== 'companies')
                                }))
                              }
                            }}
                          />
                          <Building className="w-4 h-4 text-blue-500" />
                          <span className="text-sm">Biotech Companies</span>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Checkbox
                            checked={formData.target_types.includes('vc_firms')}
                            onCheckedChange={(checked) => {
                              if (checked) {
                                setFormData(prev => ({
                                  ...prev,
                                  target_types: [...prev.target_types.filter(t => t !== 'vc_firms'), 'vc_firms']
                                }))
                              } else {
                                setFormData(prev => ({
                                  ...prev,
                                  target_types: prev.target_types.filter(t => t !== 'vc_firms')
                                }))
                              }
                            }}
                          />
                          <Briefcase className="w-4 h-4 text-purple-500" />
                          <span className="text-sm">VC Firms</span>
                        </div>
                      </div>
                    </div>

                    {/* Industries */}
                    <div>
                      <label className="block text-sm font-medium mb-2">Industries</label>
                      <div className="max-h-40 overflow-y-auto border rounded-md p-3 space-y-2">
                        {INDUSTRIES.map(industry => (
                          <div key={industry} className="flex items-center space-x-2">
                            <Checkbox
                              checked={formData.industries.includes(industry)}
                              onCheckedChange={(checked) => {
                                if (checked) {
                                  setFormData(prev => ({
                                    ...prev,
                                    industries: [...prev.industries, industry]
                                  }))
                                } else {
                                  setFormData(prev => ({
                                    ...prev,
                                    industries: prev.industries.filter(i => i !== industry)
                                  }))
                                }
                              }}
                            />
                            <span className="text-sm">{industry}</span>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Role Categories */}
                    <div>
                      <label className="block text-sm font-medium mb-2">Target Roles</label>
                      <div className="flex flex-wrap gap-3">
                        {ROLE_CATEGORIES.map(role => (
                          <div key={role} className="flex items-center space-x-2">
                            <Checkbox
                              checked={formData.role_categories.includes(role)}
                              onCheckedChange={(checked) => {
                                if (checked) {
                                  setFormData(prev => ({
                                    ...prev,
                                    role_categories: [...prev.role_categories, role]
                                  }))
                                } else {
                                  setFormData(prev => ({
                                    ...prev,
                                    role_categories: prev.role_categories.filter(r => r !== role)
                                  }))
                                }
                              }}
                            />
                            <span className="text-sm">{role}</span>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Additional Options */}
                    <div className="space-y-3 pt-4 border-t">
                      <div className="flex items-center space-x-2">
                        <Checkbox
                          checked={formData.exclude_contacted}
                          onCheckedChange={(checked) => 
                            setFormData(prev => ({ ...prev, exclude_contacted: checked as boolean }))
                          }
                        />
                        <span className="text-sm">Exclude previously contacted leads</span>
                      </div>
                    </div>

                    {/* Recipient Estimate */}
                    <Card className="bg-blue-50 border-blue-200">
                      <CardContent className="p-4">
                        <div className="flex items-center space-x-3">
                          <Users className="w-5 h-5 text-blue-600" />
                          <div>
                            <p className="font-medium text-blue-900">
                              Estimated Recipients: {estimatedRecipients.toLocaleString()}
                            </p>
                            <p className="text-sm text-blue-700">
                              Based on your targeting criteria
                            </p>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  </CardContent>
                </Card>
              </div>
            )}

            {activeTab === 'schedule' && (
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle>Campaign Schedule</CardTitle>
                    <CardDescription>Choose when to send your campaign</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div className="space-y-4">
                      <div className="flex items-center space-x-2">
                        <input
                          type="radio"
                          id="send-now"
                          name="schedule"
                          checked={formData.schedule_type === 'now'}
                          onChange={() => setFormData(prev => ({ ...prev, schedule_type: 'now' }))}
                        />
                        <label htmlFor="send-now" className="text-sm font-medium">Send immediately</label>
                      </div>
                      
                      <div className="flex items-center space-x-2">
                        <input
                          type="radio"
                          id="send-scheduled"
                          name="schedule"
                          checked={formData.schedule_type === 'scheduled'}
                          onChange={() => setFormData(prev => ({ ...prev, schedule_type: 'scheduled' }))}
                        />
                        <label htmlFor="send-scheduled" className="text-sm font-medium">Schedule for later</label>
                      </div>

                      {formData.schedule_type === 'scheduled' && (
                        <div className="ml-6 space-y-3">
                          <div>
                            <label className="block text-sm font-medium mb-2">Schedule Date & Time</label>
                            <input
                              type="datetime-local"
                              value={formData.scheduled_at || ''}
                              onChange={(e) => setFormData(prev => ({ ...prev, scheduled_at: e.target.value }))}
                              className="border border-gray-300 rounded-md px-3 py-2"
                              min={new Date().toISOString().slice(0, 16)}
                            />
                          </div>
                          <p className="text-sm text-gray-600">
                            Campaign will be automatically sent at the scheduled time
                          </p>
                        </div>
                      )}
                    </div>

                    {/* Campaign Summary */}
                    <Card className="bg-gray-50">
                      <CardHeader>
                        <CardTitle className="text-lg">Campaign Summary</CardTitle>
                      </CardHeader>
                      <CardContent className="space-y-3">
                        <div className="grid grid-cols-2 gap-4 text-sm">
                          <div>
                            <span className="font-medium">Campaign Name:</span>
                            <p>{formData.name || 'Untitled Campaign'}</p>
                          </div>
                          <div>
                            <span className="font-medium">Template:</span>
                            <p>{selectedTemplate?.name || 'No template selected'}</p>
                          </div>
                          <div>
                            <span className="font-medium">Recipients:</span>
                            <p>{estimatedRecipients.toLocaleString()} contacts</p>
                          </div>
                          <div>
                            <span className="font-medium">Schedule:</span>
                            <p>{formData.schedule_type === 'now' ? 'Send immediately' : 
                               formData.scheduled_at ? new Date(formData.scheduled_at).toLocaleString() : 'Not scheduled'}</p>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  </CardContent>
                </Card>
              </div>
            )}
          </div>

          {/* Action Buttons */}
          <div className="flex justify-between pt-6 border-t">
            <Button variant="outline" onClick={() => onOpenChange(false)}>
              <X className="w-4 h-4 mr-2" />
              Cancel
            </Button>
            
            <div className="flex space-x-3">
              <Button 
                variant="outline" 
                disabled={!formData.template_id || isCreating}
                onClick={handlePreviewEmail}
              >
                <Eye className="w-4 h-4 mr-2" />
                Preview Email
              </Button>
              
              {formData.schedule_type === 'scheduled' ? (
                <Button 
                  onClick={handleCreateCampaign}
                  disabled={!formData.name.trim() || !formData.template_id || isCreating || estimatedRecipients === 0}
                  className="bg-blue-600 hover:bg-blue-700"
                >
                  <Calendar className="w-4 h-4 mr-2" />
                  {isCreating ? 'Scheduling...' : 'Schedule Campaign'}
                </Button>
              ) : (
                <Button 
                  onClick={handleCreateCampaign}
                  disabled={!formData.name.trim() || !formData.template_id || isCreating || estimatedRecipients === 0}
                  className="bg-gradient-to-r from-blue-500 to-purple-600"
                >
                  <Send className="w-4 h-4 mr-2" />
                  {isCreating ? 'Creating...' : isDemoMode ? 'Create Demo Campaign' : 'Create & Send Campaign'}
                </Button>
              )}
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Full Preview Dialog */}
      {showPreviewDialog && (
        <Dialog open={showPreviewDialog} onOpenChange={setShowPreviewDialog}>
          <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle className="flex items-center space-x-2">
                <Eye className="w-5 h-5" />
                <span>Email Preview - {selectedTemplate?.name}</span>
              </DialogTitle>
              <DialogDescription>
                Preview of how your email will look to recipients (using sample data)
              </DialogDescription>
            </DialogHeader>
            
            <div className="space-y-4">
              {/* Email Headers */}
              <div className="bg-gray-100 p-4 rounded-lg text-sm">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <strong>From:</strong> {formData.from_name} &lt;{formData.from_email}&gt;
                  </div>
                  <div>
                    <strong>To:</strong> Sarah Chen &lt;sarah.chen@biotechinnovations.com&gt;
                  </div>
                  <div>
                    <strong>Subject:</strong> {formData.subject.replace(/{{company_name}}/g, 'BioTech Innovations')}
                  </div>
                  <div>
                    <strong>Reply-To:</strong> {formData.reply_to}
                  </div>
                </div>
              </div>

              {/* Email Content */}
              <div className="border border-gray-200 rounded-lg p-6 bg-white">
                <div 
                  dangerouslySetInnerHTML={{ __html: previewContent }}
                  className="email-preview"
                />
              </div>

              {/* Action Buttons */}
              <div className="flex justify-end space-x-3">
                <Button variant="outline" onClick={() => setShowPreviewDialog(false)}>
                  Close Preview
                </Button>
                <Button 
                  onClick={handleTestEmail}
                  disabled={isTesting}
                  className="bg-blue-600 hover:bg-blue-700"
                >
                  <TestTube className="w-4 h-4 mr-2" />
                  {isTesting ? 'Sending Test...' : 'Send Test Email'}
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </>
  )
}
EOF

# 2. Fix the email settings page too
echo "⚙️ Fixing email settings page toast calls..."
cat > app/email-settings/page.tsx << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { 
  Mail, 
  Key, 
  Save,
  TestTube,
  Shield,
  User,
  Settings,
  CheckCircle,
  XCircle,
  Globe,
  Send,
  RefreshCw
} from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { toast } from 'react-hot-toast'

interface EmailSettings {
  sendgrid_api_key: string
  from_name: string
  from_email: string
  reply_to_email: string
  company_name: string
  company_website: string
  signature: string
  bounce_handling: boolean
  click_tracking: boolean
  open_tracking: boolean
  unsubscribe_group_id?: string
}

export default function EmailSettingsPage() {
  const { isDemoMode } = useDemoMode()
  const [activeTab, setActiveTab] = useState('smtp')
  const [isSaving, setIsSaving] = useState(false)
  const [isTesting, setIsTesting] = useState(false)
  const [testResult, setTestResult] = useState<{ success: boolean; message: string } | null>(null)
  
  const [settings, setSettings] = useState<EmailSettings>({
    sendgrid_api_key: '',
    from_name: 'Peter Ferreira',
    from_email: 'peter@ferreiracto.com',
    reply_to_email: 'peter@ferreiracto.com',
    company_name: 'Ferreira CTO',
    company_website: 'https://ferreiracto.com',
    signature: `Best regards,\nPeter Ferreira\nCTO Consultant • Technology Due Diligence\nFerreira CTO\n📧 peter@ferreiracto.com\n🌐 www.ferreiracto.com`,
    bounce_handling: true,
    click_tracking: true,
    open_tracking: true,
    unsubscribe_group_id: ''
  })

  useEffect(() => {
    loadSettings()
  }, [isDemoMode])

  const loadSettings = async () => {
    try {
      if (isDemoMode) {
        // Load demo settings
        const demoSettings = {
          ...settings,
          sendgrid_api_key: 'SG.DEMO_KEY_HIDDEN_FOR_SECURITY',
        }
        setSettings(demoSettings)
        return
      }

      const response = await fetch('/api/settings/email')
      if (response.ok) {
        const data = await response.json()
        setSettings(data)
      }
    } catch (error) {
      console.error('Error loading email settings:', error)
      toast.error('Failed to load email settings')
    }
  }

  const handleSave = async () => {
    if (!settings.sendgrid_api_key.trim()) {
      toast.error('SendGrid API key is required')
      return
    }

    if (!settings.from_email.trim()) {
      toast.error('From email is required')
      return
    }

    setIsSaving(true)
    try {
      if (isDemoMode) {
        await new Promise(resolve => setTimeout(resolve, 1500))
        toast.success('Demo: Email settings saved successfully!')
        // Using regular toast instead of toast.info
        toast('Demo Mode: Settings saved locally for testing', {
          icon: 'ℹ️',
          style: {
            background: '#3B82F6',
            color: 'white',
          }
        })
      } else {
        const response = await fetch('/api/settings/email', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(settings)
        })

        if (response.ok) {
          toast.success('Email settings saved successfully!')
        } else {
          throw new Error('Failed to save settings')
        }
      }
    } catch (error) {
      console.error('Error saving settings:', error)
      toast.error('Failed to save email settings')
    } finally {
      setIsSaving(false)
    }
  }

  const handleTestEmail = async () => {
    if (!settings.sendgrid_api_key.trim()) {
      toast.error('Please configure SendGrid API key first')
      return
    }

    if (!settings.from_email.trim()) {
      toast.error('Please configure from email first')
      return
    }

    setIsTesting(true)
    setTestResult(null)
    
    try {
      if (isDemoMode) {
        // Simulate test email in demo mode
        await new Promise(resolve => setTimeout(resolve, 3000))
        setTestResult({
          success: true,
          message: 'Demo test email sent successfully! No actual email was sent in demo mode.'
        })
        toast.success('Demo: Test email completed successfully!')
        // Using regular toast instead of toast.info
        toast('Demo Mode: No actual email sent, but configuration looks good', {
          icon: 'ℹ️',
          style: {
            background: '#3B82F6',
            color: 'white',
          }
        })
      } else {
        const response = await fetch('/api/email/test-settings', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            ...settings,
            test_recipient: settings.from_email
          })
        })

        const result = await response.json()
        
        if (response.ok) {
          setTestResult({ success: true, message: result.message })
          toast.success('Test email sent successfully! Check your inbox.')
        } else {
          setTestResult({ success: false, message: result.error || 'Test failed' })
          toast.error('Email test failed')
        }
      }
    } catch (error) {
      console.error('Test email error:', error)
      setTestResult({ success: false, message: error.message })
      toast.error('Failed to test email configuration')
    } finally {
      setIsTesting(false)
    }
  }

  const tabs = [
    { id: 'smtp', name: 'SMTP Configuration', icon: Mail },
    { id: 'sender', name: 'Sender Settings', icon: User },
    { id: 'tracking', name: 'Tracking & Analytics', icon: Settings },
    { id: 'compliance', name: 'Compliance', icon: Shield },
  ]

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Email Settings</h1>
        <p className="text-gray-600 dark:text-gray-400">
          Configure your email service provider and campaign settings • {isDemoMode ? 'Demo Mode' : 'Production Mode'}
        </p>
      </div>

      {/* Mode Info */}
      <Card className={`border-0 shadow-sm ${isDemoMode ? 'bg-blue-50 dark:bg-blue-900/20' : 'bg-green-50 dark:bg-green-900/20'}`}>
        <CardContent className="p-4">
          <div className="flex items-center space-x-3">
            {isDemoMode ? (
              <TestTube className="w-5 h-5 text-blue-600 dark:text-blue-400" />
            ) : (
              <Mail className="w-5 h-5 text-green-600 dark:text-green-400" />
            )}
            <div>
              <p className={`font-medium ${isDemoMode ? 'text-blue-800 dark:text-blue-300' : 'text-green-800 dark:text-green-300'}`}>
                {isDemoMode ? 'Demo Mode Active' : 'Production Mode Active'}
              </p>
              <p className={`text-sm ${isDemoMode ? 'text-blue-600 dark:text-blue-400' : 'text-green-600 dark:text-green-400'}`}>
                {isDemoMode 
                  ? 'Email testing will simulate sending without actual emails'
                  : 'Email settings will be used for actual campaign sending'
                }
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Sidebar Navigation */}
        <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm lg:col-span-1">
          <CardContent className="p-0">
            <nav className="space-y-1 p-4">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors ${
                    activeTab === tab.id
                      ? 'bg-gradient-to-r from-blue-500 to-purple-600 text-white'
                      : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
                  }`}
                >
                  <tab.icon className="mr-3 h-4 w-4" />
                  {tab.name}
                </button>
              ))}
            </nav>
          </CardContent>
        </Card>

        {/* Settings Content */}
        <div className="lg:col-span-3 space-y-6">
          {/* SMTP Configuration */}
          {activeTab === 'smtp' && (
            <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Mail className="mr-2 h-5 w-5" />
                  SendGrid Configuration
                </CardTitle>
                <CardDescription>
                  Configure your SendGrid account for email sending
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">
                    SendGrid API Key *
                  </label>
                  <Input
                    type="password"
                    value={settings.sendgrid_api_key}
                    onChange={(e) => setSettings(prev => ({ ...prev, sendgrid_api_key: e.target.value }))}
                    placeholder="SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
                    className="font-mono"
                  />
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                    Your SendGrid API key with email sending permissions
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">
                    Unsubscribe Group ID (Optional)
                  </label>
                  <Input
                    value={settings.unsubscribe_group_id || ''}
                    onChange={(e) => setSettings(prev => ({ ...prev, unsubscribe_group_id: e.target.value }))}
                    placeholder="12345"
                  />
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                    SendGrid unsubscribe group for better deliverability
                  </p>
                </div>

                <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
                  <h4 className="font-medium text-blue-900 dark:text-blue-300 mb-2">
                    📝 SendGrid Setup Instructions
                  </h4>
                  <ol className="text-sm text-blue-800 dark:text-blue-400 space-y-1 list-decimal list-inside">
                    <li>Log into your SendGrid account</li>
                    <li>Go to Settings → API Keys</li>
                    <li>Create a new API key with "Mail Send" permissions</li>
                    <li>Copy and paste the API key above</li>
                    <li>Verify your sender domain in SendGrid</li>
                  </ol>
                </div>

                {/* Test Configuration */}
                <div className="pt-4 border-t border-gray-200 dark:border-gray-700">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h4 className="font-medium text-gray-900 dark:text-white">Test Configuration</h4>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        Send a test email to verify your setup
                      </p>
                    </div>
                    <Button 
                      onClick={handleTestEmail}
                      disabled={isTesting || !settings.sendgrid_api_key.trim()}
                      className="bg-blue-600 hover:bg-blue-700"
                    >
                      {isTesting ? (
                        <>
                          <RefreshCw className="w-4 h-4 mr-2 animate-spin" />
                          Testing...
                        </>
                      ) : (
                        <>
                          <TestTube className="w-4 h-4 mr-2" />
                          Test Email
                        </>
                      )}
                    </Button>
                  </div>

                  {testResult && (
                    <div className={`p-3 rounded-lg flex items-start space-x-2 ${
                      testResult.success 
                        ? 'bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800' 
                        : 'bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800'
                    }`}>
                      {testResult.success ? (
                        <CheckCircle className="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0 mt-0.5" />
                      ) : (
                        <XCircle className="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
                      )}
                      <div>
                        <p className={`font-medium ${testResult.success ? 'text-green-900 dark:text-green-300' : 'text-red-900 dark:text-red-300'}`}>
                          {testResult.success ? 'Test Successful!' : 'Test Failed'}
                        </p>
                        <p className={`text-sm ${testResult.success ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'}`}>
                          {testResult.message}
                        </p>
                      </div>
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          )}

          {/* Sender Settings */}
          {activeTab === 'sender' && (
            <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="flex items-center">
                  <User className="mr-2 h-5 w-5" />
                  Sender Information
                </CardTitle>
                <CardDescription>
                  Configure your sender details and email signature
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">From Name *</label>
                    <Input
                      value={settings.from_name}
                      onChange={(e) => setSettings(prev => ({ ...prev, from_name: e.target.value }))}
                      placeholder="Peter Ferreira"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">From Email *</label>
                    <Input
                      type="email"
                      value={settings.from_email}
                      onChange={(e) => setSettings(prev => ({ ...prev, from_email: e.target.value }))}
                      placeholder="peter@ferreiracto.com"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Reply-To Email</label>
                  <Input
                    type="email"
                    value={settings.reply_to_email}
                    onChange={(e) => setSettings(prev => ({ ...prev, reply_to_email: e.target.value }))}
                    placeholder="peter@ferreiracto.com"
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Company Name</label>
                    <Input
                      value={settings.company_name}
                      onChange={(e) => setSettings(prev => ({ ...prev, company_name: e.target.value }))}
                      placeholder="Ferreira CTO"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Company Website</label>
                    <div className="flex">
                      <Globe className="w-4 h-4 text-gray-400 mt-3 mr-2" />
                      <Input
                        type="url"
                        value={settings.company_website}
                        onChange={(e) => setSettings(prev => ({ ...prev, company_website: e.target.value }))}
                        placeholder="https://ferreiracto.com"
                      />
                    </div>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2 text-gray-900 dark:text-white">Email Signature</label>
                  <Textarea
                    value={settings.signature}
                    onChange={(e) => setSettings(prev => ({ ...prev, signature: e.target.value }))}
                    rows={4}
                    placeholder="Best regards,&#10;Peter Ferreira&#10;CTO Consultant"
                  />
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                    This signature will be automatically added to all your campaigns
                  </p>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Tracking & Analytics */}
          {activeTab === 'tracking' && (
            <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Settings className="mr-2 h-5 w-5" />
                  Tracking & Analytics
                </CardTitle>
                <CardDescription>
                  Configure email tracking and analytics features
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-4">
                  <div className="flex items-center justify-between p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
                    <div>
                      <h4 className="font-medium text-gray-900 dark:text-white">Open Tracking</h4>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        Track when recipients open your emails
                      </p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={settings.open_tracking}
                        onChange={(e) => setSettings(prev => ({ ...prev, open_tracking: e.target.checked }))}
                        className="sr-only peer"
                      />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                    </label>
                  </div>

                  <div className="flex items-center justify-between p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
                    <div>
                      <h4 className="font-medium text-gray-900 dark:text-white">Click Tracking</h4>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        Track when recipients click links in your emails
                      </p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={settings.click_tracking}
                        onChange={(e) => setSettings(prev => ({ ...prev, click_tracking: e.target.checked }))}
                        className="sr-only peer"
                      />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                    </label>
                  </div>

                  <div className="flex items-center justify-between p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
                    <div>
                      <h4 className="font-medium text-gray-900 dark:text-white">Bounce Handling</h4>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        Automatically handle bounced emails and update contact status
                      </p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={settings.bounce_handling}
                        onChange={(e) => setSettings(prev => ({ ...prev, bounce_handling: e.target.checked }))}
                        className="sr-only peer"
                      />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"></div>
                    </label>
                  </div>
                </div>

                <div className="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-lg">
                  <h4 className="font-medium text-yellow-800 dark:text-yellow-400 mb-2">
                    📊 Analytics Benefits
                  </h4>
                  <ul className="text-sm text-yellow-700 dark:text-yellow-300 space-y-1">
                    <li>• Track campaign performance and engagement rates</li>
                    <li>• Identify most effective subject lines and content</li>
                    <li>• Optimize send times based on open patterns</li>
                    <li>• Maintain good sender reputation with bounce handling</li>
                  </ul>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Compliance */}
          {activeTab === 'compliance' && (
            <Card className="bg-white dark:bg-gray-800 border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Shield className="mr-2 h-5 w-5" />
                  Compliance & Legal
                </CardTitle>
                <CardDescription>
                  Ensure your email campaigns comply with regulations
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
                  <h4 className="font-medium text-green-800 dark:text-green-400 mb-3">
                    ✅ Compliance Features Enabled
                  </h4>
                  <ul className="text-sm text-green-700 dark:text-green-300 space-y-2">
                    <li className="flex items-center">
                      <CheckCircle className="w-4 h-4 mr-2" />
                      Automatic unsubscribe links in all emails
                    </li>
                    <li className="flex items-center">
                      <CheckCircle className="w-4 h-4 mr-2" />
                      Sender identification in email headers
                    </li>
                    <li className="flex items-center">
                      <CheckCircle className="w-4 h-4 mr-2" />
                      GDPR-compliant data handling
                    </li>
                    <li className="flex items-center">
                      <CheckCircle className="w-4 h-4 mr-2" />
                      CAN-SPAM Act compliance
                    </li>
                    <li className="flex items-center">
                      <CheckCircle className="w-4 h-4 mr-2" />
                      Bounce and complaint handling
                    </li>
                  </ul>
                </div>

                <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
                  <h4 className="font-medium text-blue-800 dark:text-blue-400 mb-3">
                    🔒 Best Practices for Biotech Outreach
                  </h4>
                  <ul className="text-sm text-blue-700 dark:text-blue-300 space-y-2">
                    <li>• Only email professionally relevant contacts (CTOs, executives, VCs)</li>
                    <li>• Provide clear value proposition in your outreach</li>
                    <li>• Include legitimate business purpose and contact info</li>
                    <li>• Respect unsubscribe requests immediately</li>
                    <li>• Monitor sender reputation and deliverability metrics</li>
                    <li>• Maintain accurate contact lists and remove bounces</li>
                  </ul>
                </div>

                <div className="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-lg">
                  <h4 className="font-medium text-yellow-800 dark:text-yellow-400 mb-2">
                    ⚖️ Legal Disclaimer
                  </h4>
                  <p className="text-sm text-yellow-700 dark:text-yellow-300">
                    This system includes compliance features but you are responsible for ensuring 
                    your email campaigns comply with applicable laws in your jurisdiction. 
                    Consult with legal counsel for specific compliance requirements.
                  </p>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Save Button */}
          <div className="flex justify-end">
            <Button 
              onClick={handleSave}
              disabled={isSaving}
              className="bg-gradient-to-r from-blue-500 to-purple-600"
            >
              <Save className="w-4 h-4 mr-2" />
              {isSaving ? 'Saving...' : 'Save Email Settings'}
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

echo ""
echo "✅ React Hot Toast Error Fixed!"
echo ""
echo "🔧 What was fixed:"
echo ""
echo "❌ Problem: toast.info() method doesn't exist in react-hot-toast"
echo "   This is a common issue - only toast(), toast.success(), toast.error(), and toast.loading() are standard"
echo ""
echo "✅ Solution: Replaced all toast.info() calls with:"
echo "   - Custom styled toast() calls with info icon and blue background"
echo "   - Maintains the same visual feedback as toast.info would provide"
echo "   - Uses proper react-hot-toast API methods"
echo ""
echo "📧 Fixed in these files:"
echo "   - components/email/campaign-creation-dialog.tsx"
echo "   - app/email-settings/page.tsx"
echo ""
echo "🎨 Info messages now display as:"
echo "   - Blue background with white text"
echo "   - Info icon (ℹ️) for visual distinction"
echo "   - Same functionality as before, just using correct API"
echo ""
echo "The email campaign creation and settings should now work without toast errors!"
