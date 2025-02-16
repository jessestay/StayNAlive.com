#!/bin/bash

# Recovery strategies for different error types
recover_from_error() {
    local error_type="$1"
    local error_msg="$2"
    local file="$3"
    
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
    esac
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