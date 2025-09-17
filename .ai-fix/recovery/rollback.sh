#!/bin/bash

# Rollback manager
declare -A ROLLBACK_POINTS=()

# Create rollback point
create_rollback_point() {
    local name="$1"
    local timestamp=$(date +%s)
    local snapshot_dir=".ai-fix/rollbacks/${name}_${timestamp}"
    
    mkdir -p "$snapshot_dir"
    
    # Save current state
    if [[ -f "package.json" ]]; then
        cp package.json package-lock.json "$snapshot_dir/" 2>/dev/null || true
    fi
    if [[ -f "composer.json" ]]; then
        cp composer.json composer.lock "$snapshot_dir/" 2>/dev/null || true
    fi
    
    # Save modified files
    git diff --name-only | while read file; do
        cp --parents "$file" "$snapshot_dir/"
    done
    
    ROLLBACK_POINTS["$name"]="$snapshot_dir"
    echo "Created rollback point: $name"
}

# Rollback to point
rollback_to_point() {
    local name="$1"
    local snapshot_dir="${ROLLBACK_POINTS[$name]}"
    
    if [[ -d "$snapshot_dir" ]]; then
        # Restore files
        cp -r "$snapshot_dir"/* ./
        
        # Reinstall dependencies if needed
        if [[ -f "package.json" ]]; then
            npm install --legacy-peer-deps
        fi
        if [[ -f "composer.json" ]]; then
            composer install
        fi
        
        echo "Rolled back to: $name"
        return 0
    fi
    
    echo "Rollback point not found: $name"
    return 1
} 