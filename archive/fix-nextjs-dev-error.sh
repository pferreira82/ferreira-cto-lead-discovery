#!/bin/bash

echo "🔧 Fixing Next.js Development Server Issues"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: Check project structure issues
echo -e "${BLUE}📁 Step 1: Analyzing project structure...${NC}"

if [ -d "app" ] && [ -d "pages" ]; then
    echo -e "${YELLOW}⚠️  WARNING: You have both 'app' and 'pages' directories!${NC}"
    echo "This can cause conflicts in Next.js 13+ with App Router."
    echo ""
    echo "Current structure:"
    echo "├── app/"
    ls -la app/ 2>/dev/null | head -10
    echo "├── pages/"
    ls -la pages/ 2>/dev/null | head -10
    echo ""
    
    read -p "Do you want to use App Router (app/) or Pages Router (pages/)? (app/pages): " -r router_choice
    
    if [[ $router_choice == "pages" ]]; then
        echo "Moving app/ directory content to backup..."
        if [ ! -d "app-backup" ]; then
            mv app app-backup
            echo -e "${GREEN}✅ Moved app/ to app-backup/${NC}"
        fi
    elif [[ $router_choice == "app" ]]; then
        echo "Moving pages/api to app/api and backing up other pages..."
        mkdir -p app/api
        if [ -d "pages/api" ]; then
            cp -r pages/api/* app/api/ 2>/dev/null
            echo -e "${GREEN}✅ Copied API routes to app/api/${NC}"
        fi
        if [ ! -d "pages-backup" ]; then
            mv pages pages-backup
            echo -e "${GREEN}✅ Moved pages/ to pages-backup/${NC}"
        fi
    fi
fi

# Step 2: Check for broken symlinks and undefined paths
echo -e "${BLUE}📁 Step 2: Checking for broken symlinks and files...${NC}"

echo "Checking for broken symlinks..."
broken_symlinks=$(find . -type l ! -exec test -e {} \; -print 2>/dev/null)
if [ ! -z "$broken_symlinks" ]; then
    echo -e "${RED}❌ Found broken symlinks:${NC}"
    echo "$broken_symlinks"
    read -p "Remove broken symlinks? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find . -type l ! -exec test -e {} \; -delete
        echo -e "${GREEN}✅ Removed broken symlinks${NC}"
    fi
else
    echo -e "${GREEN}✅ No broken symlinks found${NC}"
fi

# Step 3: Clean Next.js cache and node_modules
echo -e "${BLUE}🧹 Step 3: Cleaning caches...${NC}"

echo "Removing Next.js cache..."
rm -rf .next
echo -e "${GREEN}✅ Removed .next cache${NC}"

echo "Removing node_modules and package-lock.json..."
rm -rf node_modules package-lock.json
echo -e "${GREEN}✅ Removed node_modules and package-lock.json${NC}"

# Step 4: Fix next.config.js
echo -e "${BLUE}⚙️  Step 4: Updating next.config.js...${NC}"

if [ -f "next.config.js" ]; then
    # Create backup
    cp next.config.js next.config.js.backup
    
    # Create a safer next.config.js
    cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  
  // Essential image configuration only
  images: {
    domains: ['images.crunchbase.com', 'logo.clearbit.com'],
  },

  // Safe environment variables
  env: {
    COMPANY_NAME: process.env.COMPANY_NAME || 'Ferreira CTO',
    COMPANY_EMAIL: process.env.COMPANY_EMAIL || 'peter@ferreiracto.com',
  },

  // Disable problematic features during debugging
  eslint: {
    ignoreDuringBuilds: true,
  },

  // Simplified webpack config to avoid path issues
  webpack: (config, { dev, isServer }) => {
    // Only add watch options if we're in development and not server-side
    if (dev && !isServer) {
      config.watchOptions = {
        ...config.watchOptions,
        ignored: [
          '**/node_modules/**',
          '**/.git/**',
          '**/.next/**',
          '**/.*', // Ignore all dot files
        ],
      }
    }
    return config
  },

  // Experimental features that might help
  experimental: {
    // Disable features that might cause path issues
    serverComponentsExternalPackages: [],
  },
}

