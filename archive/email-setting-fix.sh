#!/bin/bash

echo "🔧 Fixing Email Settings - Restoring All Tabs"
echo "=============================================="

# Create the complete email settings page with all tabs working
echo "⚙️ Creating complete email settings page with all tabs..."
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
  RefreshCw,
  AlertTriangle
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
  const [testResult, setTestResult] = useState<{ success: boolean; message: string; details?: any } | null>(null)
  
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
        const demoSettings = {
          ...settings,
          sendgrid_api_key: 'SG.DEMO_KEY_HIDDEN_FOR_SECURITY',
        }
        setSettings(demoSettings)
        return
      }

      console.log('🔄 Loading email settings...')
      const response = await fetch('/api/settings/email')
      console.log('📡 Settings response status:', response.status)
      
      if (response.ok) {
        const data = await response.json()
        console.log('✅ Settings loaded:', data)
        if (data.settings) {
          setSettings(data.settings)
        }
      } else {
        console.warn('⚠️ Failed to load settings, using defaults')
      }
    } catch (error) {
      console.error('❌ Error loading email settings:', error)
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
        toast('Demo Mode: Settings saved locally for testing', {
          icon: 'ℹ️',
          style: { background: '#3B82F6', color: 'white' }
        })
      } else {
        console.log('💾 Saving email settings...')
        const response = await fetch('/api/settings/email', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(settings)
        })

        console.log('📡 Save response status:', response.status)
        
        if (response.ok) {
          const data = await response.json()
          console.log('✅ Settings saved:', data)
          toast.success('Email settings saved successfully!')
        } else {
          const errorText = await response.text()
          console.error('❌ Save failed:', errorText)
          throw new Error('Failed to save settings')
        }
      }
    } catch (error) {
      console.error('❌ Error saving settings:', error)
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
        console.log('🧪 Demo mode email test')
        await new Promise(resolve => setTimeout(resolve, 3000))
        setTestResult({
          success: true,
          message: 'Demo test email sent successfully! No actual email was sent in demo mode.'
        })
        toast.success('Demo: Test email completed successfully!')
        toast('Demo Mode: No actual email sent, but configuration looks good', {
          icon: 'ℹ️',
          style: { background: '#3B82F6', color: 'white' }
        })
      } else {
        console.log('📧 Production mode email test')
        console.log('🔑 Using API key starting with:', settings.sendgrid_api_key.substring(0, 10) + '...')
        
        const requestBody = {
          sendgrid_api_key: settings.sendgrid_api_key,
          from_name: settings.from_name,
          from_email: settings.from_email,
          test_recipient: settings.from_email,
          company_name: settings.company_name
        }
        
        console.log('📤 Sending test request to /api/email/test-settings')
        console.log('📝 Request body (API key hidden):', {
          ...requestBody,
          sendgrid_api_key: '***HIDDEN***'
        })

        const response = await fetch('/api/email/test-settings', {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(requestBody)
        })

        console.log('📡 Test response status:', response.status)
        console.log('📄 Response content-type:', response.headers.get('content-type'))
        
        // Check if we got HTML instead of JSON
        const contentType = response.headers.get('content-type')
        if (!contentType || !contentType.includes('application/json')) {
          const htmlText = await response.text()
          console.error('❌ Received HTML instead of JSON:', htmlText.substring(0, 200))
          
          setTestResult({
            success: false,
            message: 'Server returned HTML instead of JSON. This usually means the API endpoint is not found or there\'s a server error.',
            details: 'Check the server logs for more details.'
          })
          toast.error('API endpoint error - check console for details')
          return
        }

        const result = await response.json()
        console.log('📥 Test response:', result)
        
        if (response.ok && result.success) {
          setTestResult({ 
            success: true, 
            message: result.message,
            details: result.details 
          })
          toast.success('Test email sent successfully! Check your inbox.')
        } else {
          setTestResult({ 
            success: false, 
            message: result.error || 'Test failed',
            details: result.details 
          })
          toast.error('Email test failed - check configuration')
        }
      }
    } catch (error) {
      console.error('❌ Test email error:', error)
      
      let errorMessage = 'Failed to test email configuration'
      if (error.message.includes('JSON')) {
        errorMessage = 'API endpoint returned invalid response (likely HTML instead of JSON)'
      } else if (error.message.includes('fetch')) {
        errorMessage = 'Network error - could not reach API endpoint'
      }
      
      setTestResult({ 
        success: false, 
        message: errorMessage,
        details: error.message
      })
      toast.error(errorMessage)
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
                    <div className={`p-4 rounded-lg border ${
                      testResult.success 
                        ? 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800' 
                        : 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800'
                    }`}>
                      <div className="flex items-start space-x-3">
                        {testResult.success ? (
                          <CheckCircle className="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0 mt-0.5" />
                        ) : (
                          <XCircle className="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
                        )}
                        <div className="flex-1">
                          <p className={`font-medium ${testResult.success ? 'text-green-900 dark:text-green-300' : 'text-red-900 dark:text-red-300'}`}>
                            {testResult.success ? 'Test Successful!' : 'Test Failed'}
                          </p>
                          <p className={`text-sm ${testResult.success ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'}`}>
                            {testResult.message}
                          </p>
                          {testResult.details && (
                            <details className="mt-2">
                              <summary className="cursor-pointer text-xs opacity-75">Technical Details</summary>
                              <pre className="mt-1 text-xs opacity-75 whitespace-pre-wrap">
                                {typeof testResult.details === 'string' 
                                  ? testResult.details 
                                  : JSON.stringify(testResult.details, null, 2)
                                }
                              </pre>
                            </details>
                          )}
                        </div>
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
echo "✅ Email Settings Tabs Fixed!"
echo ""
echo "🔧 What was restored:"
echo ""
echo "📊 Tracking & Analytics Tab:"
echo "  - Open tracking toggle (working)"
echo "  - Click tracking toggle (working)"  
echo "  - Bounce handling toggle (working)"
echo "  - Analytics benefits information"
echo ""
echo "🛡️ Compliance Tab:"
echo "  - Compliance features checklist"
echo "  - Best practices for biotech outreach"
echo "  - Legal disclaimer"
echo "  - GDPR and CAN-SPAM information"
echo ""
echo "🎛️ All tabs now functional:"
echo "  ✅ SMTP Configuration"
echo "  ✅ Sender Settings"  
echo "  ✅ Tracking & Analytics"
echo "  ✅ Compliance"
echo ""
echo "The tracking toggles will now save properly with your settings!"#!/bin/bash

echo "🔧 Fixing Email Settings - Restoring All Tabs"
echo "=============================================="

# Create the complete email settings page with all tabs working
echo "⚙️ Creating complete email settings page with all tabs..."
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
  RefreshCw,
  AlertTriangle
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
  const [testResult, setTestResult] = useState<{ success: boolean; message: string; details?: any } | null>(null)
  
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
        const demoSettings = {
          ...settings,
          sendgrid_api_key: 'SG.DEMO_KEY_HIDDEN_FOR_SECURITY',
        }
        setSettings(demoSettings)
        return
      }

      console.log('🔄 Loading email settings...')
      const response = await fetch('/api/settings/email')
      console.log('📡 Settings response status:', response.status)
      
      if (response.ok) {
        const data = await response.json()
        console.log('✅ Settings loaded:', data)
        if (data.settings) {
          setSettings(data.settings)
        }
      } else {
        console.warn('⚠️ Failed to load settings, using defaults')
      }
    } catch (error) {
      console.error('❌ Error loading email settings:', error)
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
        toast('Demo Mode: Settings saved locally for testing', {
          icon: 'ℹ️',
          style: { background: '#3B82F6', color: 'white' }
        })
      } else {
        console.log('💾 Saving email settings...')
        const response = await fetch('/api/settings/email', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(settings)
        })

        console.log('📡 Save response status:', response.status)
        
        if (response.ok) {
          const data = await response.json()
          console.log('✅ Settings saved:', data)
          toast.success('Email settings saved successfully!')
        } else {
          const errorText = await response.text()
          console.error('❌ Save failed:', errorText)
          throw new Error('Failed to save settings')
        }
      }
    } catch (error) {
      console.error('❌ Error saving settings:', error)
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
        console.log('🧪 Demo mode email test')
        await new Promise(resolve => setTimeout(resolve, 3000))
        setTestResult({
          success: true,
          message: 'Demo test email sent successfully! No actual email was sent in demo mode.'
        })
        toast.success('Demo: Test email completed successfully!')
        toast('Demo Mode: No actual email sent, but configuration looks good', {
          icon: 'ℹ️',
          style: { background: '#3B82F6', color: 'white' }
        })
      } else {
        console.log('📧 Production mode email test')
        console.log('🔑 Using API key starting with:', settings.sendgrid_api_key.substring(0, 10) + '...')
        
        const requestBody = {
          sendgrid_api_key: settings.sendgrid_api_key,
          from_name: settings.from_name,
          from_email: settings.from_email,
          test_recipient: settings.from_email,
          company_name: settings.company_name
        }
        
        console.log('📤 Sending test request to /api/email/test-settings')
        console.log('📝 Request body (API key hidden):', {
          ...requestBody,
          sendgrid_api_key: '***HIDDEN***'
        })

        const response = await fetch('/api/email/test-settings', {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(requestBody)
        })

        console.log('📡 Test response status:', response.status)
        console.log('📄 Response content-type:', response.headers.get('content-type'))
        
        // Check if we got HTML instead of JSON
        const contentType = response.headers.get('content-type')
        if (!contentType || !contentType.includes('application/json')) {
          const htmlText = await response.text()
          console.error('❌ Received HTML instead of JSON:', htmlText.substring(0, 200))
          
          setTestResult({
            success: false,
            message: 'Server returned HTML instead of JSON. This usually means the API endpoint is not found or there\'s a server error.',
            details: 'Check the server logs for more details.'
          })
          toast.error('API endpoint error - check console for details')
          return
        }

        const result = await response.json()
        console.log('📥 Test response:', result)
        
        if (response.ok && result.success) {
          setTestResult({ 
            success: true, 
            message: result.message,
            details: result.details 
          })
          toast.success('Test email sent successfully! Check your inbox.')
        } else {
          setTestResult({ 
            success: false, 
            message: result.error || 'Test failed',
            details: result.details 
          })
          toast.error('Email test failed - check configuration')
        }
      }
    } catch (error) {
      console.error('❌ Test email error:', error)
      
      let errorMessage = 'Failed to test email configuration'
      if (error.message.includes('JSON')) {
        errorMessage = 'API endpoint returned invalid response (likely HTML instead of JSON)'
      } else if (error.message.includes('fetch')) {
        errorMessage = 'Network error - could not reach API endpoint'
      }
      
      setTestResult({ 
        success: false, 
        message: errorMessage,
        details: error.message
      })
      toast.error(errorMessage)
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
                    <div className={`p-4 rounded-lg border ${
                      testResult.success 
                        ? 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800' 
                        : 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800'
                    }`}>
                      <div className="flex items-start space-x-3">
                        {testResult.success ? (
                          <CheckCircle className="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0 mt-0.5" />
                        ) : (
                          <XCircle className="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
                        )}
                        <div className="flex-1">
                          <p className={`font-medium ${testResult.success ? 'text-green-900 dark:text-green-300' : 'text-red-900 dark:text-red-300'}`}>
                            {testResult.success ? 'Test Successful!' : 'Test Failed'}
                          </p>
                          <p className={`text-sm ${testResult.success ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'}`}>
                            {testResult.message}
                          </p>
                          {testResult.details && (
                            <details className="mt-2">
                              <summary className="cursor-pointer text-xs opacity-75">Technical Details</summary>
                              <pre className="mt-1 text-xs opacity-75 whitespace-pre-wrap">
                                {typeof testResult.details === 'string' 
                                  ? testResult.details 
                                  : JSON.stringify(testResult.details, null, 2)
                                }
                              </pre>
                            </details>
                          )}
                        </div>
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
echo "✅ Email Settings Tabs Fixed!"
echo ""
echo "🔧 What was restored:"
echo ""
echo "📊 Tracking & Analytics Tab:"
echo "  - Open tracking toggle (working)"
echo "  - Click tracking toggle (working)"  
echo "  - Bounce handling toggle (working)"
echo "  - Analytics benefits information"
echo ""
echo "🛡️ Compliance Tab:"
echo "  - Compliance features checklist"
echo "  - Best practices for biotech outreach"
echo "  - Legal disclaimer"
echo "  - GDPR and CAN-SPAM information"
echo ""
echo "🎛️ All tabs now functional:"
echo "  ✅ SMTP Configuration"
echo "  ✅ Sender Settings"  
echo "  ✅ Tracking & Analytics"
echo "  ✅ Compliance"
echo ""
echo "The tracking toggles will now save properly with your settings!"
