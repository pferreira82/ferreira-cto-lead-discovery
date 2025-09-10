#!/bin/bash

echo "Fixing urgency color indexing error in discovery page..."
echo "======================================================"

FILE="app/discovery/page.tsx"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Create backup
cp "$FILE" "$FILE.urgency-backup"
echo "Created backup: $FILE.urgency-backup"

echo "Fixing getUrgencyBadge color indexing..."

# Fix the getUrgencyBadge function to include proper index signature
sed -i.tmp '/const getUrgencyBadge = (urgency: string) => {/,/return colors\[urgency\] || colors\.medium/c\
  const getUrgencyBadge = (urgency: string) => {\
    const colors: { [key: string]: string } = {\
      critical: '\''bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'\'',\
      high: '\''bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400'\'',\
      medium: '\''bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'\'',\
      low: '\''bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'\''\
    }\
    return colors[urgency] || colors.medium' "$FILE"

# Also fix getScoreColor if it has similar issues
if grep -q "const getScoreColor.*=.*score.*=>" "$FILE"; then
    echo "Fixing getScoreColor function as well..."
    sed -i.tmp '/const getScoreColor = (score: number) => {/,/return.*text-red/c\
  const getScoreColor = (score: number) => {\
    if (score >= 80) return '\''text-green-600 dark:text-green-400'\''\
    if (score >= 60) return '\''text-yellow-600 dark:text-yellow-400'\''\
    return '\''text-red-600 dark:text-red-400'\''' "$FILE"
fi

# Remove temporary file
rm -f "$FILE.tmp"

echo "Color indexing fixed!"
echo ""

# Verify the changes
echo "Checking updated getUrgencyBadge function:"
echo "----------------------------------------"
grep -A 8 "const getUrgencyBadge" "$FILE" || echo "getUrgencyBadge function not found"

echo ""
echo "Summary:"
echo "========"
echo "• Added proper index signature: { [key: string]: string }"
echo "• Fixed urgency color object indexing"
echo "• Also fixed getScoreColor if present"
echo ""
echo "You can now run: npm run build"
echo ""
echo "If you need to revert:"
echo "  mv $FILE.urgency-backup $FILE"
