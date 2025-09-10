#!/bin/bash

echo "🚀 Quick Fix for Next.js Dev Server Error"
echo "========================================"

# Stop any running dev servers
echo "1. Stopping any running Next.js processes..."
pkill -f "next dev" 2>/dev/null || true

# Clean caches
echo "2. Cleaning Next.js cache..."
rm -rf .next

# Fix the immediate issue in next.config.js
echo "3. Creating safer next.config.js..."
cp next.config.js next.config.js.backup 2>/dev/null || true

cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  
  images: {
    domains: ['images.crunchbase.com', 'logo.clearbit.com'],
  },

  env: {
    COMPANY_NAME: process.env.COMPANY_NAME || 'Ferreira CTO',
    COMPANY_EMAIL: process.env.COMPANY_EMAIL || 'peter@ferreiracto.com',
  },

  eslint: {
    ignoreDuringBuilds: true,
  },
  
  // Remove problematic webpack config temporarily
  // webpack: (config, { dev }) => {
  //   return config
  // }
}

module.exports = nextConfig
EOF

echo "✅ Updated next.config.js (backup saved)"

# Install missing dependency that was causing build issues
echo "4. Installing missing @radix-ui/react-tabs..."
npm install @radix-ui/react-tabs

# Clear npm cache
echo "5. Clearing npm cache..."
npm cache clean --force

echo ""
echo "✅ Quick fix completed!"
echo ""
echo "Now try: npm run dev"
echo ""
echo "If still failing, run the comprehensive fix:"
echo "  chmod +x fix-nextjs-dev-error.sh"
echo "  ./fix-nextjs-dev-error.sh"
