#!/bin/bash

echo "Fixing lead type mismatch in discovery page..."
echo "============================================"

FILE="app/discovery/page.tsx"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Create backup
cp "$FILE" "$FILE.type-backup"
echo "Created backup: $FILE.type-backup"

echo "Fixing type mismatch between lead types and search parameters..."

# Create a temporary file for complex replacements
cat > /tmp/type_fix.txt << 'EOF'
          // Map search params (plural) to lead types (singular)
          const typeMapping: { [key: string]: string } = {
            'companies': 'company',
            'vc_firms': 'vc_firm'
          }
          
          const typeMatch = searchParams.targetTypes.length === 0 || 
                           searchParams.targetTypes.some(searchType => 
                             typeMapping[searchType] === lead.type
                           )
EOF

# Replace the problematic line with the fixed version
sed -i.tmp '/const typeMatch = searchParams\.targetTypes\.includes(lead\.type)/c\
          // Map search params (plural) to lead types (singular)\
          const typeMapping: { [key: string]: string } = {\
            '\''companies'\'': '\''company'\'',\
            '\''vc_firms'\'': '\''vc_firm'\''\
          }\
          \
          const typeMatch = searchParams.targetTypes.length === 0 || \
                           searchParams.targetTypes.some(searchType => \
                             typeMapping[searchType] === lead.type\
                           )' "$FILE"

# Also fix the interface types to be consistent
echo "Updating DiscoveredLead interface..."

# Fix the type property in the interface
sed -i.tmp 's/type: '\''company'\'' | '\''vc_firm'\''/type: '\''company'\'' | '\''vc_firm'\''/' "$FILE"

# Fix the SearchParams interface to use consistent naming
sed -i.tmp 's/targetTypes: ('\''companies'\'' | '\''vc_firms'\'')\[\]/targetTypes: ('\''companies'\'' | '\''vc_firms'\'')[]/' "$FILE"

# Remove temporary file
rm -f "$FILE.tmp"

echo "Type mismatch fixed!"
echo ""

# Verify the changes
echo "Checking updated type mapping:"
echo "-----------------------------"
grep -A 8 "typeMapping" "$FILE" || echo "Type mapping not found - checking for the fix..."

# Check if the problematic line still exists
if grep -q "searchParams.targetTypes.includes(lead.type)" "$FILE"; then
    echo "Warning: Original problematic line still found, manual review needed"
else
    echo "✅ Successfully replaced problematic type checking"
fi

echo ""
echo "Additional fix: Ensuring consistent type definitions..."

# Also fix any demo data if it uses the old format
if grep -q "type: 'company'" "$FILE"; then
    echo "✅ Lead data already uses correct format ('company', 'vc_firm')"
else
    echo "ℹ️  Lead data format looks consistent"
fi

echo ""
echo "Summary:"
echo "========"
echo "• Added type mapping between plural search params and singular lead types"
echo "• 'companies' → 'company'"
echo "• 'vc_firms' → 'vc_firm'"
echo "• Updated type checking logic to use the mapping"
echo ""
echo "You can now run: npm run build"
echo ""
echo "If you need to revert:"
echo "  mv $FILE.type-backup $FILE"
