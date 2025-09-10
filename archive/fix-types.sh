#!/bin/bash

echo "Fixing Company interface types to allow null values..."
echo "===================================================="

FILE="app/companies/page.tsx"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Create backup
cp "$FILE" "$FILE.backup"
echo "Created backup: $FILE.backup"

# Fix the Company interface to allow null values
echo "Updating Company interface..."

# Replace string | undefined with string | null for optional fields
sed -i.tmp 's/website?: string$/website?: string | null/g' "$FILE"
sed -i.tmp 's/description?: string$/description?: string | null/g' "$FILE"  
sed -i.tmp 's/crunchbase_url?: string$/crunchbase_url?: string | null/g' "$FILE"
sed -i.tmp 's/linkedin_url?: string$/linkedin_url?: string | null/g' "$FILE"

# Replace number | undefined with number | null for optional fields  
sed -i.tmp 's/total_funding?: number$/total_funding?: number | null/g' "$FILE"
sed -i.tmp 's/employee_count?: number$/employee_count?: number | null/g' "$FILE"
sed -i.tmp 's/last_funding_date?: string$/last_funding_date?: string | null/g' "$FILE"

# Also handle cases where undefined is explicitly mentioned
sed -i.tmp 's/| undefined/| null/g' "$FILE"

# Remove temporary file created by sed
rm -f "$FILE.tmp"

echo "Interface updates complete!"
echo ""

# Show the changes made
echo "Checking for Company interface in updated file:"
echo "-----------------------------------------------"
grep -A 15 "interface Company" "$FILE" || echo "Interface not found with exact match - checking for variations..."

# Alternative search if exact match not found
if ! grep -q "interface Company" "$FILE"; then
    echo "Searching for interface definitions..."
    grep -A 15 "interface.*Company\|Company.*interface" "$FILE" || echo "No Company interface found"
fi

echo ""
echo "Changes applied! You can now run:"
echo "  npm run build"
echo ""
echo "If you need to revert changes:"  
echo "  mv $FILE.backup $FILE"
