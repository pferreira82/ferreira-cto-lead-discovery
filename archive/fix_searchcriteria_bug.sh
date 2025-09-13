#!/bin/bash

echo "Fixing searchCriteria Bug in Discovery Page"
echo "==========================================="

# Find the discovery page file
DISCOVERY_PAGE="app/discovery/enhanced-lead-discovery-page.tsx"
DISCOVERY_PAGE_ALT="app/discovery/page.tsx"

if [[ -f "$DISCOVERY_PAGE" ]]; then
    TARGET_FILE="$DISCOVERY_PAGE"
elif [[ -f "$DISCOVERY_PAGE_ALT" ]]; then
    TARGET_FILE="$DISCOVERY_PAGE_ALT"
else
    echo "❌ Error: Could not find discovery page"
    exit 1
fi

echo "📄 Found discovery page: $TARGET_FILE"

# Create backup
BACKUP_FILE="${TARGET_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$TARGET_FILE" "$BACKUP_FILE"
echo "💾 Backup created: $BACKUP_FILE"

# Fix the searchCriteria -> searchParams bug
echo "🔧 Fixing variable name mismatch..."

# Replace searchCriteria with searchParams in the Apollo service call
sed -i.tmp 's/searchCriteria,/searchParams,/g' "$TARGET_FILE"
rm "${TARGET_FILE}.tmp"

echo ""
echo "✅ Bug Fixed!"
echo "============"
echo ""
echo "Fixed Issues:"
echo "• Changed 'searchCriteria' to 'searchParams' in Apollo service call"
echo "• Demo search should now work without 'is not defined' error"
echo ""
echo "The search function should now work correctly in both demo and production modes."
echo ""