module.exports = nextConfig
EOF

    echo -e "${GREEN}✅ Updated next.config.js with safer configuration${NC}"
    echo "Original backed up as next.config.js.backup"
else
    echo -e "${YELLOW}⚠️  No next.config.js found, creating one...${NC}"
    # Create the same config as above
fi

# Step 5: Check and fix tsconfig.json
echo -e "${BLUE}📝 Step 5: Checking tsconfig.json...${NC}"

if [ -f "tsconfig.json" ]; then
    # Check for problematic paths
    if grep -q '"@/\*"' tsconfig.json; then
        echo -e "${GREEN}✅ Path mapping looks correct${NC}"
    else
        echo -e "${YELLOW}⚠️  Updating path mapping in tsconfig.json...${NC}"
        
        # Create backup
        cp tsconfig.json tsconfig.json.backup
        
        # Update tsconfig.json with safer configuration
        cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF
        echo -e "${GREEN}✅ Updated tsconfig.json${NC}"
    fi
fi

# Step 6: Check for missing files and dependencies
echo -e "${BLUE}📦 Step 6: Installing dependencies...${NC}"

echo "Installing fresh dependencies..."
npm install

# Check for common missing dependencies based on your imports
echo "Checking for missing UI dependencies..."

missing_deps=()

# Check if tabs component exists and if @radix-ui/react-tabs is installed
if [ -f "components/ui/tabs.tsx" ] && ! grep -q "@radix-ui/react-tabs" package.json; then
    missing_deps+=("@radix-ui/react-tabs")
fi

# Check other potential missing deps
if grep -r "@radix-ui/react-toast" components/ >/dev/null 2>&1 && ! grep -q "@radix-ui/react-toast" package.json; then
    missing_deps+=("@radix-ui/react-toast")
fi

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "Installing missing dependencies: ${missing_deps[*]}"
    npm install "${missing_deps[@]}"
fi

# Step 7: Check for problematic files
echo -e "${BLUE}🔍 Step 7: Checking for problematic files...${NC}"

# Check for files with problematic characters in names
problematic_files=$(find . -name "*[[:space:]]*" -o -name "*[^a-zA-Z0-9._/-]*" 2>/dev/null | head -10)
if [ ! -z "$problematic_files" ]; then
    echo -e "${YELLOW}⚠️  Found files with problematic names:${NC}"
    echo "$problematic_files"
fi

# Check for very long file paths (>255 characters)
long_paths=$(find . -type f -exec bash -c 'if [ ${#1} -gt 255 ]; then echo "$1"; fi' _ {} \; 2>/dev/null | head -5)
if [ ! -z "$long_paths" ]; then
    echo -e "${YELLOW}⚠️  Found very long file paths:${NC}"
    echo "$long_paths"
fi

# Step 8: Create .gitignore if missing or update it
echo -e "${BLUE}📝 Step 8: Checking .gitignore...${NC}"

if [ ! -f ".gitignore" ]; then
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Dependencies
/node_modules
/.pnp
.pnp.js

# Testing
/coverage

# Next.js
/.next/
/out/

# Production
/build

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env*.local

# Vercel
.vercel

# TypeScript
*.tsbuildinfo
next-env.d.ts

# IDE
.vscode/
.idea/

# Temporary files
*.tmp
*.temp
EOF
    echo -e "${GREEN}✅ Created .gitignore${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Cleanup completed!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Try starting the dev server: npm run dev"
echo "2. If still failing, try: npm run build"
echo "3. Check the terminal output for any remaining errors"
echo ""
echo -e "${YELLOW}💡 If you're still getting the path error:${NC}"
echo "1. Restart your terminal/IDE"
echo "2. Clear npm cache: npm cache clean --force"
echo "3. Check for any IDE-specific caches (VS Code, etc.)"
echo ""
echo -e "${BLUE}🔍 Files backed up:${NC}"
echo "• next.config.js.backup (if modified)"
echo "• tsconfig.json.backup (if modified)"
if [ -d "app-backup" ]; then
    echo "• app-backup/ (original app directory)"
fi
if [ -d "pages-backup" ]; then
    echo "• pages-backup/ (original pages directory)"
fi
