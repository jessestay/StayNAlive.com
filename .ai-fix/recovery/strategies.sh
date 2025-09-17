#!/bin/bash

# Recovery strategies for different error types
recover_from_error() {
    local error_type="$1"
    local error_msg="$2"
    local file="$3"
    
    # Log recovery attempt
    log_recovery_attempt "$error_type" "$error_msg"
    
    case "$error_type" in
        "build")
            recover_from_build_error "$error_msg" "$file"
            ;;
        "dependency")
            recover_from_dependency_error "$error_msg" "$file"
            ;;
        "syntax")
            recover_from_syntax_error "$error_msg" "$file"
            ;;
        "runtime")
            recover_from_runtime_error "$error_msg" "$file"
            ;;
        "memory")
            recover_from_memory_error "$error_msg" "$file"
            ;;
        "network")
            recover_from_network_error "$error_msg" "$file"
            ;;
        "permission")
            recover_from_permission_error "$error_msg" "$file"
            ;;
        "db")
            recover_from_db_error "$error_msg" "$file"
            ;;
        "cache")
            recover_from_cache_error "$error_msg" "$file"
            ;;
        "version")
            recover_from_version_conflict "$error_msg" "$file"
            ;;
    esac
    
    # Check if recovery was successful
    verify_recovery "$error_type" "$file"
}

# Build error recovery
recover_from_build_error() {
    local error_msg="$1"
    local file="$2"
    
    # Handle stylelint config error
    if [[ $error_msg == *"Could not find \"stylelint-config-standard\""* ]]; then
        npm install --save-dev stylelint-config-standard
        
        # Create stylelint config
        cat > .stylelintrc.json << 'EOL'
{
    "extends": [
        "stylelint-config-standard",
        "@wordpress/stylelint-config"
    ],
    "rules": {
        "no-descending-specificity": null,
        "selector-class-pattern": null
    }
}
EOL
        return 0
    fi

    # Handle ESLint undefined errors
    if [[ $error_msg == *"'registerBlockVariation' is not defined"* ]] || 
       [[ $error_msg == *"'registerBlockPattern' is not defined"* ]]; then
        # Add imports to editor-customization.js
        sed -i '' '1i\
import { registerBlockVariation, registerBlockPattern } from "@wordpress/blocks";' \
            assets/js/editor-customization.js
        return 0
    fi

    # Handle unused variable warning
    if [[ $error_msg == *"'unregisterBlockStyle' is assigned a value but never used"* ]]; then
        # Either use the variable or remove it
        sed -i '' '/unregisterBlockStyle/d' assets/js/editor-customization.js
        return 0
    fi
    
    # Try common build recovery steps
    rm -rf node_modules package-lock.json
    npm cache clean --force
    npm install --legacy-peer-deps --no-audit
    
    # If webpack error, try clearing cache
    if [[ $error_msg == *"webpack"* ]]; then
        rm -rf .webpack-cache
        npm run build -- --no-cache
    fi
}

# Dependency error recovery
recover_from_dependency_error() {
    local error_msg="$1"
    local file="$2"
    
    # Try to resolve conflicts
    if [[ -f "package.json" ]]; then
        # Save current dependencies
        cp package.json package.json.backup
        
        # Remove problematic dependencies
        jq 'del(.dependencies[] | select(contains("conflict")))' package.json > package.json.tmp
        mv package.json.tmp package.json
        
        # Reinstall
        npm install --legacy-peer-deps
        
        # If failed, restore backup
        if [ $? -ne 0 ]; then
            mv package.json.backup package.json
        fi
    fi
}

# Memory error recovery
recover_from_memory_error() {
    local error_msg="$1"
    local file="$2"
    
    # Clear system caches
    sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
    
    # Optimize Node.js memory usage
    if [[ -f "package.json" ]]; then
        export NODE_OPTIONS="--max-old-space-size=4096"
        npm cache clean --force
    fi
    
    # Optimize PHP memory usage
    if [[ -f "php.ini" ]]; then
        sed -i 's/memory_limit = .*/memory_limit = 512M/' php.ini
    fi
}

