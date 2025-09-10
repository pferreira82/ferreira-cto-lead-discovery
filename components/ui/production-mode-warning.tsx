'use client'

import { AlertCircle } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { useDemoMode } from '@/lib/demo-context'

interface ProductionModeWarningProps {
  feature: string
  hasData: boolean
  className?: string
}

export function ProductionModeWarning({ feature, hasData, className }: ProductionModeWarningProps) {
  const { isDemoMode } = useDemoMode()

  if (isDemoMode || hasData) return null

  return (
    <Card className={`border-orange-200 bg-orange-50 dark:border-orange-800 dark:bg-orange-900/20 ${className}`}>
      <CardContent className="p-4">
        <div className="flex items-start space-x-3">
          <AlertCircle className="h-5 w-5 text-orange-600 dark:text-orange-400 mt-0.5 flex-shrink-0" />
          <div className="flex-1">
            <div className="flex items-center space-x-2 mb-2">
              <Badge variant="outline" className="bg-orange-100 text-orange-800 border-orange-200 dark:bg-orange-900/40 dark:text-orange-300 dark:border-orange-700">
                Production Mode
              </Badge>
            </div>
            <p className="text-sm text-orange-800 dark:text-orange-200">
              <strong>No {feature} data available.</strong> You're in production mode but no database is configured. 
              Enable demo mode to see sample data, or configure your database connection to see real {feature}.
            </p>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
