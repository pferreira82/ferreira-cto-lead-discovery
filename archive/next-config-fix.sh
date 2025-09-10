#!/bin/bash

echo "🔍 Debugging Next.js Path Resolution Issue"
echo "=========================================="

# 1. Check system information
echo "1. System Information:"
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "OS: $(uname -a)"
echo "Current directory: $(pwd)"
echo ""

# 2. Check for problematic files/directories
echo "2. Checking for problematic files..."
echo "Hidden files in current directory:"
ls -la | head -20
echo ""

# 3. Check directory permissions
echo "3. Directory permissions:"
ls -la . | head -5
echo ""

# 4. Look for symbolic links or unusual files
echo "4. Checking for symbolic links:"
find . -type l -ls 2>/dev/null || echo "No symbolic links found"
echo ""

# 5. Try alternative approach - create minimal project in new directory
echo "5. Creating test project in new directory..."
cd ..
mkdir biotech-test-$(date +%s)
cd biotech-test-*

# Create absolute minimal Next.js project
echo "Creating minimal test project..."

cat > package.json << 'EOF'
{
  "name": "biotech-test",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev --turbo",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}
EOF

mkdir app
cat > app/page.js << 'EOF'
export default function Home() {
  return (
    <main>
      <h1>Test Project Working</h1>
      <p>If you see this, Next.js is working properly.</p>
    </main>
  )
}
EOF

cat > app/layout.js << 'EOF'
export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
EOF

echo ""
echo "✅ Test project created in: $(pwd)"
echo ""
echo "🧪 Test Steps:"
echo "1. cd $(pwd)"
echo "2. npm install"
echo "3. npm run dev"
echo ""
echo "If this works, the issue is with your original project directory."
echo "If this fails, it's a system-level Node.js issue."
echo ""

# 6. Alternative solutions for original project
echo "📋 Alternative Solutions for Original Project:"
echo ""
echo "Option A - Try production build instead of dev:"
echo "  cd /path/to/original/project"
echo "  npm run build"
echo "  npm start"
echo ""
echo "Option B - Disable file watching:"
echo "  WATCHPACK_POLLING=true npm run dev"
echo ""
echo "Option C - Use Turbo mode:"
echo "  npm run dev -- --turbo"
echo ""
echo "Option D - Try different Node version:"
echo "  nvm install 18"
echo "  nvm use 18"
echo "  npm run dev"
echo ""

# 7. Create alternative next.config.js that disables problematic features
cd - > /dev/null
echo "Creating alternative next.config.js that disables file watching..."
cat > next.config.alternative.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Disable file watching completely
  webpack: (config, { dev, isServer }) => {
    if (dev) {
      config.watchOptions = false
      config.cache = false
    }
    return config
  },
  
  // Use polling instead of native file watching
  webpackDevMiddleware: config => {
    config.watchOptions = {
      poll: 1000,
      aggregateTimeout: 300,
    }
    return config
  },
  
  // Minimal configuration
  reactStrictMode: false,
  swcMinify: false,
  
  images: {
    domains: ['images.crunchbase.com', 'logo.clearbit.com'],
  }
}

module.exports = nextConfig
EOF

echo ""
echo "🔄 Created alternative config. To use it:"
echo "  mv next.config.js next.config.original.js"
echo "  mv next.config.alternative.js next.config.js"
echo "  npm run dev"
echo ""

# 8. Create a simple static export version
echo "Creating static export configuration..."
cat > next.config.static.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true
  }
}

module.exports = nextConfig
EOF

echo "🌐 Static export option (no dev server needed):"
echo "  mv next.config.js next.config.dev.js"
echo "  mv next.config.static.js next.config.js"
echo "  npm run build"
echo "  # Then serve the 'out' folder with any static server"
echo ""

echo "💡 Most Likely Solutions:"
echo "1. Try the test project to isolate the issue"
echo "2. Use WATCHPACK_POLLING=true npm run dev"
echo "3. Try npm run build && npm start (production mode)"
echo "4. Switch to Node.js 18 LTS"
echo "5. Move your project to a different directory"
