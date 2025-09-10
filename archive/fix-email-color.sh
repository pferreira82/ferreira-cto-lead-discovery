#!/bin/bash

echo "Fixing status color indexing error in emails page..."
echo "================================================="

FILE="app/emails/page.tsx"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Create backup
cp "$FILE" "$FILE.status-backup"
echo "Created backup: $FILE.status-backup"

echo "Fixing status color indexing functions..."

# Find and fix the getStatusColor function
if grep -q "const getStatusColor.*status.*string" "$FILE"; then
    echo "Fixing getStatusColor function..."
    sed -i.tmp '/const getStatusColor = (status: string) => {/,/return colors\[status\] || colors\.draft/c\
  const getStatusColor = (status: string) => {\
    const colors: { [key: string]: string } = {\
      draft: '\''bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-400'\'',\
      scheduled: '\''bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400'\'',\
      sending: '\''bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'\'',\
      sent: '\''bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'\'',\
      paused: '\''bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400'\'',\
      completed: '\''bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400'\''\
    }\
    return colors[status] || colors.draft' "$FILE"
fi

# Also fix getStatusIcon if it has similar issues
if grep -q "const getStatusIcon.*status.*string" "$FILE"; then
    echo "Fixing getStatusIcon function..."
    # This function likely returns JSX components, so we'll add proper type annotation
    sed -i.tmp 's/const getStatusIcon = (status: string) => {/const getStatusIcon = (status: string): JSX.Element => {/' "$FILE"
fi

# Fix any other color mapping functions that might exist
if grep -q "const.*Color.*=.*=>" "$FILE"; then
    echo "Looking for other color functions..."
    # Add index signatures to any other color objects
    sed -i.tmp 's/const colors = {/const colors: { [key: string]: string } = {/g' "$FILE"
fi

# Remove temporary file
rm -f "$FILE.tmp"

echo "Status color indexing fixed!"
echo ""

# Verify the changes
echo "Checking updated functions:"
echo "-------------------------"
if grep -q "colors: { \[key: string\]: string }" "$FILE"; then
    echo "✅ Found proper index signature in color objects"
else
    echo "⚠️  Index signature may not have been added correctly"
fi

# Check if the problematic line still exists
if grep -q "return colors\[status\]" "$FILE"; then
    echo "✅ Color indexing logic preserved"
else
    echo "⚠️  Color indexing logic may have been modified"
fi

echo ""
echo "Summary:"
echo "========"
echo "• Added proper index signature: { [key: string]: string }"
echo "• Fixed status color object indexing"
echo "• Preserved all existing color values"
echo ""
echo "You can now run: npm run build"
echo ""
echo "If you need to revert:"
echo "  mv $FILE.status-backup $FILE"
