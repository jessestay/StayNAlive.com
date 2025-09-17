#!/bin/bash

# Version
AI_FIX_VERSION="1.0.0"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Error tracking
ERRORS=()
WARNINGS=()

# Load project-specific config if it exists
if [ -f ".ai-fix.config.json" ]; then
    echo "Loading project configuration..."
    eval "$(jq -r 'to_entries | .[] | "export " + .key + "=\"" + .value + "\""' .ai-fix.config.json)"
fi

# Common error patterns database
declare -A ERROR_PATTERNS=(
    # NPM/Node errors
    ["Cannot find module"]=1
    ["ERESOLVE"]=1
    ["peer dependency conflict"]=1
    ["Failed to load config"]=1
    ["Missing dependencies"]=1
    
    # PHP errors
    ["PHP Parse error"]=1
    ["PHP Fatal error"]=1
    ["PHP Notice"]=1
    ["PHP Warning"]=1
    
    # Build tool errors
    ["webpack"]=1
    ["babel"]=1
    ["postcss"]=1
    ["stylelint"]=1
    ["eslint"]=1
    
    # Package manager errors
    ["npm ERR!"]=1
    ["composer"]=1
    ["yarn"]=1
)

# Main AI fix function
fix_with_ai() {
    local error_msg="$1"
    local file="$2"
    local project_type="${3:-auto}"  # Can be specified or auto-detected
    
    echo -e "${BLUE}AI attempting to fix error in ${file}:${NC}"
    echo -e "${RED}${error_msg}${NC}"
    
    # Auto-detect project type if not specified
    if [ "$project_type" = "auto" ]; then
        if [ -f "package.json" ]; then
            project_type="node"
        elif [ -f "composer.json" ]; then
            project_type="php"
        elif [ -f "Cargo.toml" ]; then
            project_type="rust"
        fi
    fi
    
    # Load project-specific fixes
    if [ -f ".ai-fix/${project_type}/fixes.sh" ]; then
        source ".ai-fix/${project_type}/fixes.sh"
    fi
    
    # Initialize pattern database if needed
    init_pattern_db
    
    # Get context for pattern learning
    local context=$(get_error_context "$error_msg" "$file" "$project_type")
    
    # Try ML-based pattern matching first
    local pattern_match=$(find_similar_patterns "$error_msg")
    if [ -n "$pattern_match" ]; then
        local fix_command=$(echo "$pattern_match" | cut -f3)
        local success_rate=$(echo "$pattern_match" | cut -f2)
        echo -e "${BLUE}Found ML-matched fix pattern${NC}"
        echo -e "${BLUE}Previous success rate: ${success_rate}${NC}"
        
        if [ "$AUTO_FIX" = "true" ] || confirm_fix "$fix_command"; then
            if eval "$fix_command"; then
                add_pattern "$error_msg" "$fix_command" 1 "$context"
                return 0
            else
                add_pattern "$error_msg" "$fix_command" 0 "$context"
            fi
        fi
    fi
    
    # Apply fixes based on error patterns
    for pattern in "${!ERROR_PATTERNS[@]}"; do
        if [[ $error_msg == *"$pattern"* ]]; then
            handle_known_error "$pattern" "$error_msg" "$file" "$project_type"
            return $?
        fi
    done
    
    # If no pattern matched, try generic fixes
    generic_error_fix "$error_msg" "$file" "$project_type"
}

# Usage function
show_usage() {
    echo "AI Fix Tool v${AI_FIX_VERSION}"
    echo "Usage: ai-fix [command] [options]"
    echo ""
    echo "Commands:"
    echo "  watch         Watch for errors in real-time"
    echo "  fix          Fix a specific error"
    echo "  init         Initialize AI Fix in current project"
    echo "  patterns     List known error patterns"
    echo ""
    echo "Options:"
    echo "  --project    Specify project type (node, php, rust, etc.)"
    echo "  --auto       Auto-detect project type"
    echo "  --config     Path to config file"
}

# Main entry point
main() {
    case "$1" in
        "watch")
            watch_for_errors "${@:2}"
            ;;
        "fix")
            fix_specific_error "${@:2}"
            ;;
        "init")
            initialize_ai_fix "${@:2}"
            ;;
        "patterns")
            list_patterns
            ;;
        *)
            show_usage
            ;;
    esac
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Handle known error patterns
handle_known_error() {
    local pattern="$1"
    local error_msg="$2"
    local file="$3"
    local project_type="$4"
    
    echo -e "${BLUE}Handling known error pattern: ${pattern}${NC}"
    
    case "$pattern" in
        "Cannot find module"|"Missing dependencies")
            handle_missing_module_error "$error_msg" "$file"
            ;;
        "ERESOLVE"|"peer dependency conflict")
            handle_dependency_conflict "$error_msg" "$file"
            ;;
        "PHP Parse error"|"PHP Fatal error"|"PHP Notice"|"PHP Warning")
            handle_php_error "$error_msg" "$file"
            ;;
        "webpack"|"babel"|"postcss"|"stylelint"|"eslint")
            handle_build_tool_error "$pattern" "$error_msg" "$file"
            ;;
        *)
            return 1
            ;;
    esac
}

# Handle missing module errors
handle_missing_module_error() {
    local error_msg="$1"
    local file="$2"
    
    # Extract module name
    local module=$(echo "$error_msg" | grep -o "'[^']*'" | head -1 | tr -d "'")
    if [ -n "$module" ]; then
        echo -e "${BLUE}Installing missing module: $module${NC}"
        npm install --save-dev "$module"
        return $?
    fi
    return 1
}

# Handle dependency conflicts
handle_dependency_conflict() {
    local error_msg="$1"
    local file="$2"
    
    echo "Resolving dependency conflicts..."
    rm -rf node_modules package-lock.json
    npm install --legacy-peer-deps --no-audit
    
    # Check for specific version conflicts
    if grep -q "stylelint" package.json; then
        npm install --save-dev stylelint@14.16.1
    fi
    if grep -q "@wordpress/stylelint-config" package.json; then
        npm install --save-dev @wordpress/stylelint-config@21.41.0
    fi
}

# Handle PHP errors
handle_php_error() {
    local error_msg="$1"
    local file="$2"
    
    # Run PHP Code Beautifier and Fixer
    if command -v phpcbf >/dev/null 2>&1; then
        phpcbf "$file"
    fi
    
    # Fix common PHP issues
    sed -i '' -e 's/[^;]$/&;/' \
             -e 's/}\([^ ]\)/}\n\1/g' \
             -e 's/[^{]\{$/\{/g' \
             -e 's/\([^}]\)}/\1\n}/g' "$file"
}

# Handle build tool errors
handle_build_tool_error() {
    local tool="$1"
    local error_msg="$2"
    local file="$3"
    
    case "$tool" in
        "webpack"|"babel")
            npm install --save-dev @babel/core @babel/preset-env
            ;;
        "postcss")
            npm install --save-dev postcss postcss-cli autoprefixer
            ;;
        "stylelint")
            npm install --save-dev stylelint stylelint-config-standard
            ;;
        "eslint")
            npm install --save-dev eslint eslint-config-standard
            ;;
    esac
} 