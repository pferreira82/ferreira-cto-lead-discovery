'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Search, AlertCircle, Database } from 'lucide-react'
import { useDemoMode } from '@/lib/demo-context'
import { useDemoAPI } from '@/lib/hooks/use-demo-api'
import { toast } from 'react-hot-toast'

export default function DiscoveryPage() {
  const { isDemoMode } = useDemoMode()
  const { fetchWithDemo } = useDemoAPI()
  const [isTestingDatabase, setIsTestingDatabase] = useState(false)
  const [isTestingSearch, setIsTestingSearch] = useState(false)
  const [databaseResults, setDatabaseResults] = useState<any>(null)
  const [searchResults, setSearchResults] = useState<any>(null)

  const testDatabase = async () => {
    setIsTestingDatabase(true)
    setDatabaseResults(null)
    
    try {
      console.log('Testing database connection...')
      const response = await fetch('/api/debug/database')
      const data = await response.json()
      
      console.log('Database test response:', data)
      setDatabaseResults(data)
      
      if (data.success) {
        toast.success(`Database connected! Found ${data.details?.companyCount || 0} companies`)
      } else {
        toast.error('Database connection failed')
      }
    } catch (error) {
      console.error('Database test error:', error)
      setDatabaseResults({ error: error.message })
      toast.error('Database test failed')
    } finally {
      setIsTestingDatabase(false)
    }
  }

  const testSearch = async () => {
    setIsTestingSearch(true)
    setSearchResults(null)
    
    try {
      console.log('Testing search...')
      const searchResponse = await fetchWithDemo('/api/discovery/search', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          industries: ['Biotechnology'],
          fundingStages: ['Series A', 'Series B', 'Series C', 'Public'],
          maxResults: 10
        })
      })
      
      if (!searchResponse.ok) {
        const errorText = await searchResponse.text()
        throw new Error(`Search API returned ${searchResponse.status}: ${errorText}`)
      }
      
      const searchData = await searchResponse.json()
      console.log('Search response:', searchData)
      
      setSearchResults(searchData)
      
      if (searchData.success) {
        toast.success(`Search successful: ${searchData.leads?.length || 0} companies found (${searchData.source})`)
      } else {
        toast.error(searchData.error || 'Search failed')
      }
      
    } catch (error) {
      console.error('Search error:', error)
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
            <p className="text-muted-foreground mt-1">Debug database connection and search functionality</p>
          </div>
          <div className="flex items-center space-x-2">
            {isDemoMode ? (
              <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
                Demo Mode ON
              </Badge>
            ) : (
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
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
            <CardTitle className="flex items-center">
              <Database className="w-5 h-5 mr-2" />
              1. Database Connection Test
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Test if your Supabase database is connected and has company data
            </p>
            <Button 
              onClick={testDatabase}
              disabled={isTestingDatabase}
              variant="outline"
              className="w-full"
            >
              {isTestingDatabase ? 'Testing Database...' : 'Test Database Connection'}
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Search className="w-5 h-5 mr-2" />
              2. Search Functionality Test
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Test the discovery search with current mode ({isDemoMode ? 'demo' : 'production'})
            </p>
            <Button 
              onClick={testSearch}
              disabled={isTestingSearch}
              className="w-full bg-gradient-to-r from-blue-500 to-purple-600"
            >
              {isTestingSearch ? 'Searching...' : 'Test Search'}
              <Search className="w-4 h-4 ml-2" />
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Database Test Results */}
      {databaseResults && (
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Database Test Results</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {databaseResults.success ? (
                <div className="p-4 bg-green-50 border border-green-200 rounded">
                  <div className="flex items-center">
                    <div className="w-4 h-4 bg-green-500 rounded-full mr-3"></div>
                    <span className="font-medium text-green-800">Database Connected Successfully</span>
                  </div>
                  <div className="mt-2 text-sm text-green-700">
                    <p>Companies in database: <strong>{databaseResults.details?.companyCount || 0}</strong></p>
                    {databaseResults.details?.sampleCompanies?.length > 0 && (
                      <div className="mt-2">
                        <p className="font-medium">Sample companies:</p>
                        <ul className="list-disc list-inside ml-4">
                          {databaseResults.details.sampleCompanies.map((company: any, idx: number) => (
                            <li key={idx}>{company.name} ({company.industry})</li>
                          ))}
                        </ul>
                      </div>
                    )}
                  </div>
                </div>
              ) : (
                <div className="p-4 bg-red-50 border border-red-200 rounded">
                  <div className="flex items-center">
                    <AlertCircle className="w-5 h-5 text-red-600 mr-2" />
                    <span className="font-medium text-red-800">Database Connection Failed</span>
                  </div>
                  <p className="text-sm text-red-700 mt-1">{databaseResults.error}</p>
                </div>
              )}
              
              <details className="mt-4">
                <summary className="cursor-pointer text-sm font-medium">View Raw Results</summary>
                <pre className="text-xs bg-muted p-4 rounded mt-2 overflow-auto">
                  {JSON.stringify(databaseResults, null, 2)}
                </pre>
              </details>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Search Test Results */}
      {searchResults && (
        <Card>
          <CardHeader>
            <CardTitle>Search Test Results</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {searchResults.success ? (
                <div className="p-4 bg-green-50 border border-green-200 rounded">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="w-4 h-4 bg-green-500 rounded-full mr-3"></div>
                      <span className="font-medium text-green-800">Search Successful</span>
                    </div>
                    <Badge variant="outline" className={
                      searchResults.source === 'demo' ? 'bg-blue-100 text-blue-800' :
                      searchResults.source === 'production' ? 'bg-green-100 text-green-800' :
                      'bg-orange-100 text-orange-800'
                    }>
                      {searchResults.source}
                    </Badge>
                  </div>
                  <p className="text-sm text-green-700 mt-2">
                    Found <strong>{searchResults.leads?.length || 0}</strong> companies
                  </p>
                  {searchResults.message && (
                    <p className="text-sm text-green-600 mt-1">{searchResults.message}</p>
                  )}
                </div>
              ) : (
                <div className="p-4 bg-red-50 border border-red-200 rounded">
                  <div className="flex items-center">
                    <AlertCircle className="w-5 h-5 text-red-600 mr-2" />
                    <span className="font-medium text-red-800">Search Failed</span>
                  </div>
                  <p className="text-sm text-red-700 mt-1">{searchResults.error}</p>
                </div>
              )}

              {searchResults.leads && searchResults.leads.length > 0 && (
                <div className="mt-4">
                  <h4 className="font-medium mb-2">Found Companies:</h4>
                  <div className="space-y-2">
                    {searchResults.leads.slice(0, 5).map((lead: any, idx: number) => (
                      <div key={idx} className="p-3 bg-muted/50 rounded">
                        <p className="font-medium">{lead.company}</p>
                        <p className="text-sm text-muted-foreground">
                          {lead.industry} • {lead.location} • {lead.contacts?.length || 0} contacts
                        </p>
                      </div>
                    ))}
                    {searchResults.leads.length > 5 && (
                      <p className="text-sm text-muted-foreground">
                        ...and {searchResults.leads.length - 5} more companies
                      </p>
                    )}
                  </div>
                </div>
              )}
              
              <details className="mt-4">
                <summary className="cursor-pointer text-sm font-medium">View Raw Results</summary>
                <pre className="text-xs bg-muted p-4 rounded mt-2 overflow-auto max-h-96">
                  {JSON.stringify(searchResults, null, 2)}
                </pre>
              </details>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
