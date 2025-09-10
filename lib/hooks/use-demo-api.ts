'use client'

import { useDemoMode } from '@/lib/demo-context'
import { useCallback } from 'react'

export function useDemoAPI() {
  const { isDemoMode } = useDemoMode()

  const fetchWithDemo = useCallback(async (url: string, options?: RequestInit) => {
    // Add demo parameter to URL if in demo mode
    const urlWithDemo = new URL(url, window.location.origin)
    if (isDemoMode) {
      urlWithDemo.searchParams.set('demo', 'true')
    }

    console.log(`🔗 API Call: ${urlWithDemo.toString()} (demo: ${isDemoMode})`)

    return fetch(urlWithDemo.toString(), options)
  }, [isDemoMode])

  return { fetchWithDemo, isDemoMode }
}
