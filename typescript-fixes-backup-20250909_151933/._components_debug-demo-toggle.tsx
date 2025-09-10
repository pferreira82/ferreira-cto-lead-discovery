'use client'

import { useDemoMode } from '@/lib/demo-context'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export function DebugDemoToggle() {
  const { isDemoMode, toggleDemoMode, isLoaded } = useDemoMode()

  return (
    <Card className="w-full max-w-md">
      <CardHeader>
        <CardTitle>Demo Toggle Debug</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          <div>
            <strong>Is Loaded:</strong> {isLoaded ? 'Yes' : 'No'}
          </div>
          <div>
            <strong>Current Mode:</strong> {isDemoMode ? 'Demo' : 'Production'}
          </div>
          <div>
            <strong>localStorage value:</strong> 
            <span className="ml-2 font-mono text-sm">
              {typeof window !== 'undefined' ? localStorage.getItem('biotech-demo-mode') : 'N/A (SSR)'}
            </span>
          </div>
          <Button onClick={toggleDemoMode} className="w-full">
            Toggle to {isDemoMode ? 'Production' : 'Demo'}
          </Button>
        </div>
      </CardContent>
    </Card>
  )
}
