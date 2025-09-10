#!/bin/bash

echo "Fixing Set iteration TypeScript error..."
echo "======================================"

# Fix 1: Update tsconfig.json to use ES2015+ target
echo "Updating tsconfig.json..."

if [ -f "tsconfig.json" ]; then
    cp tsconfig.json tsconfig.json.set-backup
    echo "Created backup: tsconfig.json.set-backup"
    
    # Update target and add downlevelIteration
    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es2017",
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
    "downlevelIteration": true,
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
    echo "Updated tsconfig.json with ES2017 target and downlevelIteration"
else
    echo "tsconfig.json not found, creating new one..."
    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es2017",
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
    "downlevelIteration": true,
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
    echo "Created new tsconfig.json"
fi

echo ""
echo "Fix 2: Alternative - Replace Set spread with Array.from (if still needed)"

FILE="app/companies/page.tsx"
if [ -f "$FILE" ]; then
    cp "$FILE" "$FILE.set-backup"
    echo "Created backup: $FILE.set-backup"
    
    # Replace Set spread syntax with Array.from
    sed -i.tmp 's/\[\.\.\.\(new Set([^]]*)\)\]/Array.from(\1)/g' "$FILE"
    
    # Remove temporary file
    rm -f "$FILE.tmp"
    
    echo "Replaced Set spread operators with Array.from() in $FILE"
else
    echo "$FILE not found"
fi

echo ""
echo "Summary of changes:"
echo "==================="
echo "1. Updated tsconfig.json:"
echo "   - Set target to 'es2017'"
echo "   - Added 'downlevelIteration': true"
echo ""
echo "2. Alternative fix applied to companies page:"
echo "   - [...new Set(...)] → Array.from(new Set(...))"
echo ""
echo "You can now run: npm run build"
echo ""
echo "If you need to revert changes:"
echo "  mv tsconfig.json.set-backup tsconfig.json"
echo "  mv $FILE.set-backup $FILE"
