#!/bin/bash

echo "Fixing nodemailer method name and cleaning backup files..."
echo "======================================================="

# First, fix the nodemailer method name in any files that have it
echo "1. Fixing nodemailer.createTransporter -> nodemailer.createTransport"
echo "-------------------------------------------------------------------"

# Find all TypeScript files with the incorrect method name
FILES_TO_FIX=$(find . -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v .next)

FIXED_COUNT=0
for file in $FILES_TO_FIX; do
    if grep -q "nodemailer\.createTransporter" "$file" 2>/dev/null; then
        echo "Fixing: $file"
        cp "$file" "$file.nodemailer-backup"
        sed -i.tmp 's/nodemailer\.createTransporter/nodemailer.createTransport/g' "$file"
        rm -f "$file.tmp"
        ((FIXED_COUNT++))
    fi
done

if [ $FIXED_COUNT -gt 0 ]; then
    echo "✅ Fixed $FIXED_COUNT file(s)"
else
    echo "✅ No files needed fixing (or already fixed)"
fi

echo ""
echo "2. Cleaning up backup directories that Next.js is trying to compile"
echo "----------------------------------------------------------------"

# List backup directories/files that might be causing issues
BACKUP_ITEMS=$(find . -maxdepth 1 -name "*backup*" -o -name "backup_*" | grep -v node_modules)

if [ -n "$BACKUP_ITEMS" ]; then
    echo "Found backup items:"
    echo "$BACKUP_ITEMS"
    echo ""
    
    # Move backup items to a single archive directory
    mkdir -p .archive
    
    for item in $BACKUP_ITEMS; do
        echo "Moving $item to .archive/"
        mv "$item" .archive/
    done
    
    echo "✅ Moved backup items to .archive/ directory"
else
    echo "✅ No backup directories found in root"
fi

echo ""
echo "3. Checking for any remaining backup files in project"
echo "---------------------------------------------------"

# Find any .backup files that might still be causing issues
BACKUP_FILES=$(find . -name "*.backup" -o -name "*-backup" | grep -v node_modules | grep -v .archive | head -10)

if [ -n "$BACKUP_FILES" ]; then
    echo "Found remaining backup files:"
    echo "$BACKUP_FILES"
    echo ""
    echo "Moving these to .archive/ as well..."
    
    for backup_file in $BACKUP_FILES; do
        mkdir -p ".archive/$(dirname "$backup_file")"
        mv "$backup_file" ".archive/$backup_file"
        echo "Moved: $backup_file"
    done
    
    echo "✅ Cleaned up remaining backup files"
else
    echo "✅ No remaining backup files found"
fi

echo ""
echo "4. Adding .archive to .gitignore to prevent future issues"
echo "--------------------------------------------------------"

if [ -f ".gitignore" ]; then
    if ! grep -q "^\.archive$" .gitignore; then
        echo ".archive" >> .gitignore
        echo "✅ Added .archive to .gitignore"
    else
        echo "✅ .archive already in .gitignore"
    fi
else
    echo ".archive" > .gitignore
    echo "✅ Created .gitignore with .archive"
fi

echo ""
echo "Summary:"
echo "========"
echo "• Fixed nodemailer.createTransporter -> nodemailer.createTransport"
echo "• Moved backup directories/files to .archive/"
echo "• Added .archive to .gitignore"
echo "• Next.js will no longer try to compile backup files"
echo ""

echo "Files with nodemailer fixes (backups created):"
find . -name "*.nodemailer-backup" 2>/dev/null || echo "None"

echo ""
echo "You can now run: npm run build"
echo ""
echo "All backups are safely stored in .archive/ if you need them later."
