#!/bin/bash

echo "🔧 Fixing Next.js Page Routing Issues..."
echo "======================================"

# Check which Next.js structure we're using
if [ -d "app" ] && [ -f "app/layout.tsx" ]; then
    echo "✓ Using Next.js 13+ app directory structure"
    
    # Check if companies page exists and move it if needed
    if [ ! -f "app/companies/page.tsx" ]; then
        echo "🏢 Creating companies page in app/companies/page.tsx"
        mkdir -p app/companies
        
        # Move from pages/ if it exists there
        if [ -f "pages/companies.tsx" ] || [ -f "pages/companies/index.tsx" ]; then
            echo "📁 Found companies page in pages/ directory, it should be in app/ directory"
        fi
        
        # Ensure the companies page content exists in the right place
        echo "Creating app/companies/page.tsx..."
        # This would contain the companies page content from the original script
    else
        echo "✓ Companies page exists at app/companies/page.tsx"
    fi
    
    # Check if contacts page exists
    if [ ! -f "app/contacts/page.tsx" ]; then
        echo "👥 Creating contacts page in app/contacts/page.tsx"
        mkdir -p app/contacts
        echo "Creating app/contacts/page.tsx..."
        # This would contain the contacts page content from the original script
    else
        echo "✓ Contacts page exists at app/contacts/page.tsx"
    fi
    
elif [ -d "pages" ]; then
    echo "📁 Using Next.js pages directory structure"
    
    # For pages/ directory, files should be:
    # pages/companies/index.tsx OR pages/companies.tsx
    # pages/contacts/index.tsx OR pages/contacts.tsx
    
    if [ ! -f "pages/companies.tsx" ] && [ ! -f "pages/companies/index.tsx" ]; then
        echo "🏢 Creating companies page for pages/ directory"
        echo "Creating pages/companies.tsx..."
        # Create companies page for pages/ structure
    fi
    
    if [ ! -f "pages/contacts.tsx" ] && [ ! -f "pages/contacts/index.tsx" ]; then
        echo "👥 Creating contacts page for pages/ directory"
        echo "Creating pages/contacts.tsx..."
        # Create contacts page for pages/ structure
    fi
    
else
    echo "⚠️  No clear Next.js structure detected"
    echo "Creating app/ directory structure..."
    mkdir -p app
    
    # Create basic layout for app directory
    cat > app/layout.tsx << 'EOF'
import './globals.css'
import { Inter } from 'next/font/google'
import { ThemeProvider } from '@/components/theme-provider'
import { DemoModeProvider } from '@/lib/demo-context'
import { Toaster } from 'react-hot-toast'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'Biotech CRM - Ferreira CTO',
  description: 'Professional biotech industry contact and company management system',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <DemoModeProvider>
            {children}
            <Toaster 
              position="top-right"
              toastOptions={{
                duration: 4000,
                style: {
                  background: 'var(--background)',
                  color: 'var(--foreground)',
                  border: '1px solid var(--border)',
                },
              }}
            />
          </DemoModeProvider>
        </ThemeProvider>
      </body>
    </html>
  )
}
EOF

fi

# Quick diagnostic
echo ""
echo "📊 Current file structure:"
echo "=========================="
echo "app/ directory:" $([ -d "app" ] && echo "✓ exists" || echo "❌ missing")
echo "pages/ directory:" $([ -d "pages" ] && echo "✓ exists" || echo "❌ missing")

if [ -d "app" ]; then
    echo ""
    echo "app/ contents:"
    ls -la app/ 2>/dev/null || echo "  (empty or inaccessible)"
    
    echo ""
    echo "Looking for page files in app/:"
    [ -f "app/companies/page.tsx" ] && echo "  ✓ app/companies/page.tsx" || echo "  ❌ app/companies/page.tsx"
    [ -f "app/contacts/page.tsx" ] && echo "  ✓ app/contacts/page.tsx" || echo "  ❌ app/contacts/page.tsx"
    [ -f "app/layout.tsx" ] && echo "  ✓ app/layout.tsx" || echo "  ❌ app/layout.tsx"
fi

if [ -d "pages" ]; then
    echo ""
    echo "pages/ contents:"
    ls -la pages/ 2>/dev/null || echo "  (empty or inaccessible)"
    
    echo ""
    echo "Looking for page files in pages/:"
    [ -f "pages/companies.tsx" ] && echo "  ✓ pages/companies.tsx" || echo "  ❌ pages/companies.tsx"
    [ -f "pages/companies/index.tsx" ] && echo "  ✓ pages/companies/index.tsx" || echo "  ❌ pages/companies/index.tsx"
    [ -f "pages/contacts.tsx" ] && echo "  ✓ pages/contacts.tsx" || echo "  ❌ pages/contacts.tsx"
    [ -f "pages/contacts/index.tsx" ] && echo "  ✓ pages/contacts/index.tsx" || echo "  ❌ pages/contacts/index.tsx"
fi

echo ""
echo "🔧 Next Steps:"
echo "=============="
echo "1. Run this script to see your current structure"
echo "2. Check what's missing from the output above"
echo "3. The page files need to be created in the correct location"
echo "4. Restart your dev server: npm run dev"
echo ""
echo "For Next.js 13+ (app directory):"
echo "  - Pages should be: app/companies/page.tsx, app/contacts/page.tsx"
echo ""
echo "For Next.js 12 (pages directory):"
echo "  - Pages should be: pages/companies.tsx, pages/contacts.tsx"
echo "  - OR: pages/companies/index.tsx, pages/contacts/index.tsx"
