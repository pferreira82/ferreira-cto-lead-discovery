#!/bin/bash

echo "Quick fix for apollo-debug.ts TypeScript error"
echo "============================================="

# Fix the specific line that's causing the error
if [ -f "app/api/debug/apollo-debug.ts" ]; then
    echo "Fixing apollo-debug.ts implicit 'any' type error..."
    
    # Create backup
    cp "app/api/debug/apollo-debug.ts" "app/api/debug/apollo-debug.ts.backup"
    
    # Fix the specific line by adding explicit type annotation
    sed -i.tmp 's/detailedResults\.filter(r =>/detailedResults.filter((r: any) =>/g' "app/api/debug/apollo-debug.ts"
    
    # Also fix any map/forEach functions that might have the same issue
    sed -i.tmp 's/organizations\.map((org: any, index: number)/organizations.map((org: any, index: number)/g' "app/api/debug/apollo-debug.ts"
    sed -i.tmp 's/detailedResults\.forEach(result =>/detailedResults.forEach((result: any) =>/g' "app/api/debug/apollo-debug.ts"
    
    # Clean up temp file
    rm -f "app/api/debug/apollo-debug.ts.tmp"
    
    echo "✅ Fixed implicit 'any' type errors in apollo-debug.ts"
    echo "Backup saved as: app/api/debug/apollo-debug.ts.backup"
else
    echo "❌ app/api/debug/apollo-debug.ts not found"
fi

echo ""
echo "Now try: npm run build"
