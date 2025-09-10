#!/bin/bash

# Biotech Lead Generator - Styling Fix Script
# This script fixes common CSS and Tailwind issues

echo "🎨 Fixing styling issues..."
echo "================================"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from your project root directory."
    exit 1
fi

# 1. Install/reinstall Tailwind and dependencies
echo "📦 Installing/updating CSS dependencies..."
npm install -D tailwindcss postcss autoprefixer
npm install tailwindcss-animate

# 2. Initialize Tailwind config (this will overwrite existing)
echo "⚙️ Configuring Tailwind CSS..."
npx tailwindcss init -p

# 3. Create proper tailwind.config.js
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: 0 },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: 0 },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
EOF

# 4. Create proper PostCSS config
cat > postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# 5. Create comprehensive globals.css with all necessary styles
echo "🎨 Creating comprehensive CSS file..."
cat > app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 84% 4.9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
    --radius: 0.75rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 217.2 91.2% 59.8%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 224.3 76.3% 94.0%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  
  body {
    @apply bg-background text-foreground;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', sans-serif;
    font-feature-settings: "rlig" 1, "calt" 1;
    line-height: 1.6;
  }

  h1, h2, h3, h4, h5, h6 {
    @apply font-semibold tracking-tight;
  }

  h1 {
    @apply text-3xl;
  }

  h2 {
    @apply text-2xl;
  }

  h3 {
    @apply text-xl;
  }
}

@layer components {
  /* Professional gradients */
  .gradient-primary {
    background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%);
  }
  
  .gradient-secondary {
    background: linear-gradient(135deg, #10B981 0%, #059669 100%);
  }
  
  .gradient-accent {
    background: linear-gradient(135deg, #F59E0B 0%, #D97706 100%);
  }

  /* Card shadows */
  .card-shadow {
    box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
  }
  
  .card-shadow-lg {
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  }

  /* Loading animations */
  .animate-pulse {
    animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }

  @keyframes pulse {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: .5;
    }
  }

  /* Sidebar specific styles */
  .sidebar-nav {
    @apply flex items-center px-3 py-2.5 text-sm font-medium rounded-lg transition-all duration-200;
  }

  .sidebar-nav-active {
    @apply bg-gradient-to-r from-blue-500 to-purple-600 text-white shadow-lg shadow-blue-500/25;
  }

  .sidebar-nav-inactive {
    @apply text-slate-700 hover:bg-slate-100 hover:text-slate-900;
  }

  /* Button styles */
  .btn-gradient {
    @apply bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white shadow-lg hover:shadow-xl transition-all duration-200;
  }

  /* Table styles */
  .table-row-hover {
    @apply hover:bg-slate-50 transition-colors duration-150;
  }

  /* Input focus styles */
  .input-focus {
    @apply focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200;
  }
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-track {
  background: #f1f5f9;
}

::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
}

/* Mobile responsive adjustments */
@media (max-width: 768px) {
  .mobile-hidden {
    display: none !important;
  }
  
  .mobile-full {
    width: 100% !important;
  }
}

/* Ensure Recharts responsive container works properly */
.recharts-responsive-container {
  width: 100% !important;
  height: 100% !important;
}

/* Fix any layout issues */
.layout-fix {
  min-height: 100vh;
  background: linear-gradient(to bottom right, #f8fafc, #f1f5f9);
}

/* Sidebar positioning fix */
.sidebar-fixed {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: 16rem; /* 64 in Tailwind = 16rem */
  z-index: 50;
}

.main-content {
  margin-left: 16rem; /* Same as sidebar width */
  min-height: 100vh;
}

/* Header positioning */
.header-fixed {
  height: 4rem; /* 16 in Tailwind = 4rem */
  position: sticky;
  top: 0;
  z-index: 40;
}

/* Ensure content has proper spacing */
.content-container {
  padding: 1.5rem; /* 6 in Tailwind = 1.5rem */
}
EOF

# 6. Ensure the layout is importing globals.css correctly
echo "🔗 Fixing layout imports..."
cat > app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Sidebar } from '@/components/layout/sidebar'
import { Header } from '@/components/layout/header'

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter'
})

export const metadata: Metadata = {
  title: 'Biotech Lead Generator - Ferreira CTO',
  description: 'Technology due diligence lead generation for biotech companies',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className={`${inter.className} layout-fix`}>
        <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
          <div className="sidebar-fixed">
            <Sidebar />
          </div>
          <div className="main-content">
            <div className="header-fixed">
              <Header />
            </div>
            <main className="content-container">
              {children}
            </main>
          </div>
        </div>
      </body>
    </html>
  )
}
EOF

# 7. Create a simple test page to verify styling
echo "🧪 Creating styling test page..."
cat > app/test-styling/page.tsx << 'EOF'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

export default function TestStyling() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold text-slate-900">Styling Test Page</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="border-0 shadow-lg bg-gradient-to-br from-blue-50 to-blue-100">
          <CardHeader>
            <CardTitle className="text-blue-900">Test Card 1</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-blue-700">This should have blue gradient background</p>
            <Badge className="mt-2 bg-blue-500 text-white">Test Badge</Badge>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg bg-gradient-to-br from-purple-50 to-purple-100">
          <CardHeader>
            <CardTitle className="text-purple-900">Test Card 2</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-purple-700">This should have purple gradient background</p>
            <Button className="mt-2 bg-gradient-to-r from-blue-500 to-purple-600">
              Test Button
            </Button>
          </CardContent>
        </Card>

        <Card className="border-0 shadow-lg bg-gradient-to-br from-green-50 to-green-100">
          <CardHeader>
            <CardTitle className="text-green-900">Test Card 3</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-green-700">This should have green gradient background</p>
            <div className="mt-2 w-full h-4 bg-green-200 rounded-full">
              <div className="h-4 bg-green-500 rounded-full" style={{width: '75%'}}></div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="bg-white p-6 rounded-lg shadow-sm">
        <h2 className="text-xl font-semibold mb-4">If you can see this styled content, CSS is working!</h2>
        <div className="space-x-2">
          <Button variant="default">Primary</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="outline">Outline</Button>
        </div>
      </div>
    </div>
  )
}
EOF

# 8. Clear Next.js cache and rebuild
echo "🧹 Clearing Next.js cache..."
rm -rf .next
rm -rf node_modules/.cache

# 9. Install dependencies fresh
echo "📦 Reinstalling dependencies..."
npm install

echo ""
echo "🎉 Styling fix completed!"
echo ""
echo "📋 What was fixed:"
echo "  ✅ Reinstalled Tailwind CSS and dependencies"
echo "  ✅ Created proper Tailwind configuration"
echo "  ✅ Fixed PostCSS configuration"
echo "  ✅ Created comprehensive globals.css with all styles"
echo "  ✅ Fixed layout imports and CSS loading"
echo "  ✅ Added proper CSS variables and components"
echo "  ✅ Cleared Next.js cache"
echo "  ✅ Created test page for verification"
echo ""
echo "🚀 Next steps:"
echo "  1. npm run dev"
echo "  2. Visit http://localhost:3000 to see styled dashboard"
echo "  3. Visit http://localhost:3000/test-styling to verify CSS is working"
echo ""
echo "If you still see issues, check the browser console for errors!"
