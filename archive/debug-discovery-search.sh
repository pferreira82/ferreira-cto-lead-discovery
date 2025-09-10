#!/bin/bash

echo "Debugging Discovery Search Issue"
echo "==============================="

# First, let's test if the API endpoint is accessible
echo "Testing API endpoint accessibility..."

# Create a simple test API endpoint
mkdir -p app/api/discovery-test
cat > app/api/discovery-test/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  console.log('Discovery test endpoint called')
  return NextResponse.json({
    success: true,
    message: 'Discovery test endpoint is working',
    timestamp: new Date().toISOString()
  })
}

export async function POST(request: NextRequest) {
  console.log('Discovery test POST endpoint called')
  try {
    const body = await request.json()
    console.log('Request body:', body)
    
    return NextResponse.json({
      success: true,
      message: 'Discovery test POST endpoint is working',
      receivedData: body,
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    console.error('Discovery test POST error:', error)
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 })
  }
}
EOF

# Create a simplified discovery page for debugging
echo "Creating simplified discovery page for debugging..."

if [ -f "app/discovery/page.tsx" ]; then
    cp "app/discovery/page.tsx" "app/discovery/page.tsx.debug-backup"
fi

cat > app/discovery/page.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Search, AlertCircle } from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'
import { toast } from 'react-hot-toast'

