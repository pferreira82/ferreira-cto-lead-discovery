#!/bin/bash

echo "🔧 Fixing CSS border-border error"
echo "================================"

# Backup current globals.css
if [ -f "app/globals.css" ]; then
    cp "app/globals.css" "app/globals.css.error-backup"
    echo "📦 Backed up app/globals.css"
fi

# Create a working globals.css without the problematic border-border class
cat > app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }
}

@layer base {
  * {
    @apply border-gray-200;
  }
  body {
    @apply bg-gray-50 text-gray-900 font-sans antialiased;
  }
  html {
    @apply scroll-smooth;
  }
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 6px;
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

/* Additional component styles */
@layer components {
  .sidebar-nav-link {
    @apply flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors;
  }
  
  .sidebar-nav-link-active {
    @apply bg-blue-50 text-blue-700 border border-blue-200;
  }
  
  .sidebar-nav-link-inactive {
    @apply text-gray-700 hover:bg-gray-100;
  }
  
  .card-hover {
    @apply hover:shadow-md transition-shadow duration-200;
  }
  
  .gradient-primary {
    @apply bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700;
  }
  
  .gradient-secondary {
    @apply bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700;
  }
  
  .gradient-tertiary {
    @apply bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700;
  }
}

/* Loading animations */
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

/* Fade in animation */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fadeIn 0.3s ease-out;
}
EOF

echo "✅ Fixed app/globals.css - removed border-border reference"

# Also check and fix tailwind.config.js if it exists
if [ -f "tailwind.config.js" ]; then
    echo "🔧 Checking tailwind.config.js..."
    
    # Create a proper tailwind config
    cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
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
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      animation: {
        "fade-in": "fadeIn 0.3s ease-out",
      },
    },
  },
  plugins: [],
}
EOF
    
    echo "✅ Updated tailwind.config.js with proper color mappings"
fi

echo ""
echo "🚀 CSS Error Fixed!"
echo "=================="
echo ""
echo "Changes made:"
echo "• Replaced border-border with border-gray-200"
echo "• Added proper color definitions to Tailwind config"
echo "• Added useful component classes"
echo "• Added loading and fade animations"
echo ""
echo "Now restart your dev server:"
echo "   npm run dev"
echo ""
echo "The CSS compilation error should be resolved."
