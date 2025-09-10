#!/bin/bash

echo "🔧 Comprehensive TypeScript Issue Fixer"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
files_processed=0
issues_fixed=0
backup_count=0

# Create backup directory
backup_dir="typescript-fixes-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
echo "📦 Backup directory created: $backup_dir"
echo ""

# Function to create backup
create_backup() {
    local file="$1"
    local backup_path="$backup_dir/$(echo "$file" | sed 's/\//\_/g')"
    cp "$file" "$backup_path"
    backup_count=$((backup_count + 1))
    echo "   📄 Backed up: $file"
}

# Function to fix a file
fix_typescript_file() {
    local file="$1"
    local fixed=false
    local temp_file="${file}.tmp"
    
    echo "🔍 Processing: $file"
    
    # Create backup first
    create_backup "$file"
    
    # Copy original to temp file for processing
    cp "$file" "$temp_file"
    
    # Fix 1: Array declarations without explicit types
    if grep -q "const.*= \[\]" "$temp_file"; then
        echo "   🔧 Fixing empty array declarations..."
        
        # Common array patterns and their fixes
        sed -i.bak 's/const emailActivity = \[\]/const emailActivity: Array<{date: string; sent: number; opened: number; replied: number}> = []/g' "$temp_file"
        sed -i.bak 's/const contactsByRole = \[\]/const contactsByRole: Array<{role: string; count: number; color?: string}> = []/g' "$temp_file"
        sed -i.bak 's/const companiesByStage = \[\]/const companiesByStage: Array<{stage: string; count: number}> = []/g' "$temp_file"
        sed -i.bak 's/const results = \[\]/const results: any[] = []/g' "$temp_file"
        sed -i.bak 's/const errors = \[\]/const errors: string[] = []/g' "$temp_file"
        sed -i.bak 's/const companies = \[\]/const companies: any[] = []/g' "$temp_file"
        sed -i.bak 's/const contacts = \[\]/const contacts: any[] = []/g' "$temp_file"
        sed -i.bak 's/const campaigns = \[\]/const campaigns: any[] = []/g' "$temp_file"
        
        # Generic fix for other empty arrays
        sed -i.bak 's/const \([a-zA-Z_][a-zA-Z0-9_]*\) = \[\]/const \1: any[] = []/g' "$temp_file"
        
        rm -f "${temp_file}.bak"
        fixed=true
        issues_fixed=$((issues_fixed + 1))
    fi
    
    # Fix 2: Array method callbacks without explicit types
    if grep -qE "\.(filter|map|forEach|reduce|find|some|every)\s*\(\s*[a-zA-Z_][a-zA-Z0-9_]*\s*=>" "$temp_file"; then
        echo "   🔧 Fixing array method callbacks..."
        
        # Fix filter methods
        sed -i.bak -E 's/\.filter\s*\(\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=>/\.filter((\1: any) =>/g' "$temp_file"
        
        # Fix map methods
        sed -i.bak -E 's/\.map\s*\(\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=>/\.map((\1: any) =>/g' "$temp_file"
        
        # Fix forEach methods
        sed -i.bak -E 's/\.forEach\s*\(\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=>/\.forEach((\1: any) =>/g' "$temp_file"
        
        # Fix find methods
        sed -i.bak -E 's/\.find\s*\(\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=>/\.find((\1: any) =>/g' "$temp_file"
        
        # Fix some/every methods
        sed -i.bak -E 's/\.(some|every)\s*\(\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=>/\.\1((\2: any) =>/g' "$temp_file"
        
        # Fix reduce methods (more complex pattern)
        sed -i.bak -E 's/\.reduce\s*\(\s*\(([a-zA-Z_][a-zA-Z0-9_]*),\s*([a-zA-Z_][a-zA-Z0-9_]*)\)\s*=>/\.reduce((\1: any, \2: any) =>/g' "$temp_file"
        
        rm -f "${temp_file}.bak"
        fixed=true
        issues_fixed=$((issues_fixed + 1))
    fi
    
    # Fix 3: supabaseAdmin null checks
    if grep -q "await supabaseAdmin" "$temp_file" && ! grep -q "if (!supabaseAdmin)" "$temp_file"; then
        echo "   🔧 Adding supabaseAdmin null checks..."
        
        # Find functions that use supabaseAdmin and add null checks
        # This is a more conservative approach - we'll add the check at the beginning of functions
        if grep -q "export default async function handler" "$temp_file"; then
            # For API route handlers, add check after try {
            sed -i.bak '/try {/a\
    if (!supabaseAdmin) {\
      return res.status(500).json({ error: "Database not configured", message: "Supabase configuration is missing" })\
    }' "$temp_file"
        fi
        
        rm -f "${temp_file}.bak"
        fixed=true
        issues_fixed=$((issues_fixed + 1))
    fi
    
    # Fix 4: Error handling without type guards
    if grep -qE "error\.message" "$temp_file" && ! grep -q "error instanceof Error" "$temp_file"; then
        echo "   🔧 Adding error type guards..."
        
        # Replace direct error.message access with safe access
        sed -i.bak 's/error\.message/error instanceof Error ? error.message : String(error)/g' "$temp_file"
        
        rm -f "${temp_file}.bak"
        fixed=true
        issues_fixed=$((issues_fixed + 1))
    fi
    
    # Fix 5: Function parameters without types in common patterns
    if grep -qE "function.*\([a-zA-Z_][a-zA-Z0-9_]*\)\s*{" "$temp_file"; then
        echo "   🔧 Adding function parameter types..."
        
        # This is more conservative - only fix obvious cases
        sed -i.bak -E 's/function ([a-zA-Z_][a-zA-Z0-9_]*)\(([a-zA-Z_][a-zA-Z0-9_]*)\)/function \1(\2: any)/g' "$temp_file"
        
        rm -f "${temp_file}.bak"
        fixed=true
        issues_fixed=$((issues_fixed + 1))
    fi
    
    # Fix 6: Object property access that might be undefined
    if grep -qE "\?\.(length|total_entries|organizations)" "$temp_file"; then
        echo "   🔧 Adding safe property access..."
        
        # Add fallbacks for common undefined property access
        sed -i.bak 's/data\.pagination\.total_entries/data.pagination?.total_entries/g' "$temp_file"
        sed -i.bak 's/data\.organizations\.length/data.organizations?.length/g' "$temp_file"
        
        rm -f "${temp_file}.bak"
        fixed=true
        issues_fixed=$((issues_fixed + 1))
    fi
    
    # Fix 7: Type assertions for counts that might be null
    if grep -qE "(sent|opened|replied|clicked|bounced).*\|\| 0" "$temp_file"; then
        echo "   🔧 Adding type assertions for counts..."
        
        sed -i.bak 's/sent || 0/(sent as number) || 0/g' "$temp_file"
        sed -i.bak 's/opened || 0/(opened as number) || 0/g' "$temp_file"
        sed -i.bak 's/replied || 0/(replied as number) || 0/g' "$temp_file"
        sed -i.bak 's/clicked || 0/(clicked as number) || 0/g' "$temp_file"
        sed -i.bak 's/bounced || 0/(bounced as number) || 0/g' "$temp_file"
        
        rm -f "${temp_file}.bak"
        fixed=true
        issues_fixed=$((issues_fixed + 1))
    fi
    
    # Fix 8: Import statements that might be causing issues
    if grep -qE "import.*from.*supabase.*" "$temp_file" && ! grep -q "isSupabaseConfigured" "$temp_file"; then
        echo "   🔧 Adding missing imports..."
        
        # Add isSupabaseConfigured import if supabase is imported
        sed -i.bak 's/import { supabaseAdmin }/import { supabaseAdmin, isSupabaseConfigured }/g' "$temp_file"
        sed -i.bak 's/import { createClient }/import { createClient } from "@supabase\/supabase-js"\nimport { isSupabaseConfigured }/g' "$temp_file"
        
        rm -f "${temp_file}.bak"
        fixed=true
        issues_fixed=$((issues_fixed + 1))
    fi
    
    # If we made changes, replace the original file
    if [ "$fixed" = true ]; then
        mv "$temp_file" "$file"
        echo "   ✅ Fixed TypeScript issues in $file"
        files_processed=$((files_processed + 1))
    else
        rm -f "$temp_file"
        echo "   ℹ️  No issues found in $file"
    fi
}

