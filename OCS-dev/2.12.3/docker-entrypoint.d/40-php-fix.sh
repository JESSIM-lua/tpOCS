#!/bin/bash

# Find all php.ini files
php_ini_files=$(find / -name php.ini 2>/dev/null)

# Check if any php.ini files were found
if [ -z "$php_ini_files" ]; then
    echo "No php.ini files found"
    exit 1
fi

# Process each php.ini file
for ini_file in $php_ini_files; do
    echo "Processing: $ini_file"

    # Create a backup
    backup_file="${ini_file}.backup_$(date +%Y%m%d_%H%M%S)"
    cp "$ini_file" "$backup_file"

    # Make the changes using sed
    sed -i \
        -e 's/^[; ]*short_open_tag\s*=.*/short_open_tag = On/' \
        -e 's/^[; ]*max_execution_time\s*=.*/max_execution_time = 360/' \
        -e 's/^[; ]*memory_limit\s*=.*/memory_limit = 256M/' \
        -e 's/^[; ]*post_max_size\s*=.*/post_max_size = 200M/' \
        -e 's/^[; ]*file_uploads\s*=.*/file_uploads = On/' \
        -e 's/^[; ]*upload_max_filesize\s*=.*/upload_max_filesize = 200M/' \
        -e 's/^[; ]*date\.timezone\s*=.*/date.timezone = Europe\/Paris/' \
        "$ini_file"

    if [ $? -eq 0 ]; then
        echo "Successfully updated $ini_file"
        echo "Backup created at $backup_file"
    else
        echo "Error updating $ini_file"
        echo "Restoring from backup..."
        cp "$backup_file" "$ini_file"
    fi
done