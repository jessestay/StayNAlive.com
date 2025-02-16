#!/bin/bash

# Fix all PHP coding standards issues
fix_php_standards() {
    local file="$1"
    
    # Run PHP Code Beautifier and Fixer
    if command -v phpcbf >/dev/null 2>&1; then
        phpcbf --standard=WordPress "$file"
    fi
    
    # Fix common issues
    sed -i '' -e 's/[[:space:]]*$//' \
              -e 's/\t/    /g' \
              -e 's/[^;]$/&;/' \
              -e 's/}\([^ ]\)/}\n\1/g' \
              -e 's/[^{]\{$/\{/g' \
              -e 's/\([^}]\)}/\1\n}/g' \
              -e 's/\/\/ \([A-Za-z].*[^.]\)$/\/\/ \1./' \
              "$file"
    
    # Fix function spacing
    sed -i '' 's/function\([^ ]\)/function \1/g' "$file"
    
    # Fix array alignment
    if command -v php-cs-fixer >/dev/null 2>&1; then
        php-cs-fixer fix "$file" --rules=align_multiline_comment,array_indentation
    fi
} 