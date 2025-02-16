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
    
    case "$error_type" in
        "build")
            npm run build >/dev/null 2>&1
            return $?
            ;;
        "dependency")
            npm install >/dev/null 2>&1
            return $?
            ;;
        "syntax")
            if [[ "$file" == *.php ]]; then
                php -l "$file" >/dev/null 2>&1
            elif [[ "$file" == *.js ]]; then
                eslint "$file" >/dev/null 2>&1
            fi
            return $?
            ;;
    esac
} 