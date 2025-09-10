#!/bin/bash

echo "🔧 Fixing Component Import Issues..."
echo "=================================="

# 1. First, let's check if we have the Template icon issue - replace with FileText
echo "📝 Updating campaign dialog with correct imports..."
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
  X
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
    name: 'Biotech Introduction',
    category: 'outreach',
    subject_template: 'Technology Due Diligence for {{company_name}}',
    html_content: '<p>Hi {{first_name}},</p><p>I hope this email finds you well. I am Peter Ferreira, CTO consultant specializing in technology due diligence for biotech companies like {{company_name}}.</p><p>I have been following {{company_name}} progress and am impressed by your {{funding_stage}} growth...</p>',
    text_content: 'Hi {{first_name}}, I hope this email finds you well...',
    variables: ['first_name', 'company_name', 'industry', 'funding_stage']
  },
  {
    id: 'demo-template-2',
    name: 'VC Partnership',
    category: 'outreach',
    subject_template: 'Technology Due Diligence Partnership - {{vc_firm_name}}',
    html_content: '<p>Hi {{first_name}},</p><p>I am Peter Ferreira, a CTO consultant specializing in technology due diligence for biotech investments...</p>',
    text_content: 'Hi {{first_name}}, I am Peter Ferreira...',
    variables: ['first_name', 'vc_firm_name', 'focus_area']
  },
  {
    id: 'demo-template-3',
    name: 'Follow-up Meeting',
    category: 'followup',
    subject_template: 'Following up on {{company_name}} technology discussion',
    html_content: '<p>Hi {{first_name}},</p><p>I wanted to follow up on my previous email about technology consulting for {{company_name}}...</p>',
    text_content: 'Hi {{first_name}}, I wanted to follow up...',
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
      // Mock estimation for demo - in production this would query the database
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

  const handleScheduleCampaign = async () => {
    if (!formData.scheduled_at) {
      toast.error('Please select a schedule time')
      return
    }
    await handleCreateCampaign()
  }

  // Simple tab navigation without external Tabs component
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

        {/* Custom Tab Navigation */}
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
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
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
                    <Card className="mt-6">
                      <CardHeader>
                        <CardTitle className="text-lg">Template Preview</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <div className="bg-gray-50 p-4 rounded-lg">
                          <div className="text-sm text-gray-600 mb-2">Subject: {selectedTemplate.subject_template}</div>
                          <div 
                            className="prose prose-sm max-w-none"
                            dangerouslySetInnerHTML={{ __html: selectedTemplate.html_content }}
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
            <Button variant="outline" disabled={!formData.template_id || isCreating}>
              <Eye className="w-4 h-4 mr-2" />
              Preview Email
            </Button>
            
            {formData.schedule_type === 'scheduled' ? (
              <Button 
                onClick={handleScheduleCampaign}
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
                {isCreating ? 'Creating...' : 'Create & Send Campaign'}
              </Button>
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
EOF

echo ""
echo "✅ Component imports fixed!"
echo ""
echo "🔧 Changes made:"
echo "  - Replaced 'Template' icon with 'FileText' (Template doesn't exist in lucide-react)"
echo "  - Removed Tabs components (created custom tab navigation instead)"
echo "  - Created simple custom TabButton component"
echo "  - All imports now use only confirmed working components"
echo ""
echo "🚀 Try running the application again:"
echo "   npm run dev"
echo ""
echo "The campaign creation dialog should now work without import errors!"
