#!/bin/bash

# Gather context for error analysis
get_error_context() {
    local error_msg="$1"
    local file="$2"
    local project_type="$3"
    
    # Create context object
    cat << EOF
{
    "environment": {
        "os": "$(uname -s)",
        "node_version": "$(node -v 2>/dev/null || echo '')",
        "php_version": "$(php -v 2>/dev/null | head -n1 || echo '')",
        "project_type": "$project_type"
    },
    "file_info": {
        "path": "$file",
        "type": "${file##*.}",
        "size": $(stat -f%z "$file" 2>/dev/null || echo 0)
    },
    "dependencies": $(jq -c '.dependencies // {}' package.json 2>/dev/null || echo '{}'),
    "error_type": "$(categorize_error "$error_msg")",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

# Categorize error type
categorize_error() {
    local error_msg="$1"
    
    case "$error_msg" in
        *"Cannot find module"*) echo "missing_module" ;;
        *"ERESOLVE"*) echo "dependency_conflict" ;;
        *"PHP Parse error"*) echo "syntax_error" ;;
        *"webpack"*) echo "build_error" ;;
        *) echo "unknown" ;;
    esac
} 