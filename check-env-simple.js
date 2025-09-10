const fs = require('fs')
const path = require('path')

console.log('\n🔍 Quick Environment Check')
console.log('========================')

const envPath = path.join(process.cwd(), '.env.local')
const envExists = fs.existsSync(envPath)

console.log('📁 .env.local file:', envExists ? '✅ EXISTS' : '❌ MISSING')

if (envExists) {
  const envContent = fs.readFileSync(envPath, 'utf8')
  const requiredVars = [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY', 
    'SUPABASE_SERVICE_ROLE_KEY'
  ]
  
  console.log('\n🔑 Required Variables:')
  requiredVars.forEach(varName => {
    const hasVar = envContent.includes(varName + '=')
    console.log(`   ${hasVar ? '✅' : '❌'} ${varName}`)
  })
} else {
  console.log('\n❌ Please create .env.local with your Supabase credentials')
}

console.log('\n🚀 Next steps:')
console.log('   1. Create/check .env.local file')
console.log('   2. Restart: npm run dev')
console.log('   3. Check the orange debug panel on dashboard')
console.log('   4. Click "Test Supabase" button')