# Network error recovery
recover_from_network_error() {
    local error_msg="$1"
    local file="$2"
    
    # Check connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "Network connectivity issue detected"
        return 1
    fi
    
    # Retry with increased timeout
    if [[ -f "package.json" ]]; then
        npm config set fetch-retry-mintimeout 100000
        npm config set fetch-retry-maxtimeout 600000
        npm install --network-timeout 600000
    fi
}

# Permission error recovery
recover_from_permission_error() {
    local error_msg="$1"
    local file="$2"
    
    # Fix common permission issues
    if [[ -d "node_modules" ]]; then
        sudo chown -R $USER:$USER node_modules
        chmod -R 755 node_modules
    fi
    
    if [[ -d "vendor" ]]; then
        sudo chown -R $USER:$USER vendor
        chmod -R 755 vendor
    fi
}

# Database error recovery
recover_from_db_error() {
    local error_msg="$1"
    local file="$2"
    
    # Check for common WordPress DB issues
    if [[ -f "wp-config.php" ]]; then
        # Try to repair tables
        wp db repair
        wp db optimize
        
        # Check for corrupted options
        wp option list --format=json | jq -r '.[] | select(.autoload=="yes") | .option_name' | \
        while read option; do
            wp option get "$option" >/dev/null 2>&1 || wp option delete "$option"
        done
    fi
}

# Cache error recovery
recover_from_cache_error() {
    local error_msg="$1"
    local file="$2"
    
    # Clear all caches
    rm -rf .cache
    rm -rf .webpack-cache
    rm -rf .eslintcache
    wp cache flush 2>/dev/null || true
    
    # Clear PHP opcache
    if php -r 'opcache_reset();' 2>/dev/null; then
        echo "Cleared PHP opcache"
    fi
    
    # Clear browser caches in development
    if [[ -f ".env" && -f "package.json" ]]; then
        echo "const clearCache = () => { localStorage.clear(); sessionStorage.clear(); };" > clear-cache.js
        npx playwright chromium --evaluate-script clear-cache.js
    fi
}

# Version conflict recovery
recover_from_version_conflict() {
    local error_msg="$1"
    local file="$2"
    
    # Create version resolution map
    declare -A version_map=(
        ["stylelint"]="14.16.1"
        ["@wordpress/stylelint-config"]="21.41.0"
        ["eslint"]="8.57.0"
        ["prettier"]="3.0.0"
        ["webpack"]="5.88.2"
    )
    
    # Extract package name from error
    local package=$(echo "$error_msg" | grep -oP '(?<=")@?[\w-]+/[\w-]+|[\w-]+(?=@)')
    
    if [[ -n "$package" && -n "${version_map[$package]}" ]]; then
        npm install --save-dev "${package}@${version_map[$package]}"
    fi
}

# Verify recovery success
verify_recovery() {
    local error_type="$1"
    local file="$2"
    
    # Create verification point
    create_rollback_point "verify_${error_type}"
    
    case "$error_type" in
        "build")
            # Run build with verification
            if npm run build; then
                # Verify build output
                if [[ -d "build" && -f "build/index.js" ]]; then
                    # Run tests if available
                    npm test >/dev/null 2>&1 && return 0
                fi
            fi
            # Rollback if verification failed
            rollback_to_point "verify_${error_type}"
            return 1
            ;;
        "dependency")
            # Verify all dependencies
            if npm install && npm ls >/dev/null 2>&1; then
                # Check for peer dependency issues
                if ! npm ls | grep -i "peer" >/dev/null 2>&1; then
                    return 0
                fi
            fi
            rollback_to_point "verify_${error_type}"
            return 1
            ;;
        "syntax")
            if [[ "$file" == *.php ]]; then
                # Run PHP syntax check and PHPCS
                if php -l "$file" && phpcs "$file"; then
                    return 0
                fi
            elif [[ "$file" == *.js ]]; then
                # Run ESLint and Prettier
                if eslint "$file" && prettier --check "$file"; then
                    return 0
                fi
            fi
            rollback_to_point "verify_${error_type}"
            return 1
            ;;
    esac
}

