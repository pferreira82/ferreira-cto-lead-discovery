#!/bin/bash

echo "Fixing theme provider types import..."
echo "==================================="

FILE="components/theme-provider.tsx"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Create backup
cp "$FILE" "$FILE.types-backup"
echo "Created backup: $FILE.types-backup"

echo "Fixing types import in theme provider..."

# Method 1: Try importing types directly from next-themes
sed -i.tmp "s|import { type ThemeProviderProps } from 'next-themes/dist/types'|import { ThemeProviderProps } from 'next-themes'|" "$FILE"

# Check if that worked, if not try alternative approaches
if grep -q "next-themes/dist/types" "$FILE"; then
    echo "First method didn't work, trying alternative..."
    
    # Method 2: Use React.ComponentProps to infer types
    sed -i.tmp "s|import { type ThemeProviderProps } from 'next-themes/dist/types'|// Types inferred from NextThemesProvider|" "$FILE"
    
    # Update the component signature to use inferred types
    sed -i.tmp 's|export function ThemeProvider({ children, ...props }: ThemeProviderProps)|export function ThemeProvider({ children, ...props }: React.ComponentProps<typeof NextThemesProvider>)|' "$FILE"
fi

# Method 3: If still having issues, create a simple working version
if grep -q "next-themes/dist/types" "$FILE" || ! grep -q "NextThemesProvider" "$FILE"; then
    echo "Creating simplified working version..."
    
    cat > "$FILE" << 'EOF'
'use client'

import * as React from 'react'
import { ThemeProvider as NextThemesProvider } from 'next-themes'

interface ThemeProviderProps {
  children: React.ReactNode
  attribute?: string
  defaultTheme?: string
  enableSystem?: boolean
  disableTransitionOnChange?: boolean
}

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
EOF

    echo "Created simplified working version with manual types"
fi

# Remove temporary file
rm -f "$FILE.tmp"

echo "Theme provider types fixed!"
echo ""

# Verify the fix
echo "Checking updated theme provider:"
echo "-------------------------------"
cat "$FILE"

echo ""

# Check if the problematic import is gone
if grep -q "next-themes/dist/types" "$FILE"; then
    echo "❌ Still contains problematic import"
else
    echo "✅ Problematic import removed"
fi

# Check if valid imports exist
if grep -q "from 'next-themes'" "$FILE"; then
    echo "✅ Valid next-themes import found"
else
    echo "❌ No next-themes import found"
fi

echo ""
echo "Summary:"
echo "========"
echo "• Fixed types import from next-themes"
echo "• Removed problematic /dist/types path"
echo "• Created working ThemeProvider component"
echo ""
echo "You can now run: npm run build"
echo ""
echo "If you need to revert:"
echo "  mv $FILE.types-backup $FILE"
