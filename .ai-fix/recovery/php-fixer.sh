#!/bin/bash

# Fix PHP files
fix_php_files() {
    local files=("$@")
    
    for file in "${files[@]}"; do
        echo "Fixing $file..."
        
        # Fix comment spacing
        sed -i '' -e '/^\/\*\*$/,/^ \*\/$/ {
            /^ \*\/$/ {
                a\

            }
        }' "$file"
        
        # Fix inline comments
        sed -i '' -e 's/\/\/ \([A-Za-z].*[^.!?]\)$/\/\/ \1./' "$file"
        
        # Fix Yoda conditions
        sed -i '' -e 's/if (\$\([a-zA-Z_][a-zA-Z0-9_]*\) \([=!]\+\) \([^$][^)]*\))/if (\3 \2 $\1)/' "$file"
        
        # Fix function spacing
        sed -i '' -e 's/function\([^ ]\)/function \1/g' "$file"
        
        # Fix array alignment
        if grep -q "=>" "$file"; then
            align_arrays "$file"
        fi
        
        # Run PHPCBF
        if command -v phpcbf >/dev/null 2>&1; then
            phpcbf --standard=WordPress "$file" >/dev/null 2>&1
        fi
    done
}

# Align array arrows
align_arrays() {
    local file="$1"
    local max_length=0
    local arrays=()
    
    # Find arrays and calculate max key length
    while IFS= read -r line; do
        if [[ $line =~ .*\'.*\'[[:space:]]*=\>.* ]]; then
            key_length=$(echo "$line" | sed -E 's/^[[:space:]]*'"'"'([^'"'"']*).*/\1/' | wc -c)
            ((key_length > max_length)) && max_length=$key_length
            arrays+=("$line")
        fi
    done < "$file"
    
    # Align arrows
    for line in "${arrays[@]}"; do
        key=$(echo "$line" | sed -E 's/^[[:space:]]*'"'"'([^'"'"']*).*/\1/')
        value=$(echo "$line" | sed -E 's/.*=>([^,}]*).*/\1/')
        printf "    '%s'%*s => %s,\n" "$key" $((max_length - ${#key})) "" "$value"
    done > "$file.tmp"
    
    mv "$file.tmp" "$file"
}

# Run the fixer
php_files=$(find . -name "*.php")
fix_php_files $php_files 