# Syntax error recovery
recover_from_syntax_error() {
    local error_msg="$1"
    local file="$2"
    
    # Fix PHP comment spacing
    if [[ $error_msg == *"FileComment.SpacingAfterComment"* ]]; then
        sed -i '' '/^\/\*\*/,/\*\//{ /\*\//{ x; p; }; H; d; }; x; p' "$file"
        return 0
    fi

    # Fix PHP inline comment endings
    if [[ $error_msg == *"InlineComment.InvalidEndChar"* ]]; then
        sed -i '' 's/\/\/ \([A-Za-z].*[^.]\)$/\/\/ \1./' "$file"
        return 0
    fi

    # Fix Yoda conditions
    if [[ $error_msg == *"YodaConditions.NotYoda"* ]]; then
        sed -i '' 's/if (\$\([a-zA-Z_]*\) [=!]== \(.*\))/if (\2 [=!]== \$\1)/' "$file"
        return 0
    fi

    # Fix whitespace at end of line
    if [[ $error_msg == *"SuperfluousWhitespace.EndLine"* ]]; then
        sed -i '' 's/[[:space:]]*$//' "$file"
        return 0
    fi

    # Rest of existing code...
}

# Maximum retry attempts
MAX_RETRIES=3

# Recursive error fixing
fix_until_resolved() {
    local error_msg="$1"
    local file="$2"
    local attempt="${3:-1}"
    
    echo -e "${BLUE}Fix attempt $attempt for $file${NC}"
    
    # Try to fix the error
    if fix_with_ai "$error_msg" "$file"; then
        # Verify the fix worked
        if verify_fix "$file"; then
            echo -e "${GREEN}Fix successful!${NC}"
            return 0
        fi
    fi
    
    # If we haven't exceeded max retries, try again with a different strategy
    if [ "$attempt" -lt "$MAX_RETRIES" ]; then
        echo -e "${YELLOW}Fix attempt $attempt failed, trying alternative approach...${NC}"
        # Get new error message if available
        local new_error=$(get_current_errors "$file")
        fix_until_resolved "${new_error:-$error_msg}" "$file" $((attempt + 1))
    else
        echo -e "${RED}Maximum fix attempts reached for $file${NC}"
        return 1
    fi
}

# Get current errors for a file
get_current_errors() {
    local file="$1"
    
    case "${file##*.}" in
        php)
            php -l "$file" 2>&1 || phpcs "$file" 2>&1
            ;;
        js)
            eslint "$file" 2>&1
            ;;
        css)
            stylelint "$file" 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Handle WordPress-specific errors
handle_wordpress_errors() {
    local error_msg="$1"
    local file="$2"
    
    # Fix Yoda conditions
    if [[ $error_msg == *"YodaConditions.NotYoda"* ]]; then
        sed -i '' -E 's/if \((\$[a-zA-Z_][a-zA-Z0-9_]*) ([=!><]+) ([^)]+)\)/if (\3 \2 \1)/g' "$file"
    fi
    
    # Fix comment spacing
    if [[ $error_msg == *"FileComment.SpacingAfterComment"* ]]; then
        sed -i '' -e '/^\/\*\*$/,/\*\// { /\*\//a\

        }' "$file"
    fi
    
    # Fix inline comments
    if [[ $error_msg == *"InlineComment.InvalidEndChar"* ]]; then
        sed -i '' -e 's/\/\/ \([A-Za-z].*[^.!?]\)$/\/\/ \1./' "$file"
    fi
}

# Handle JavaScript-specific errors
handle_javascript_errors() {
    local error_msg="$1"
    local file="$2"
    
    # Fix undefined variables
    if [[ $error_msg == *"is not defined"* ]]; then
        local var=$(echo "$error_msg" | grep -o "'.*'" | head -1 | tr -d "'")
        if [[ -n "$var" ]]; then
            sed -i '' "1i\\
import { $var } from '@wordpress/blocks';" "$file"
        fi
    fi
    
    # Fix unused variables
    if [[ $error_msg == *"is assigned a value but never used"* ]]; then
        local var=$(echo "$error_msg" | grep -o "'.*'" | head -1 | tr -d "'")
        if [[ -n "$var" ]]; then
            # Try to find a use for the variable or remove it
            if grep -q "wp.blocks" "$file"; then
                sed -i '' "s/const { .*$var.* } = wp.blocks/import { $var } from '@wordpress/blocks'/" "$file"
            else
                sed -i '' "/$var/d" "$file"
            fi
        fi
    fi
} 