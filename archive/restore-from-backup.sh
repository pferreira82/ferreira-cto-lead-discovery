#!/bin/bash
echo "Restoring files from backup: typescript-fixes-backup-20250909_151933"
for backup_file in typescript-fixes-backup-20250909_151933/*; do
    if [ -f "$backup_file" ]; then
        original_path=$(basename "$backup_file" | sed 's/_/\//g')
        if [ -f "$original_path" ]; then
            cp "$backup_file" "$original_path"
            echo "Restored: $original_path"
        fi
    fi
done
echo "All files restored!"