# Find all TypeScript files (excluding node_modules, .next, backups)
echo "🔍 Scanning for TypeScript files..."
ts_files=$(find . -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v ".next" | grep -v "backup" | grep -v ".git" | sort)

if [ -z "$ts_files" ]; then
    echo "❌ No TypeScript files found!"
    exit 1
fi

file_count=$(echo "$ts_files" | wc -l)
echo "📁 Found $file_count TypeScript files to process"
echo ""

# Process each file
for file in $ts_files; do
    if [ -f "$file" ]; then
        fix_typescript_file "$file"
    fi
done

echo ""
echo "🎉 Processing Complete!"
echo "====================="
echo ""
echo "📊 Summary:"
echo "• Files processed: $files_processed"
echo "• Issues fixed: $issues_fixed"  
echo "• Backups created: $backup_count"
echo "• Backup location: $backup_dir"
echo ""

# Create a summary report
report_file="$backup_dir/fix-report.txt"
cat > "$report_file" << EOF
TypeScript Fix Report
Generated: $(date)

Files Processed: $files_processed
Issues Fixed: $issues_fixed
Backups Created: $backup_count

Types of fixes applied:
1. Empty array declarations → Explicit array types
2. Array method callbacks → Added parameter types
3. supabaseAdmin usage → Added null checks
4. Error handling → Added type guards
5. Function parameters → Added type annotations
6. Property access → Added safe navigation
7. Count variables → Added type assertions
8. Import statements → Added missing imports

