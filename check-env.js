#!/usr/bin/env node

const fs = require('fs')
const path = require('path')

console.log('🔍 Environment Check')
console.log('===================')

// Check for .env.local file
const envPath = path.join(process.cwd(), '.env.local')
const envExists = fs.existsSync(envPath)

console.log('✓ .env.local file:', envExists ? 'EXISTS' : 'MISSING')

if (envExists) {
  const envContent = fs.readFileSync(envPath, 'utf8')
  const lines = envContent.split('\n').filter(line => line.trim() && !line.startsWith('#'))
  
  console.log('\n📋 Environment variables:')
  const requiredVars = [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY', 
    'SUPABASE_SERVICE_ROLE_KEY'
  ]
  
  requiredVars.forEach(varName => {
    const hasVar = lines.some(line => line.startsWith(varName + '='))
    console.log(`   ${hasVar ? '✅' : '❌'} ${varName}`)
  })
  
  console.log('\n📄 All variables:')
  lines.forEach(line => {
    const [key] = line.split('=')
    console.log(`   📝 ${key}`)
  })
} else {
  console.log('\n❌ Create .env.local file with:')
  console.log('   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co')
  console.log('   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key')
  console.log('   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key')
}

console.log('\n🚀 Next steps:')
console.log('   1. Ensure .env.local has all required variables')
console.log('   2. Restart your dev server: npm run dev')
console.log('   3. Visit /debug to run connectivity tests')
console.log('   4. Check browser console for error messages')
