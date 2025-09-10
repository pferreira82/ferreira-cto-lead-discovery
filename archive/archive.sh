 #!/bin/bash

# Script to move all .sh files to an archive folder
# Creates archive folder if it doesn't exist

ARCHIVE_DIR="archive"

echo "Moving all .sh files to archive folder..."
echo "========================================"

# Create archive directory if it doesn't exist
if [ ! -d "$ARCHIVE_DIR" ]; then
    mkdir -p "$ARCHIVE_DIR"
    echo "Created archive directory: $ARCHIVE_DIR"
else
    echo "Using existing archive directory: $ARCHIVE_DIR"
fi

# Count .sh files first
SH_COUNT=$(find . -maxdepth 1 -name "*.sh" -type f | wc -l)

if [ $SH_COUNT -eq 0 ]; then
    echo "No .sh files found in current directory"
    exit 0
fi

echo "Found $SH_COUNT .sh file(s) to archive:"

# List the files that will be moved
find . -maxdepth 1 -name "*.sh" -type f -exec basename {} \;

echo ""
echo "Moving files..."

# Move all .sh files to archive directory
MOVED_COUNT=0
for file in *.sh; do
    if [ -f "$file" ]; then
        mv "$file" "$ARCHIVE_DIR/"
        echo "Moved: $file -> $ARCHIVE_DIR/"
        ((MOVED_COUNT++))
    fi
done

echo ""
echo "Archive complete!"
echo "Moved $MOVED_COUNT file(s) to $ARCHIVE_DIR/"
echo ""
echo "Archive contents:"
ls -la "$ARCHIVE_DIR"/*.sh 2>/dev/null || echo "No files in archive"
