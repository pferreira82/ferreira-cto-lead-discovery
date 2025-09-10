'use client'

import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ThemeToggle } from '@/components/ui/theme-toggle'
import { useDemoMode } from '@/lib/demo-context'
import { Bell, RefreshCw, Plus, Play, Settings, TestTube, Building } from 'lucide-react'
import { toast } from 'react-hot-toast'

export function Header() {
  const { isDemoMode, toggleDemoMode, isLoaded } = useDemoMode()

  const handleToggle = () => {
    try {
      toggleDemoMode()
      const newMode = !isDemoMode
      toast.success(`Switched to ${newMode ? 'Demo' : 'Production'} mode`, {
        icon: newMode ? '🎮' : '⚙️'
      })
    } catch (error) {
      console.error('Failed to toggle demo mode:', error)
      toast.error('Failed to toggle mode')
    }
  }

  // Show loading state while hydrating
  if (!isLoaded) {
    return (
      <header className="h-16 header-bg border-b flex items-center justify-between px-6">
        <div>
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white">Biotech Lead Generation</h2>
          <p className="text-sm text-gray-500 dark:text-gray-400">
            Technology Due Diligence Dashboard • Loading...
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <div className="w-20 h-8 bg-gray-200 dark:bg-gray-700 rounded animate-pulse"></div>
          <ThemeToggle />
        </div>
      </header>
    )
  }

  return (
    <header className="h-16 header-bg border-b flex items-center justify-between px-6">
      <div>
        <h2 className="text-xl font-semibold text-gray-900 dark:text-white">Biotech Lead Generation</h2>
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Technology Due Diligence Dashboard • {isDemoMode ? 'Demo Mode' : 'Production Mode'}
        </p>
      </div>
      
      <div className="flex items-center space-x-4">
        {/* Demo/Production Toggle */}
        <div className="flex items-center space-x-2 px-3 py-1.5 rounded-lg bg-gray-100 dark:bg-gray-800 border">
          <TestTube className={`w-4 h-4 ${isDemoMode ? 'text-blue-600' : 'text-gray-400'}`} />
          <span className="text-sm text-gray-600 dark:text-gray-400">Demo</span>
          <button
            onClick={handleToggle}
            className={`relative inline-flex h-5 w-9 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 ${
              isDemoMode ? 'bg-gray-300 dark:bg-gray-600' : 'bg-green-500'
            }`}
            aria-label={`Switch to ${isDemoMode ? 'Production' : 'Demo'} mode`}
          >
            <span
              className={`inline-block h-3 w-3 transform rounded-full bg-white transition-transform ${
                isDemoMode ? 'translate-x-1' : 'translate-x-5'
              }`}
            />
          </button>
          <span className="text-sm text-gray-600 dark:text-gray-400">Prod</span>
          <Building className={`w-4 h-4 ${!isDemoMode ? 'text-green-600' : 'text-gray-400'}`} />
        </div>

        <Badge 
          variant="secondary" 
          className={`${
            isDemoMode 
              ? 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-400' 
              : 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400'
          }`}
        >
          {isDemoMode ? 'Demo Active' : 'Production Active'}
        </Badge>
        
        <Button variant="outline" size="sm" className="flex items-center space-x-2">
          <RefreshCw className="w-4 h-4" />
          <span>Sync Data</span>
        </Button>
        
        <Button size="sm" className="flex items-center space-x-2 bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700">
          <Plus className="w-4 h-4" />
          <span>New Campaign</span>
        </Button>

        <ThemeToggle />
        
        <div className="relative">
          <Button variant="ghost" size="sm">
            <Bell className="w-5 h-5" />
          </Button>
          <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></div>
        </div>
      </div>
    </header>
  )
}
