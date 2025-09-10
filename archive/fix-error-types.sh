#!/bin/bash

echo "Fixing error type handling in email-settings page..."
echo "=================================================="

FILE="app/email-settings/page.tsx"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Create backup
cp "$FILE" "$FILE.error-backup"
echo "Created backup: $FILE.error-backup"

echo "Fixing error type handling..."

# Replace the problematic error handling block
sed -i.tmp '/let errorMessage = '\''Failed to test email configuration'\''/,/toast\.error(errorMessage)/c\
      let errorMessage = '\''Failed to test email configuration'\''\
      if (error instanceof Error) {\
        if (error.message.includes('\''JSON'\'')) {\
          errorMessage = '\''API endpoint returned invalid response (likely HTML instead of JSON)'\''\
        } else if (error.message.includes('\''fetch'\'')) {\
          errorMessage = '\''Network error - could not reach API endpoint'\''\
        }\
      }\
      \
      setTestResult({ \
        success: false, \
        message: errorMessage,\
        details: error instanceof Error ? error.message : String(error)\
      })\
      toast.error(errorMessage)' "$FILE"

# Also fix any other error handling blocks that might have similar issues
echo "Checking for other error handling blocks..."

# Fix any other instances where error.message is accessed directly
sed -i.tmp 's/error\.message/error instanceof Error ? error.message : String(error)/g' "$FILE"

# Remove temporary file
rm -f "$FILE.tmp"

echo "Error type handling fixed!"
echo ""

# Verify the changes
echo "Checking for proper error handling:"
echo "----------------------------------"
if grep -q "error instanceof Error" "$FILE"; then
    echo "✅ Found proper instanceof Error checks"
else
    echo "⚠️  No instanceof checks found - manual review may be needed"
fi

# Check if any direct error.message access remains
if grep -q "error\.message" "$FILE"; then
    echo "⚠️  Direct error.message access still found - may need additional fixes"
else
    echo "✅ No direct error.message access found"
fi

echo ""
echo "Summary:"
echo "========"
echo "• Added 'error instanceof Error' type guards"
echo "• Protected all error.message access with type checks"
echo "• Used String(error) fallback for non-Error objects"
echo ""
echo "You can now run: npm run build"
echo ""
echo "If you need to revert:"
echo "  mv $FILE.error-backup $FILE"