export default function DiscoveryPage() {
  const { isDemoMode } = useDemoMode()
  const { fetchWithDemo } = useDemoAPI()
  const [isTestingBasic, setIsTestingBasic] = useState(false)
  const [isTestingSearch, setIsTestingSearch] = useState(false)
  const [testResults, setTestResults] = useState<string>('')
  const [searchResults, setSearchResults] = useState<any>(null)

  const testBasicEndpoint = async () => {
    setIsTestingBasic(true)
    setTestResults('')
    
    try {
      console.log('Testing basic endpoint...')
      const response = await fetch('/api/discovery-test')
      const data = await response.json()
      
      console.log('Basic test response:', data)
      setTestResults(`Basic test: ${JSON.stringify(data, null, 2)}`)
      
      if (data.success) {
        toast.success('Basic API test successful')
      } else {
        toast.error('Basic API test failed')
      }
    } catch (error) {
      console.error('Basic test error:', error)
      setTestResults(`Basic test error: ${error.message}`)
      toast.error('Basic API test failed')
    } finally {
      setIsTestingBasic(false)
    }
  }

  const testSearchEndpoint = async () => {
    setIsTestingSearch(true)
    setSearchResults(null)
    
    try {
      console.log('Testing search endpoint...')
      console.log('Demo mode:', isDemoMode)
      
      // Test the discovery-test POST endpoint first
      const testResponse = await fetchWithDemo('/api/discovery-test', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ test: 'data', demoMode: isDemoMode })
      })
      
      const testData = await testResponse.json()
      console.log('Test POST response:', testData)
      
      if (!testData.success) {
        throw new Error('Test POST endpoint failed')
      }
      
      // Now test the actual search endpoint
      console.log('Testing actual search endpoint...')
      const searchResponse = await fetchWithDemo('/api/discovery/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          industries: ['Biotechnology'],
          fundingStages: ['Series A', 'Series B'],
          maxResults: 5
        })
      })
      
      console.log('Search response status:', searchResponse.status)
      console.log('Search response ok:', searchResponse.ok)
      
      if (!searchResponse.ok) {
        const errorText = await searchResponse.text()
        console.error('Search response error text:', errorText)
        throw new Error(`Search API returned ${searchResponse.status}: ${errorText}`)
      }
      
      const searchData = await searchResponse.json()
      console.log('Search response data:', searchData)
      
      setSearchResults(searchData)
      
      if (searchData.success) {
        toast.success(`Search successful: Found ${searchData.leads?.length || 0} results`)
      } else {
        toast.error(searchData.error || 'Search failed')
      }
      
    } catch (error) {
      console.error('Search test error:', error)
      setSearchResults({ error: error.message })
      toast.error(`Search failed: ${error.message}`)
    } finally {
      setIsTestingSearch(false)
    }
  }

  return (
    <div className="p-6">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Discovery Debug</h1>
            <p className="text-muted-foreground mt-1">Debug the discovery search functionality</p>
          </div>
          <div className="flex items-center space-x-2">
            {isDemoMode && (
              <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
                Demo Mode ON
              </Badge>
            )}
            {!isDemoMode && (
              <Badge variant="outline" className="bg-orange-50 text-orange-700 border-orange-200">
                Production Mode
              </Badge>
            )}
          </div>
        </div>
      </div>

      {/* Debug Tests */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <Card>
          <CardHeader>
            <CardTitle>1. Basic API Test</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Test if basic API endpoints are working
            </p>
            <Button 
              onClick={testBasicEndpoint}
              disabled={isTestingBasic}
              variant="outline"
              className="w-full"
            >
              {isTestingBasic ? 'Testing...' : 'Test Basic API'}
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>2. Search API Test</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Test the actual discovery search functionality
            </p>
            <Button 
              onClick={testSearchEndpoint}
              disabled={isTestingSearch}
              className="w-full bg-gradient-to-r from-blue-500 to-purple-600"
            >
              {isTestingSearch ? 'Searching...' : 'Test Search API'}
              <Search className="w-4 h-4 ml-2" />
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Test Results */}
      {testResults && (
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Basic Test Results</CardTitle>
          </CardHeader>
          <CardContent>
            <pre className="text-xs bg-muted p-4 rounded overflow-auto">
              {testResults}
            </pre>
          </CardContent>
        </Card>
      )}

      {/* Search Results */}
      {searchResults && (
        <Card>
          <CardHeader>
            <CardTitle>Search Test Results</CardTitle>
          </CardHeader>
          <CardContent>
            <pre className="text-xs bg-muted p-4 rounded overflow-auto max-h-96">
              {JSON.stringify(searchResults, null, 2)}
            </pre>
            
            {searchResults.success && searchResults.leads && (
              <div className="mt-4">
                <h4 className="font-medium mb-2">Companies Found: {searchResults.leads.length}</h4>
                <div className="space-y-2">
                  {searchResults.leads.map((lead: any, idx: number) => (
                    <div key={idx} className="p-3 bg-muted/50 rounded">
                      <p className="font-medium">{lead.company}</p>
                      <p className="text-sm text-muted-foreground">{lead.industry} • {lead.location}</p>
                      <p className="text-xs text-muted-foreground">Contacts: {lead.contacts?.length || 0}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Debug Info */}
      <Card className="mt-6">
        <CardHeader>
          <CardTitle>Debug Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2 text-sm">
            <p><strong>Demo Mode:</strong> {isDemoMode ? 'ON' : 'OFF'}</p>
            <p><strong>Expected Search URL:</strong> /api/discovery/search?demo={isDemoMode}</p>
            <p><strong>Test URL:</strong> /api/discovery-test</p>
            <p><strong>Browser:</strong> {typeof window !== 'undefined' ? navigator.userAgent : 'SSR'}</p>
          </div>
          
          <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded">
            <div className="flex items-start">
              <AlertCircle className="h-5 w-5 text-yellow-600 mr-2 mt-0.5" />
              <div>
                <p className="text-sm text-yellow-800">
                  <strong>Debug Steps:</strong>
                </p>
                <ol className="text-xs text-yellow-700 mt-1 list-decimal list-inside space-y-1">
                  <li>Click "Test Basic API" to verify API routing works</li>
                  <li>Click "Test Search API" to debug the search functionality</li>
                  <li>Check browser console for detailed error messages</li>
                  <li>Check server logs for API call details</li>
                </ol>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
EOF

echo ""
echo "Debug Discovery Search Setup Complete"
echo "===================================="
echo ""
echo "Created debug tools:"
echo "• /api/discovery-test endpoint for basic testing"
echo "• Simplified discovery page with debug functions"
echo "• Step-by-step testing buttons"
echo "• Detailed error logging"
echo ""
echo "To debug the issue:"
echo "1. Restart your dev server: npm run dev"
echo "2. Visit /discovery"
echo "3. Click 'Test Basic API' button first"
echo "4. Then click 'Test Search API' button"
echo "5. Check the results and browser console"
echo ""
echo "This will help identify exactly where the search is failing:"
echo "• API routing issues"
echo "• Request/response problems"  
echo "• Demo mode parameter issues"
echo "• Network or fetch errors"
