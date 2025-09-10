import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  return NextResponse.json({
    success: true,
    message: 'Discovery API is working!',
    timestamp: new Date().toISOString(),
    endpoints: [
      '/api/discovery/search (POST)',
      '/api/discovery/save-leads (POST)',
      '/api/discovery/test (GET)'
    ]
  })
}
