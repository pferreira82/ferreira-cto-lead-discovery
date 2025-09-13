#!/bin/bash

echo "Fixing Discovery Page Syntax Error"
echo "=================================="

# Create a clean page.tsx file that imports the enhanced component
echo "Creating clean page.tsx file..."
cat > app/discovery/page.tsx << 'EOF'
import EnhancedLeadDiscoveryPage from './enhanced-lead-discovery-page'

export default function DiscoveryPage() {
  return <EnhancedLeadDiscoveryPage />
}
EOF

# Make sure the enhanced component exists and is properly formatted
echo "Verifying enhanced-lead-discovery-page.tsx exists..."
if [ ! -f "app/discovery/enhanced-lead-discovery-page.tsx" ]; then
    echo "❌ enhanced-lead-discovery-page.tsx not found!"
    echo "Please run the universal save setup script first to create this file."
    exit 1
fi

echo "✅ Files corrected!"
echo ""
echo "The issue was likely:"
echo "1. Missing export default in page.tsx"
echo "2. Incorrect file structure"
echo "3. Syntax error in JSX return statement"
echo ""
echo "Now your page.tsx simply imports and renders the enhanced component."
echo "Try accessing /discovery again - it should work now!"
echo ""
echo "If you still get errors, check that:"
echo "1. app/discovery/enhanced-lead-discovery-page.tsx exists"
echo "2. All imports in that file are correct"
echo "3. No missing closing braces or brackets"
