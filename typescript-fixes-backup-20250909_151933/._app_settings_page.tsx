'use client'

import { useState } from 'react'
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
  User
} from 'lucide-react'

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('company')
  const [isSaving, setIsSaving] = useState(false)

  const handleSave = async () => {
    setIsSaving(true)
    await new Promise(resolve => setTimeout(resolve, 1000))
    setIsSaving(false)
  }

  const tabs = [
    { id: 'company', name: 'Company', icon: User },
    { id: 'email', name: 'Email', icon: Mail },
    { id: 'apis', name: 'API Keys', icon: Key },
    { id: 'security', name: 'Security', icon: Shield },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Settings</h1>
        <p className="text-slate-600">Configure your biotech lead generation system</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Sidebar Navigation */}
        <Card className="border-0 shadow-sm lg:col-span-1">
          <CardContent className="p-0">
            <nav className="space-y-1 p-4">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors ${
                    activeTab === tab.id
                      ? 'bg-gradient-to-r from-blue-500 to-purple-600 text-white'
                      : 'text-slate-700 hover:bg-slate-100'
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
          {/* Company Settings */}
          {activeTab === 'company' && (
            <Card className="border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="flex items-center">
                  <User className="mr-2 h-5 w-5" />
                  Company Information
                </CardTitle>
                <CardDescription>
                  Configure your company details for email signatures and branding
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Company Name</label>
                    <Input defaultValue="Ferreira CTO" />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Company Email</label>
                    <Input defaultValue="peter@ferreiracto.com" />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Email Signature</label>
                  <Textarea
                    defaultValue="Best regards,&#10;Peter Ferreira&#10;CTO, Ferreira CTO&#10;Technology Due Diligence & Strategic Consulting&#10;www.ferreiracto.com"
                    rows={4}
                  />
                </div>
              </CardContent>
            </Card>
          )}

          {/* Email Settings */}
          {activeTab === 'email' && (
            <Card className="border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Mail className="mr-2 h-5 w-5" />
                  SMTP Configuration
                </CardTitle>
                <CardDescription>
                  Configure your email server settings for sending automated emails
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">SMTP Host</label>
                    <Input defaultValue="smtp.gmail.com" />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">SMTP Port</label>
                    <Input defaultValue="587" />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">SMTP Username</label>
                  <Input defaultValue="peter@ferreiracto.com" />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">SMTP Password</label>
                  <Input type="password" placeholder="Gmail App Password (16 characters)" />
                  <p className="text-xs text-slate-500 mt-1">
                    Use a Gmail App Password, not your regular password
                  </p>
                </div>
                <Button variant="outline" className="flex items-center space-x-2">
                  <TestTube className="w-4 h-4" />
                  <span>Test Email Configuration</span>
                </Button>
              </CardContent>
            </Card>
          )}

          {/* API Keys */}
          {activeTab === 'apis' && (
            <Card className="border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Key className="mr-2 h-5 w-5" />
                  API Configuration
                </CardTitle>
                <CardDescription>
                  Configure your third-party service API keys
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div>
                  <h4 className="font-medium text-slate-900 mb-3">Apollo API (Lead Discovery)</h4>
                  <div className="space-y-3">
                    <div>
                      <label className="block text-sm font-medium mb-2">Apollo API Key</label>
                      <Input type="password" placeholder="Enter your Apollo API key" />
                    </div>
                    <Button variant="outline" className="flex items-center space-x-2">
                      <TestTube className="w-4 h-4" />
                      <span>Test API Key</span>
                    </Button>
                  </div>
                </div>

                <div>
                  <h4 className="font-medium text-slate-900 mb-3">Supabase (Database)</h4>
                  <div className="space-y-3">
                    <div>
                      <label className="block text-sm font-medium mb-2">Supabase URL</label>
                      <Input placeholder="https://your-project.supabase.co" />
                    </div>
                    <div>
                      <label className="block text-sm font-medium mb-2">Anon Key</label>
                      <Input type="password" placeholder="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." />
                    </div>
                  </div>
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
              {isSaving ? 'Saving...' : 'Save Settings'}
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
