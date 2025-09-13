'use client'

import React, { createContext, useContext, useState, useEffect } from 'react'

interface DemoContextType {
  isDemoMode: boolean
  setIsDemoMode: (demo: boolean) => void
  toggleDemoMode: () => void
  isLoaded: boolean
}

const DemoContext = createContext<DemoContextType | undefined>(undefined)

export function DemoModeProvider({ children }: { children: React.ReactNode }) {
  const [isDemoMode, setIsDemoMode] = useState(true) // Default to demo
  const [isLoaded, setIsLoaded] = useState(false)

  // Load demo mode from localStorage on mount (client-side only)
  useEffect(() => {
    try {
      const savedMode = localStorage.getItem('biotech-demo-mode')
      if (savedMode !== null) {
        setIsDemoMode(JSON.parse(savedMode))
      }
    } catch (error) {
      console.warn('Failed to load demo mode from localStorage:', error)
      setIsDemoMode(true) // Fallback to demo mode
    }
    setIsLoaded(true)
  }, [])

  // Save demo mode to localStorage when it changes (client-side only)
  useEffect(() => {
    if (isLoaded) {
      try {
        localStorage.setItem('biotech-demo-mode', JSON.stringify(isDemoMode))
      } catch (error) {
        console.warn('Failed to save demo mode to localStorage:', error)
      }
    }
  }, [isDemoMode, isLoaded])

  const toggleDemoMode = () => {
    setIsDemoMode(prev => !prev)
  }

  const contextValue = {
    isDemoMode,
    setIsDemoMode,
    toggleDemoMode,
    isLoaded
  }

  return (
    <DemoContext.Provider value={contextValue}>
      {children}
    </DemoContext.Provider>
  )
}

export function useDemoMode() {
  const context = useContext(DemoContext)
  if (context === undefined) {
    throw new Error('useDemoMode must be used within a DemoModeProvider')
  }
  return context
}

// Legacy export for compatibility
export const DemoProvider = DemoModeProvider
