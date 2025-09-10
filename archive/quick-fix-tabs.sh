#!/bin/bash

echo "🔧 Quick Fix: Installing missing @radix-ui/react-tabs"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ No package.json found. Run this from your project root."
    exit 1
fi

# Check if the tabs component exists and is causing the issue
if [ -f "components/ui/tabs.tsx" ]; then
    echo "📄 Found components/ui/tabs.tsx"
    
    # Check if it imports @radix-ui/react-tabs
    if grep -q "@radix-ui/react-tabs" components/ui/tabs.tsx; then
        echo "🔍 Confirmed: tabs.tsx imports @radix-ui/react-tabs"
        
        # Check if package is already installed
        if grep -q '"@radix-ui/react-tabs"' package.json; then
            echo "✅ @radix-ui/react-tabs is already installed"
            echo "The issue might be with your node_modules. Try:"
            echo "   rm -rf node_modules package-lock.json"
            echo "   npm install"
        else
            echo "❌ @radix-ui/react-tabs is NOT installed"
            echo ""
            echo "🚀 Installing @radix-ui/react-tabs..."
            
            if npm install @radix-ui/react-tabs; then
                echo "✅ Successfully installed @radix-ui/react-tabs!"
                echo ""
                echo "🔧 Next steps:"
                echo "1. Try building again: npm run build"
                echo "2. If still failing, restart dev server: npm run dev"
                echo "3. Clear Next.js cache if needed: rm -rf .next && npm run build"
            else
                echo "❌ Failed to install @radix-ui/react-tabs"
                echo "Try manually: npm install @radix-ui/react-tabs"
                exit 1
            fi
        fi
    else
        echo "⚠️  tabs.tsx doesn't import @radix-ui/react-tabs"
        echo "The error might be coming from a different file"
    fi
else
    echo "⚠️  No components/ui/tabs.tsx found"
    echo "The tabs import might be in a different file"
    echo ""
    echo "🔍 Searching for @radix-ui/react-tabs imports..."
    
    # Search for the import in all files
    files_with_tabs_import=$(find . -name "*.tsx" -o -name "*.ts" | xargs grep -l "@radix-ui/react-tabs" 2>/dev/null)
    
    if [ ! -z "$files_with_tabs_import" ]; then
        echo "Found @radix-ui/react-tabs imports in:"
        echo "$files_with_tabs_import"
        echo ""
        echo "🚀 Installing @radix-ui/react-tabs..."
        
        if npm install @radix-ui/react-tabs; then
            echo "✅ Successfully installed @radix-ui/react-tabs!"
        else
            echo "❌ Failed to install @radix-ui/react-tabs"
            exit 1
        fi
    else
        echo "❌ No @radix-ui/react-tabs imports found"
        echo "The error might be in a different location"
    fi
fi

echo ""
echo "📋 Installation complete!"
echo ""
echo "If you're still getting errors, run the comprehensive scan:"
echo "   chmod +x fix-missing-radix-deps.sh"
echo "   ./fix-missing-radix-deps.sh"