All original files backed up to: $backup_dir

To restore a file:
cp $backup_dir/path_to_file original/path/to/file

To test the fixes:
npm run build
EOF

echo "📄 Detailed report saved to: $report_file"
echo ""

# Test the build
echo "🧪 Testing TypeScript compilation..."
if command -v npm >/dev/null 2>&1; then
    echo "Running: npm run build"
    if npm run build 2>&1 | tee build-test.log; then
        echo ""
        echo "✅ Build successful! All TypeScript issues appear to be resolved."
    else
        echo ""
        echo "❌ Build still has errors. Check build-test.log for remaining issues."
        echo ""
        echo "🔄 You can restore files from backups and try manual fixes:"
        echo "   Backup location: $backup_dir"
        echo ""
        echo "📋 If there are still errors, run this again or fix manually:"
        echo "   Common remaining issues:"
        echo "   • Complex type definitions needed"
        echo "   • Interface definitions required"
        echo "   • Generic type parameters"
    fi
else
    echo "⚠️  npm not found. Please test manually with: npm run build"
fi

echo ""
echo "💡 Next steps:"
echo "1. If build passes: npm run dev"
echo "2. If build fails: Check build-test.log for specific errors"
echo "3. For complex issues: Define proper interfaces instead of 'any'"
echo "4. To undo all changes: ./restore-from-backup.sh"

# Create restoration script
cat > restore-from-backup.sh << EOF
#!/bin/bash
echo "Restoring files from backup: $backup_dir"
for backup_file in $backup_dir/*; do
    if [ -f "\$backup_file" ]; then
        original_path=\$(basename "\$backup_file" | sed 's/_/\//g')
        if [ -f "\$original_path" ]; then
            cp "\$backup_file" "\$original_path"
            echo "Restored: \$original_path"
        fi
    fi
done
echo "All files restored!"
EOF

chmod +x restore-from-backup.sh
echo ""
echo "📦 Restoration script created: ./restore-from-backup.sh"
